#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-eu-west-3}"
PROJECT_TAG="${PROJECT_TAG:-UrbanMove-FinalLab}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.micro}"
KEY_NAME="${KEY_NAME:-}"
AMI_ID="${AMI_ID:-}"
ADMIN_CIDR="${ADMIN_CIDR:-}"
EXPOSE_SERVICE_HTTP_FOR_APIGW="${EXPOSE_SERVICE_HTTP_FOR_APIGW:-true}"
STATE_DIR="$(cd "$(dirname "$0")" && pwd)/.state"
NETWORK_STATE_FILE="${STATE_DIR}/network.env"
IAM_STATE_FILE="${STATE_DIR}/iam.env"
mkdir -p "${STATE_DIR}"

if [[ -f "${NETWORK_STATE_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${NETWORK_STATE_FILE}"
fi

if [[ -f "${IAM_STATE_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${IAM_STATE_FILE}"
fi

PRIVATE_NETWORK_MODE="${PRIVATE_NETWORK_MODE:-false}"
EC2_INSTANCE_PROFILE_NAME="${EC2_INSTANCE_PROFILE_NAME:-}"

if [[ -z "${KEY_NAME}" ]]; then
  echo "KEY_NAME is required."
  echo "Example: KEY_NAME=my-key ./02_create_ec2_topology.sh"
  exit 1
fi

if [[ -z "${ADMIN_CIDR}" ]]; then
  IP="$(curl -fsSL https://checkip.amazonaws.com | tr -d '\n')"
  ADMIN_CIDR="${IP}/32"
fi

if [[ -z "${AMI_ID}" ]]; then
  # Prefer Ubuntu 22.04 x86_64 for t3.micro; fallback to Amazon Linux 2023.
  AMI_ID="$(aws ssm get-parameter \
    --region "${REGION}" \
    --name "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id" \
    --query 'Parameter.Value' \
    --output text 2>/dev/null || true)"
fi

if [[ -z "${AMI_ID}" || "${AMI_ID}" == "None" ]]; then
  AMI_ID="$(aws ssm get-parameter \
    --region "${REGION}" \
    --name "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" \
    --query 'Parameter.Value' \
    --output text 2>/dev/null || true)"
fi

if [[ ! "${AMI_ID}" =~ ^ami-[a-zA-Z0-9]+$ ]]; then
  echo "Could not resolve a valid AMI_ID automatically."
  echo "Set AMI_ID explicitly, e.g.:"
  echo "AMI_ID=\$(aws ec2 describe-images --region ${REGION} --owners amazon --filters Name=name,Values='al2023-ami-*-x86_64' Name=state,Values=available --query 'Images | sort_by(@,&CreationDate)[-1].ImageId' --output text) KEY_NAME=${KEY_NAME} ./02_create_ec2_topology.sh"
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  if [[ -z "${VPC_ID:-}" || -z "${VPC_CIDR:-}" || -z "${PUBLIC_SUBNET_ID:-}" || -z "${PRIVATE_SUBNET_A_ID:-}" || -z "${PRIVATE_SUBNET_B_ID:-}" ]]; then
    echo "PRIVATE_NETWORK_MODE=true requires .state/network.env from 02a_create_vpc_private_network.sh."
    exit 1
  fi
else
  VPC_ID="$(aws ec2 describe-vpcs --region "${REGION}" --filters Name=isDefault,Values=true --query 'Vpcs[0].VpcId' --output text)"
  SUBNET_ID="$(aws ec2 describe-subnets --region "${REGION}" --filters Name=vpc-id,Values="${VPC_ID}" Name=default-for-az,Values=true --query 'Subnets[0].SubnetId' --output text)"
fi

create_sg_if_missing() {
  local name="$1"
  local desc="$2"
  local sg_id
  sg_id="$(aws ec2 describe-security-groups --region "${REGION}" --filters "Name=vpc-id,Values=${VPC_ID}" "Name=group-name,Values=${name}" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || true)"
  if [[ -z "${sg_id}" || "${sg_id}" == "None" ]]; then
    sg_id="$(aws ec2 create-security-group --region "${REGION}" --group-name "${name}" --description "${desc}" --vpc-id "${VPC_ID}" --query GroupId --output text)"
    aws ec2 create-tags --region "${REGION}" --resources "${sg_id}" --tags "Key=Project,Value=${PROJECT_TAG}" "Key=Name,Value=${name}" >/dev/null
  fi
  echo "${sg_id}"
}

SG_API="$(create_sg_if_missing urbanmove-api-sg "urbanmove API SG")"
SG_AUTH="$(create_sg_if_missing urbanmove-auth-sg "urbanmove Auth SG")"
SG_INGEST="$(create_sg_if_missing urbanmove-ingest-sg "urbanmove Ingestion SG")"
SG_BASTION=""
if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  SG_BASTION="$(create_sg_if_missing urbanmove-bastion-sg "urbanmove Bastion SG")"
fi

if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_BASTION}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"IpRanges\":[{\"CidrIp\":\"${ADMIN_CIDR}\"}]}]" >/dev/null 2>&1 || true
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_API}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_BASTION}\"}]}]" >/dev/null 2>&1 || true
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_AUTH}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_BASTION}\"}]}]" >/dev/null 2>&1 || true
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_BASTION}\"}]}]" >/dev/null 2>&1 || true
  # Keep services private by subnet/public-IP design; allow NLB and API Gateway VPC Link health/proxy traffic.
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_API}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8080,"ToPort":8080,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true
else
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_API}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"IpRanges\":[{\"CidrIp\":\"${ADMIN_CIDR}\"}]}]" >/dev/null 2>&1 || true
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_AUTH}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"IpRanges\":[{\"CidrIp\":\"${ADMIN_CIDR}\"}]}]" >/dev/null 2>&1 || true
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"IpRanges\":[{\"CidrIp\":\"${ADMIN_CIDR}\"}]}]" >/dev/null 2>&1 || true
  aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_API}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8080,"ToPort":8080,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true
