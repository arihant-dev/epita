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
PRIVATE_NETWORK_MODE="${PRIVATE_NETWORK_MODE:-false}"

resolve_public_dns() {
  local instance_id="$1"
  aws ec2 describe-instances \
    --region "${REGION}" \
    --instance-ids "${instance_id}" \
    --query 'Reservations[0].Instances[0].PublicDnsName' \
    --output text
}

if [[ "${PRIVATE_NETWORK_MODE}" != "true" ]]; then
  API_PUBLIC_DNS="${API_PUBLIC_DNS:-$(resolve_public_dns "${API_INSTANCE_ID}")}"
  AUTH_PUBLIC_DNS="${AUTH_PUBLIC_DNS:-$(resolve_public_dns "${AUTH_INSTANCE_ID}")}"
  INGEST_PUBLIC_DNS="${INGEST_PUBLIC_DNS:-$(resolve_public_dns "${INGEST_INSTANCE_ID}")}"
  if [[ -z "${API_PUBLIC_DNS}" || "${API_PUBLIC_DNS}" == "None" ]]; then
    echo "Could not resolve API public DNS."
    exit 1
  fi
fi

if [[ "${EXPOSE_SERVICE_HTTP_FOR_APIGW}" == "true" && "${PRIVATE_NETWORK_MODE}" != "true" ]]; then
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

APIGW_VPC_LINK_ID="${APIGW_VPC_LINK_ID:-}"
if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  if [[ -z "${NLB_LISTENER_API_ARN:-}" || -z "${NLB_LISTENER_AUTH_ARN:-}" || -z "${NLB_LISTENER_INGEST_ARN:-}" ]]; then
    echo "Private mode requires NLB listener ARNs in ${STATE_FILE}."
    echo "Re-run 02_create_ec2_topology.sh after provisioning private network."
    exit 1
  fi

  APIGW_VPC_LINK_ID="$(aws apigatewayv2 get-vpc-links --region "${REGION}" --query "Items[?Name=='urbanmove-vpc-link'].VpcLinkId | [0]" --output text)"
  if [[ -n "${APIGW_VPC_LINK_ID}" && "${APIGW_VPC_LINK_ID}" != "None" ]]; then
    existing_status="$(aws apigatewayv2 get-vpc-link --region "${REGION}" --vpc-link-id "${APIGW_VPC_LINK_ID}" --query 'VpcLinkStatus' --output text)"
    if [[ "${existing_status}" == "FAILED" || "${existing_status}" == "INACTIVE" ]]; then
      aws apigatewayv2 delete-vpc-link --region "${REGION}" --vpc-link-id "${APIGW_VPC_LINK_ID}" >/dev/null 2>&1 || true
      APIGW_VPC_LINK_ID=""
    fi
  fi

  if [[ -z "${APIGW_VPC_LINK_ID}" || "${APIGW_VPC_LINK_ID}" == "None" ]]; then
    create_vpc_link_try() {
      local subnet_args=("$@")
      local out
      out="$(aws apigatewayv2 create-vpc-link \
        --region "${REGION}" \
        --name urbanmove-vpc-link \
        --subnet-ids "${subnet_args[@]}" \
        --query 'VpcLinkId' \
        --output text 2>&1)" || {
        echo "${out}" >&2
        return 1
      }
      echo "${out}"
      return 0
    }

    APIGW_VPC_LINK_ID="$(create_vpc_link_try "${PRIVATE_SUBNET_A_ID}" "${PRIVATE_SUBNET_B_ID}" || true)"
    if [[ -z "${APIGW_VPC_LINK_ID}" || "${APIGW_VPC_LINK_ID}" == "None" ]]; then
      APIGW_VPC_LINK_ID="$(create_vpc_link_try "${PRIVATE_SUBNET_A_ID}" || true)"
    fi
    if [[ -z "${APIGW_VPC_LINK_ID}" || "${APIGW_VPC_LINK_ID}" == "None" ]]; then
      APIGW_VPC_LINK_ID="$(create_vpc_link_try "${PRIVATE_SUBNET_B_ID}" || true)"
    fi
    if [[ -z "${APIGW_VPC_LINK_ID}" || "${APIGW_VPC_LINK_ID}" == "None" ]]; then
      if [[ -n "${PUBLIC_SUBNET_ID:-}" ]]; then
        APIGW_VPC_LINK_ID="$(create_vpc_link_try "${PUBLIC_SUBNET_ID}" || true)"
      fi
    fi
    if [[ -z "${APIGW_VPC_LINK_ID}" || "${APIGW_VPC_LINK_ID}" == "None" ]]; then
      echo "Failed to create API Gateway VPC Link with available subnets."
      exit 1
    fi
  fi

  for _ in $(seq 1 60); do
    status="$(aws apigatewayv2 get-vpc-link --region "${REGION}" --vpc-link-id "${APIGW_VPC_LINK_ID}" --query 'VpcLinkStatus' --output text)"
    if [[ "${status}" == "AVAILABLE" ]]; then
      break
    fi
    if [[ "${status}" == "FAILED" || "${status}" == "INACTIVE" ]]; then
      echo "VPC Link status is ${status}."
      exit 1
    fi
    sleep 10
  done

  final_status="$(aws apigatewayv2 get-vpc-link --region "${REGION}" --vpc-link-id "${APIGW_VPC_LINK_ID}" --query 'VpcLinkStatus' --output text)"
  if [[ "${final_status}" != "AVAILABLE" ]]; then
    echo "VPC Link is not available yet (status=${final_status}). Re-run this script in a few minutes."
    exit 1
  fi
