#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-eu-west-3}"
PROJECT_TAG="${PROJECT_TAG:-UrbanMove-FinalLab}"
STATE_DIR="$(cd "$(dirname "$0")" && pwd)/.state"
mkdir -p "${STATE_DIR}"

if [[ -f "${STATE_DIR}/ec2.env" ]]; then
  # shellcheck source=/dev/null
  source "${STATE_DIR}/ec2.env"
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
API_PUBLIC_DNS="${API_PUBLIC_DNS:-}"
API_GW_ENDPOINT="${API_GW_ENDPOINT:-}"
if [[ -z "${API_PUBLIC_DNS}" && -z "${API_GW_ENDPOINT}" ]]; then
  echo "Either API_PUBLIC_DNS or API_GW_ENDPOINT is required."
  echo "Run 02_create_ec2_topology.sh and optionally 03a_api_gateway_setup.sh first."
  exit 1
fi

if [[ -n "${API_GW_ENDPOINT}" ]]; then
  API_ORIGIN_DOMAIN="${API_GW_ENDPOINT#https://}"
  API_ORIGIN_DOMAIN="${API_ORIGIN_DOMAIN#http://}"
  API_ORIGIN_DOMAIN="${API_ORIGIN_DOMAIN%/}"
  API_HTTP_PORT=80
  API_HTTPS_PORT=443
  API_ORIGIN_PROTOCOL_POLICY="https-only"
else
  API_ORIGIN_DOMAIN="${API_PUBLIC_DNS}"
  API_HTTP_PORT=8080
  API_HTTPS_PORT=443
  API_ORIGIN_PROTOCOL_POLICY="http-only"
fi

UI_BUCKET="${UI_BUCKET:-urbanmove-ui-${ACCOUNT_ID}-eu-west-3}"

aws s3api create-bucket \
  --region "${REGION}" \
  --bucket "${UI_BUCKET}" \
  --create-bucket-configuration "LocationConstraint=${REGION}" >/dev/null 2>&1 || true

aws s3api put-public-access-block \
  --region "${REGION}" \
  --bucket "${UI_BUCKET}" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-tagging \
  --region "${REGION}" \
  --bucket "${UI_BUCKET}" \
  --tagging "TagSet=[{Key=Project,Value=${PROJECT_TAG}}]" >/dev/null

OAC_ID="$(aws cloudfront create-origin-access-control \
  --origin-access-control-config "Name=urbanmove-oac,Description=OAC for urbanmove UI,SigningProtocol=sigv4,SigningBehavior=always,OriginAccessControlOriginType=s3" \
  --query 'OriginAccessControl.Id' \
  --output text 2>/dev/null || true)"

if [[ -z "${OAC_ID}" || "${OAC_ID}" == "None" ]]; then
  OAC_ID="$(aws cloudfront list-origin-access-controls --query 'OriginAccessControlList.Items[?Name==`urbanmove-oac`].Id | [0]' --output text)"
fi

DISTRIBUTION_CONFIG_FILE="${STATE_DIR}/distribution-config.json"
cat > "${DISTRIBUTION_CONFIG_FILE}" <<JSON
{
  "CallerReference": "urbanmove-$(date +%s)",
  "Comment": "UrbanMove final lab distribution",
  "Enabled": true,
  "Origins": {
    "Quantity": 2,
    "Items": [
      {
        "Id": "ui-s3-origin",
        "DomainName": "${UI_BUCKET}.s3.${REGION}.amazonaws.com",
        "S3OriginConfig": { "OriginAccessIdentity": "" },
        "OriginAccessControlId": "${OAC_ID}"
      },
      {
        "Id": "api-origin",
        "DomainName": "${API_ORIGIN_DOMAIN}",
        "CustomOriginConfig": {
          "HTTPPort": ${API_HTTP_PORT},
          "HTTPSPort": ${API_HTTPS_PORT},
          "OriginProtocolPolicy": "${API_ORIGIN_PROTOCOL_POLICY}",
          "OriginSslProtocols": {
            "Quantity": 1,
            "Items": ["TLSv1.2"]
          }
        }
      }
    ]
  },
  "DefaultRootObject": "index.html",
  "DefaultCacheBehavior": {
    "TargetOriginId": "ui-s3-origin",
    "ViewerProtocolPolicy": "redirect-to-https",
    "TrustedSigners": { "Enabled": false, "Quantity": 0 },
    "TrustedKeyGroups": { "Enabled": false, "Quantity": 0 },
    "AllowedMethods": { "Quantity": 2, "Items": ["GET", "HEAD"], "CachedMethods": { "Quantity": 2, "Items": ["GET", "HEAD"] } },
    "Compress": true,
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": { "Forward": "none" }
    },
    "MinTTL": 0
  },
  "CacheBehaviors": {
    "Quantity": 1,
    "Items": [
      {
        "PathPattern": "/api/*",
        "TargetOriginId": "api-origin",
        "ViewerProtocolPolicy": "redirect-to-https",
        "TrustedSigners": { "Enabled": false, "Quantity": 0 },
        "TrustedKeyGroups": { "Enabled": false, "Quantity": 0 },
        "AllowedMethods": {
          "Quantity": 7,
          "Items": ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"],
          "CachedMethods": { "Quantity": 2, "Items": ["GET", "HEAD"] }
        },
        "Compress": true,
        "ForwardedValues": {
          "QueryString": true,
          "Headers": { "Quantity": 1, "Items": ["Authorization"] },
          "Cookies": { "Forward": "all" }
        },
        "MinTTL": 0
      }
    ]
  },
  "PriceClass": "PriceClass_100",
  "ViewerCertificate": { "CloudFrontDefaultCertificate": true }
}
JSON

DISTRIBUTION_ID="$(aws cloudfront create-distribution \
  --distribution-config file://"${DISTRIBUTION_CONFIG_FILE}" \
  --query 'Distribution.Id' \
  --output text)"

DISTRIBUTION_DOMAIN="$(aws cloudfront get-distribution --id "${DISTRIBUTION_ID}" --query 'Distribution.DomainName' --output text)"

cat > "${STATE_DIR}/ui-bucket-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipalReadOnly",
      "Effect": "Allow",
      "Principal": { "Service": "cloudfront.amazonaws.com" },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${UI_BUCKET}/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::${ACCOUNT_ID}:distribution/${DISTRIBUTION_ID}"
        }
      }
    }
  ]
}
JSON

aws s3api put-bucket-policy \
  --region "${REGION}" \
  --bucket "${UI_BUCKET}" \
  --policy file://"${STATE_DIR}/ui-bucket-policy.json"

cat >> "${STATE_DIR}/ec2.env" <<EOF
UI_BUCKET=${UI_BUCKET}
CLOUDFRONT_DISTRIBUTION_ID=${DISTRIBUTION_ID}
CLOUDFRONT_DOMAIN=${DISTRIBUTION_DOMAIN}
EOF

echo "S3 + CloudFront configured."
echo "UI bucket: ${UI_BUCKET}"
echo "CloudFront domain: https://${DISTRIBUTION_DOMAIN}"
if [[ -n "${API_GW_ENDPOINT}" ]]; then
  echo "CloudFront API origin: ${API_GW_ENDPOINT}"
else
  echo "CloudFront API origin: http://${API_PUBLIC_DNS}:8080"
fi