fi

if [[ "${EXPOSE_SERVICE_HTTP_FOR_APIGW}" == "true" ]]; then
  if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
    aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_AUTH}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8081,"ToPort":8081,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true
    aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8082,"ToPort":8082,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true
  else
    aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_AUTH}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8081,"ToPort":8081,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true
    aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8082,"ToPort":8082,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true
  fi
fi

# Internal RPC: API -> AUTH/INGEST.
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_AUTH}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":50051,\"ToPort\":50051,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_API}\"}]}]" >/dev/null 2>&1 || true
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":50052,\"ToPort\":50052,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_API}\"}]}]" >/dev/null 2>&1 || true

# Ingest host local stack ports (NATS/Postgres only from itself).
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":4222,\"ToPort\":4222,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_INGEST}\"}]},{\"IpProtocol\":\"tcp\",\"FromPort\":5432,\"ToPort\":5432,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_INGEST}\"}]}]" >/dev/null 2>&1 || true

create_instance() {
  local name="$1"
  local subnet_id="$2"
  local sg_id="$3"
  local associate_public_ip="$4"
  local instance_id
  local args=(
    --region "${REGION}"
    --image-id "${AMI_ID}"
    --instance-type "${INSTANCE_TYPE}"
    --key-name "${KEY_NAME}"
    --subnet-id "${subnet_id}"
    --security-group-ids "${sg_id}"
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${name}},{Key=Project,Value=${PROJECT_TAG}}]"
  )
  if [[ -n "${EC2_INSTANCE_PROFILE_NAME}" ]]; then
    args+=(--iam-instance-profile "Name=${EC2_INSTANCE_PROFILE_NAME}")
  fi
  if [[ "${associate_public_ip}" == "true" ]]; then
    args+=(--associate-public-ip-address)
  else
    args+=(--no-associate-public-ip-address)
  fi
  instance_id="$(aws ec2 run-instances "${args[@]}" --query 'Instances[0].InstanceId' --output text)"
  echo "${instance_id}"
}

if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  BASTION_INSTANCE_ID="$(create_instance urbanmove-bastion-ec2 "${PUBLIC_SUBNET_ID}" "${SG_BASTION}" "true")"
  API_INSTANCE_ID="$(create_instance urbanmove-api-ec2 "${PRIVATE_SUBNET_A_ID}" "${SG_API}" "false")"
  AUTH_INSTANCE_ID="$(create_instance urbanmove-auth-ec2 "${PRIVATE_SUBNET_B_ID}" "${SG_AUTH}" "false")"
  INGEST_INSTANCE_ID="$(create_instance urbanmove-ingest-ec2 "${PRIVATE_SUBNET_A_ID}" "${SG_INGEST}" "false")"
  aws ec2 wait instance-running --region "${REGION}" --instance-ids "${BASTION_INSTANCE_ID}" "${API_INSTANCE_ID}" "${AUTH_INSTANCE_ID}" "${INGEST_INSTANCE_ID}"