fi

create_integration() {
  local uri="$1"
  local request_parameters="${2:-}"
  local connection_type="${3:-INTERNET}"
  local connection_id="${4:-}"

  local cmd=(
    aws apigatewayv2 create-integration
    --region "${REGION}"
    --api-id "${API_GW_ID}"
    --integration-type HTTP_PROXY
    --integration-method ANY
    --integration-uri "${uri}"
    --payload-format-version "1.0"
    --timeout-in-millis 30000
  )
  if [[ -n "${request_parameters}" ]]; then
    cmd+=(--request-parameters "${request_parameters}")
  fi
  if [[ "${connection_type}" == "VPC_LINK" ]]; then
    cmd+=(--connection-type VPC_LINK --connection-id "${connection_id}")
  fi
  "${cmd[@]}" --query 'IntegrationId' --output text
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

if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  API_INT_ID="$(create_integration "${NLB_LISTENER_API_ARN}" '{"overwrite:path":"/$request.path.proxy"}' "VPC_LINK" "${APIGW_VPC_LINK_ID}")"
  upsert_route "ANY /api/{proxy+}" "${API_INT_ID}"

  INGEST_INT_ID="$(create_integration "${NLB_LISTENER_INGEST_ARN}" '{"overwrite:path":"/gov-feed/$request.path.proxy"}' "VPC_LINK" "${APIGW_VPC_LINK_ID}")"
  upsert_route "ANY /gov-feed/{proxy+}" "${INGEST_INT_ID}"

  API_HEALTH_INT_ID="$(create_integration "${NLB_LISTENER_API_ARN}" '{"overwrite:path":"/healthz"}' "VPC_LINK" "${APIGW_VPC_LINK_ID}")"
  upsert_route "GET /health/api" "${API_HEALTH_INT_ID}"

  AUTH_HEALTH_INT_ID="$(create_integration "${NLB_LISTENER_AUTH_ARN}" '{"overwrite:path":"/healthz"}' "VPC_LINK" "${APIGW_VPC_LINK_ID}")"
  upsert_route "GET /health/auth" "${AUTH_HEALTH_INT_ID}"

  INGEST_HEALTH_INT_ID="$(create_integration "${NLB_LISTENER_INGEST_ARN}" '{"overwrite:path":"/healthz"}' "VPC_LINK" "${APIGW_VPC_LINK_ID}")"
  upsert_route "GET /health/ingest" "${INGEST_HEALTH_INT_ID}"
else
  API_INT_ID="$(create_integration "http://${API_PUBLIC_DNS}:8080" '{"overwrite:path":"/$request.path.proxy"}')"
  upsert_route "ANY /api/{proxy+}" "${API_INT_ID}"

  if [[ -n "${INGEST_PUBLIC_DNS}" && "${INGEST_PUBLIC_DNS}" != "None" ]]; then
    INGEST_INT_ID="$(create_integration "http://${INGEST_PUBLIC_DNS}:8082" '{"overwrite:path":"/gov-feed/$request.path.proxy"}')"
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
fi

API_GW_ENDPOINT="$(aws apigatewayv2 get-api --region "${REGION}" --api-id "${API_GW_ID}" --query 'ApiEndpoint' --output text)"

cat >> "${STATE_FILE}" <<EOF
API_PUBLIC_DNS=${API_PUBLIC_DNS:-}
AUTH_PUBLIC_DNS=${AUTH_PUBLIC_DNS:-}
INGEST_PUBLIC_DNS=${INGEST_PUBLIC_DNS:-}
API_GW_ID=${API_GW_ID}
API_GW_ENDPOINT=${API_GW_ENDPOINT}
APIGW_VPC_LINK_ID=${APIGW_VPC_LINK_ID:-}
EOF

echo "API Gateway configured."
echo "API ID: ${API_GW_ID}"
echo "Invoke URL: ${API_GW_ENDPOINT}"
if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  echo "Routes: /api/* and /gov-feed/* -> private services via VPC Link + internal NLB"
else
  echo "Routes: /api/* -> API EC2, /gov-feed/* -> INGEST EC2, /health/* -> service hosts"
fi
