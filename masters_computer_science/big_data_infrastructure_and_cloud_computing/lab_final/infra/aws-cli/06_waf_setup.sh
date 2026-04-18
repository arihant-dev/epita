#!/usr/bin/env bash
set -euo pipefail

PROJECT_TAG="${PROJECT_TAG:-UrbanMove-FinalLab}"
WAF_REGION="${WAF_REGION:-us-east-1}"
WEB_ACL_NAME="${WEB_ACL_NAME:-urbanmove-cloudfront-waf}"
RATE_LIMIT="${RATE_LIMIT:-1000}"
STATE_DIR="$(cd "$(dirname "$0")" && pwd)/.state"
STATE_FILE="${STATE_DIR}/ec2.env"

if [[ ! -f "${STATE_FILE}" ]]; then
  echo "Missing ${STATE_FILE}. Run previous infra scripts first."
  exit 1
fi

# shellcheck source=/dev/null
source "${STATE_FILE}"

if [[ -z "${CLOUDFRONT_DISTRIBUTION_ID:-}" ]]; then
  echo "CLOUDFRONT_DISTRIBUTION_ID missing in state. Run 03_s3_cloudfront_setup.sh first."
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
RESOURCE_ARN="arn:aws:cloudfront::${ACCOUNT_ID}:distribution/${CLOUDFRONT_DISTRIBUTION_ID}"

WEB_ACL_ARN="$(aws wafv2 list-web-acls \
  --scope CLOUDFRONT \
  --region "${WAF_REGION}" \
  --query "WebACLs[?Name=='${WEB_ACL_NAME}'].ARN | [0]" \
  --output text)"

if [[ -z "${WEB_ACL_ARN}" || "${WEB_ACL_ARN}" == "None" ]]; then
  cat > "${STATE_DIR}/waf-rules.json" <<JSON
[
  {
    "Name": "AWS-AWSManagedRulesCommonRuleSet",
    "Priority": 0,
    "Statement": {
      "ManagedRuleGroupStatement": {
        "VendorName": "AWS",
        "Name": "AWSManagedRulesCommonRuleSet"
      }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "awsCommonRules"
    }
  },
  {
    "Name": "AWS-AWSManagedRulesKnownBadInputsRuleSet",
    "Priority": 1,
    "Statement": {
      "ManagedRuleGroupStatement": {
        "VendorName": "AWS",
        "Name": "AWSManagedRulesKnownBadInputsRuleSet"
      }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "awsKnownBadInputsRules"
    }
  },
  {
    "Name": "AWS-AWSManagedRulesAmazonIpReputationList",
    "Priority": 2,
    "Statement": {
      "ManagedRuleGroupStatement": {
        "VendorName": "AWS",
        "Name": "AWSManagedRulesAmazonIpReputationList"
      }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "awsIpReputationRules"
    }
  },
  {
    "Name": "RateLimitRule",
    "Priority": 3,
    "Statement": {
      "RateBasedStatement": {
        "Limit": ${RATE_LIMIT},
        "AggregateKeyType": "IP"
      }
    },
    "Action": { "Block": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "rateLimitRule"
    }
  }
]
JSON

  WEB_ACL_ARN="$(aws wafv2 create-web-acl \
    --name "${WEB_ACL_NAME}" \
    --scope CLOUDFRONT \
    --region "${WAF_REGION}" \
    --description "UrbanMove CloudFront WAF" \
    --default-action Allow={} \
    --rules "file://${STATE_DIR}/waf-rules.json" \
    --visibility-config "SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=urbanmoveCloudfrontWaf" \
    --tags "Key=Project,Value=${PROJECT_TAG}" \
    --query 'Summary.ARN' \
    --output text)"
fi

aws wafv2 associate-web-acl \
  --region "${WAF_REGION}" \
  --web-acl-arn "${WEB_ACL_ARN}" \
  --resource-arn "${RESOURCE_ARN}" >/dev/null 2>&1 || true

cat >> "${STATE_FILE}" <<EOF
WAF_WEB_ACL_ARN=${WEB_ACL_ARN}
EOF

echo "WAF configured for CloudFront."
echo "Web ACL ARN: ${WEB_ACL_ARN}"
echo "CloudFront distribution: ${CLOUDFRONT_DISTRIBUTION_ID}"
echo "Note: WAF propagation can take a few minutes."