else
  BASTION_INSTANCE_ID=""
  API_INSTANCE_ID="$(create_instance urbanmove-api-ec2 "${SUBNET_ID}" "${SG_API}" "true")"
  AUTH_INSTANCE_ID="$(create_instance urbanmove-auth-ec2 "${SUBNET_ID}" "${SG_AUTH}" "true")"
  INGEST_INSTANCE_ID="$(create_instance urbanmove-ingest-ec2 "${SUBNET_ID}" "${SG_INGEST}" "true")"
  aws ec2 wait instance-running --region "${REGION}" --instance-ids "${API_INSTANCE_ID}" "${AUTH_INSTANCE_ID}" "${INGEST_INSTANCE_ID}"
fi

describe_instance_field() {
  local instance_id="$1"
  local field="$2"
  aws ec2 describe-instances --region "${REGION}" --instance-ids "${instance_id}" --query "Reservations[0].Instances[0].${field}" --output text
}

API_PUBLIC_DNS="$(describe_instance_field "${API_INSTANCE_ID}" PublicDnsName)"
AUTH_PUBLIC_DNS="$(describe_instance_field "${AUTH_INSTANCE_ID}" PublicDnsName)"
INGEST_PUBLIC_DNS="$(describe_instance_field "${INGEST_INSTANCE_ID}" PublicDnsName)"
API_PRIVATE_IP="$(describe_instance_field "${API_INSTANCE_ID}" PrivateIpAddress)"
AUTH_PRIVATE_IP="$(describe_instance_field "${AUTH_INSTANCE_ID}" PrivateIpAddress)"
INGEST_PRIVATE_IP="$(describe_instance_field "${INGEST_INSTANCE_ID}" PrivateIpAddress)"

BASTION_PUBLIC_DNS=""
BASTION_PRIVATE_IP=""
if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  BASTION_PUBLIC_DNS="$(describe_instance_field "${BASTION_INSTANCE_ID}" PublicDnsName)"
  BASTION_PRIVATE_IP="$(describe_instance_field "${BASTION_INSTANCE_ID}" PrivateIpAddress)"
fi

NLB_ARN=""
NLB_DNS=""
NLB_LISTENER_API_ARN=""
NLB_LISTENER_AUTH_ARN=""
NLB_LISTENER_INGEST_ARN=""

