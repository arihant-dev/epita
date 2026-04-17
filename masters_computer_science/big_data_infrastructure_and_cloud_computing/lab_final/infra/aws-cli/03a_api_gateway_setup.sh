#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-eu-west-3}"
PROJECT_TAG="${PROJECT_TAG:-UrbanMove-FinalLab}"
STATE_DIR="$(cd "$(dirname "$0")" && pwd)/.state"
STATE_FILE="${STATE_DIR}/ec2.env"
mkdir -p "${STATE_DIR}"

if [[ ! -f "${STATE_FILE}" ]]; then
  echo "Missing ${STATE_FILE}. Run 02_create_ec2_topology.sh first."
  exit 1
fi

# shellcheck source=/dev/null
source "${STATE_FILE}"

API_HTTP_API_NAME="${API_HTTP_API_NAME:-urbanmove-routing-http-api}"
EXPOSE_SERVICE_HTTP_FOR_APIGW="${EXPOSE_SERVICE_HTTP_FOR_APIGW:-true}"

resolve_public_dns() {
  local instance_id="$1"
  aws ec2 describe-instances \
    --region "${REGION}" \
    --instance-ids "${instance_id}" \
    --query 'Reservations[0].Instances[0].PublicDnsName' \
    --output text
}

API_PUBLIC_DNS="${API_PUBLIC_DNS:-$(resolve_public_dns "${API_INSTANCE_ID}")}"
AUTH_PUBLIC_DNS="${AUTH_PUBLIC_DNS:-$(resolve_public_dns "${AUTH_INSTANCE_ID}")}"
INGEST_PUBLIC_DNS="${INGEST_PUBLIC_DNS:-$(resolve_public_dns "${INGEST_INSTANCE_ID}")}"

if [[ -z "${API_PUBLIC_DNS}" || "${API_PUBLIC_DNS}" == "None" ]]; then
  echo "Could not resolve API public DNS."
  exit 1
fi

if [[ "${EXPOSE_SERVICE_HTTP_FOR_APIGW}" == "true" ]]; then
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_API}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8080,"ToPort":8080,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_AUTH}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8081,"ToPort":8081,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8082,"ToPort":8082,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true
fi

API_GW_ID="$(aws apigatewayv2 get-apis --region "${REGION}" --query "Items[?Name=='${API_HTTP_API_NAME}'].ApiId | [0]" --output text)"
if [[ -z "${API_GW_ID}" || "${API_GW_ID}" == "None" ]]; then
  API_GW_ID="$(aws apigatewayv2 create-api \
    --region "${REGION}" \
    --name "${API_HTTP_API_NAME}" \
    --protocol-type HTTP \
    --tags "Project=${PROJECT_TAG}" \
    --query 'ApiId' \
    --output text)"
fi

if ! aws apigatewayv2 get-stage --region "${REGION}" --api-id "${API_GW_ID}" --stage-name '$default' >/dev/null 2>&1; then
  aws apigatewayv2 create-stage \
    --region "${REGION}" \
    --api-id "${API_GW_ID}" \
    --stage-name '$default' \
    --auto-deploy >/dev/null
else
  aws apigatewayv2 update-stage \
    --region "${REGION}" \
    --api-id "${API_GW_ID}" \
    --stage-name '$default' \
    --auto-deploy >/dev/null
fi

create_integration() {
  local uri="$1"
  aws apigatewayv2 create-integration \
    --region "${REGION}" \
    --api-id "${API_GW_ID}" \
    --integration-type HTTP_PROXY \
    --integration-method ANY \
    --integration-uri "${uri}" \
    --payload-format-version "1.0" \
    --timeout-in-millis 30000 \
    --query 'IntegrationId' \
    --output text
}

upsert_route() {
  local route_key="$1"
  local integration_id="$2"
  local route_id
  route_id="$(aws apigatewayv2 get-routes --region "${REGION}" --api-id "${API_GW_ID}" --query "Items[?RouteKey=='${route_key}'].RouteId | [0]" --output text)"
  if [[ -z "${route_id}" || "${route_id}" == "None" ]]; then
    aws apigatewayv2 create-route \
      --region "${REGION}" \
      --api-id "${API_GW_ID}" \
      --route-key "${route_key}" \
      --target "integrations/${integration_id}" >/dev/null
  else
    aws apigatewayv2 update-route \
      --region "${REGION}" \
      --api-id "${API_GW_ID}" \
      --route-id "${route_id}" \
      --target "integrations/${integration_id}" >/dev/null
  fi
}

API_INT_ID="$(create_integration "http://${API_PUBLIC_DNS}:8080")"
upsert_route "ANY /api/{proxy+}" "${API_INT_ID}"

if [[ -n "${INGEST_PUBLIC_DNS}" && "${INGEST_PUBLIC_DNS}" != "None" ]]; then
  INGEST_INT_ID="$(create_integration "http://${INGEST_PUBLIC_DNS}:8082")"
  upsert_route "ANY /gov-feed/{proxy+}" "${INGEST_INT_ID}"
  INGEST_HEALTH_INT_ID="$(create_integration "http://${INGEST_PUBLIC_DNS}:8082/healthz")"
  upsert_route "GET /health/ingest" "${INGEST_HEALTH_INT_ID}"
fi

if [[ -n "${AUTH_PUBLIC_DNS}" && "${AUTH_PUBLIC_DNS}" != "None" ]]; then
  AUTH_HEALTH_INT_ID="$(create_integration "http://${AUTH_PUBLIC_DNS}:8081/healthz")"
  upsert_route "GET /health/auth" "${AUTH_HEALTH_INT_ID}"
fi

API_HEALTH_INT_ID="$(create_integration "http://${API_PUBLIC_DNS}:8080/healthz")"
upsert_route "GET /health/api" "${API_HEALTH_INT_ID}"

API_GW_ENDPOINT="$(aws apigatewayv2 get-api --region "${REGION}" --api-id "${API_GW_ID}" --query 'ApiEndpoint' --output text)"

cat >> "${STATE_FILE}" <<EOF
API_PUBLIC_DNS=${API_PUBLIC_DNS}
AUTH_PUBLIC_DNS=${AUTH_PUBLIC_DNS}
INGEST_PUBLIC_DNS=${INGEST_PUBLIC_DNS}
API_GW_ID=${API_GW_ID}
API_GW_ENDPOINT=${API_GW_ENDPOINT}
EOF

echo "API Gateway configured."
echo "API ID: ${API_GW_ID}"
echo "Invoke URL: ${API_GW_ENDPOINT}"
echo "Routes: /api/* -> API EC2, /gov-feed/* -> INGEST EC2, /health/* -> service hosts"