if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  NLB_ARN="$(aws elbv2 describe-load-balancers --region "${REGION}" --names urbanmove-internal-nlb --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || true)"
  if [[ -z "${NLB_ARN}" || "${NLB_ARN}" == "None" ]]; then
    NLB_ARN="$(aws elbv2 create-load-balancer \
      --region "${REGION}" \
      --name urbanmove-internal-nlb \
      --type network \
      --scheme internal \
      --subnets "${PRIVATE_SUBNET_A_ID}" "${PRIVATE_SUBNET_B_ID}" \
      --tags "Key=Project,Value=${PROJECT_TAG}" "Key=Name,Value=urbanmove-internal-nlb" \
      --query 'LoadBalancers[0].LoadBalancerArn' \
      --output text)"
  fi
  aws elbv2 modify-load-balancer-attributes \
    --region "${REGION}" \
    --load-balancer-arn "${NLB_ARN}" \
    --attributes Key=load_balancing.cross_zone.enabled,Value=true >/dev/null

  create_tg_if_missing() {
    local name="$1"
    local port="$2"
    local tg_arn
    tg_arn="$(aws elbv2 describe-target-groups --region "${REGION}" --names "${name}" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || true)"
    if [[ -z "${tg_arn}" || "${tg_arn}" == "None" ]]; then
      tg_arn="$(aws elbv2 create-target-group \
        --region "${REGION}" \
        --name "${name}" \
        --protocol TCP \
        --port "${port}" \
        --target-type instance \
        --vpc-id "${VPC_ID}" \
        --health-check-protocol TCP \
        --query 'TargetGroups[0].TargetGroupArn' \
        --output text)"
    fi
    echo "${tg_arn}"
  }

  TG_API_ARN="$(create_tg_if_missing um-api-tg 8080)"
  TG_AUTH_ARN="$(create_tg_if_missing um-auth-tg 8081)"
  TG_INGEST_ARN="$(create_tg_if_missing um-ingest-tg 8082)"

  aws elbv2 register-targets --region "${REGION}" --target-group-arn "${TG_API_ARN}" --targets "Id=${API_INSTANCE_ID},Port=8080" >/dev/null
  aws elbv2 register-targets --region "${REGION}" --target-group-arn "${TG_AUTH_ARN}" --targets "Id=${AUTH_INSTANCE_ID},Port=8081" >/dev/null
  aws elbv2 register-targets --region "${REGION}" --target-group-arn "${TG_INGEST_ARN}" --targets "Id=${INGEST_INSTANCE_ID},Port=8082" >/dev/null

  create_listener_if_missing() {
    local nlb_arn="$1"
    local port="$2"
    local tg_arn="$3"
    local listener_arn
    listener_arn="$(aws elbv2 describe-listeners --region "${REGION}" --load-balancer-arn "${nlb_arn}" --query "Listeners[?Port==\`${port}\`].ListenerArn | [0]" --output text)"
    if [[ -z "${listener_arn}" || "${listener_arn}" == "None" ]]; then
      listener_arn="$(aws elbv2 create-listener \
        --region "${REGION}" \
        --load-balancer-arn "${nlb_arn}" \
        --protocol TCP \
        --port "${port}" \
        --default-actions "Type=forward,TargetGroupArn=${tg_arn}" \
        --query 'Listeners[0].ListenerArn' \
        --output text)"
    fi
    echo "${listener_arn}"
  }

  NLB_LISTENER_API_ARN="$(create_listener_if_missing "${NLB_ARN}" 8080 "${TG_API_ARN}")"
  NLB_LISTENER_AUTH_ARN="$(create_listener_if_missing "${NLB_ARN}" 8081 "${TG_AUTH_ARN}")"
  NLB_LISTENER_INGEST_ARN="$(create_listener_if_missing "${NLB_ARN}" 8082 "${TG_INGEST_ARN}")"
  NLB_DNS="$(aws elbv2 describe-load-balancers --region "${REGION}" --load-balancer-arns "${NLB_ARN}" --query 'LoadBalancers[0].DNSName' --output text)"
fi

cat > "${STATE_DIR}/ec2.env" <<EOF
REGION=${REGION}
ACCOUNT_ID=${ACCOUNT_ID}
PROJECT_TAG=${PROJECT_TAG}
PRIVATE_NETWORK_MODE=${PRIVATE_NETWORK_MODE}
VPC_ID=${VPC_ID}
VPC_CIDR=${VPC_CIDR:-}
PUBLIC_SUBNET_ID=${PUBLIC_SUBNET_ID:-}
PRIVATE_SUBNET_A_ID=${PRIVATE_SUBNET_A_ID:-}
PRIVATE_SUBNET_B_ID=${PRIVATE_SUBNET_B_ID:-}
EC2_INSTANCE_PROFILE_NAME=${EC2_INSTANCE_PROFILE_NAME}
API_INSTANCE_ID=${API_INSTANCE_ID}
AUTH_INSTANCE_ID=${AUTH_INSTANCE_ID}
INGEST_INSTANCE_ID=${INGEST_INSTANCE_ID}
BASTION_INSTANCE_ID=${BASTION_INSTANCE_ID}
API_PUBLIC_DNS=${API_PUBLIC_DNS}
AUTH_PUBLIC_DNS=${AUTH_PUBLIC_DNS}
INGEST_PUBLIC_DNS=${INGEST_PUBLIC_DNS}
BASTION_PUBLIC_DNS=${BASTION_PUBLIC_DNS}
API_PRIVATE_IP=${API_PRIVATE_IP}
AUTH_PRIVATE_IP=${AUTH_PRIVATE_IP}
INGEST_PRIVATE_IP=${INGEST_PRIVATE_IP}
BASTION_PRIVATE_IP=${BASTION_PRIVATE_IP}
SG_API=${SG_API}
SG_AUTH=${SG_AUTH}
SG_INGEST=${SG_INGEST}
SG_BASTION=${SG_BASTION}
NLB_ARN=${NLB_ARN}
NLB_DNS=${NLB_DNS}
NLB_LISTENER_API_ARN=${NLB_LISTENER_API_ARN}
NLB_LISTENER_AUTH_ARN=${NLB_LISTENER_AUTH_ARN}
NLB_LISTENER_INGEST_ARN=${NLB_LISTENER_INGEST_ARN}
EOF

echo "EC2 topology created."
echo "State file: ${STATE_DIR}/ec2.env"
if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  echo "Bastion public DNS: ${BASTION_PUBLIC_DNS}"
  echo "API private IP: ${API_PRIVATE_IP}"
  echo "AUTH private IP: ${AUTH_PRIVATE_IP}"
  echo "INGEST private IP: ${INGEST_PRIVATE_IP}"
  echo "Internal NLB DNS: ${NLB_DNS}"
else
  echo "API public DNS: ${API_PUBLIC_DNS}"
  echo "AUTH public DNS: ${AUTH_PUBLIC_DNS}"
  echo "INGEST public DNS: ${INGEST_PUBLIC_DNS}"
fi
echo "AMI used: ${AMI_ID}"
