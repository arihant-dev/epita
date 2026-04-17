#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-eu-west-3}"
PROJECT_TAG="${PROJECT_TAG:-UrbanMove-FinalLab}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.micro}"
KEY_NAME="${KEY_NAME:-}"
AMI_ID="${AMI_ID:-}"
ADMIN_CIDR="${ADMIN_CIDR:-}"
STATE_DIR="$(cd "$(dirname "$0")" && pwd)/.state"
mkdir -p "${STATE_DIR}"

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
VPC_ID="$(aws ec2 describe-vpcs --region "${REGION}" --filters Name=isDefault,Values=true --query 'Vpcs[0].VpcId' --output text)"
SUBNET_ID="$(aws ec2 describe-subnets --region "${REGION}" --filters Name=vpc-id,Values="${VPC_ID}" Name=default-for-az,Values=true --query 'Subnets[0].SubnetId' --output text)"

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

# SSH access from your current IP.
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_API}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"IpRanges\":[{\"CidrIp\":\"${ADMIN_CIDR}\"}]}]" >/dev/null 2>&1 || true
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_AUTH}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"IpRanges\":[{\"CidrIp\":\"${ADMIN_CIDR}\"}]}]" >/dev/null 2>&1 || true
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"IpRanges\":[{\"CidrIp\":\"${ADMIN_CIDR}\"}]}]" >/dev/null 2>&1 || true

# Public API entry and CloudFront origin access (for demo simplicity).
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_API}" --ip-permissions '[{"IpProtocol":"tcp","FromPort":8080,"ToPort":8080,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' >/dev/null 2>&1 || true

# Internal RPC: API -> AUTH/INGEST.
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_AUTH}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":50051,\"ToPort\":50051,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_API}\"}]}]" >/dev/null 2>&1 || true
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":50052,\"ToPort\":50052,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_API}\"}]}]" >/dev/null 2>&1 || true

# Ingest host local stack ports (NATS/Postgres only from itself).
aws ec2 authorize-security-group-ingress --region "${REGION}" --group-id "${SG_INGEST}" --ip-permissions "[{\"IpProtocol\":\"tcp\",\"FromPort\":4222,\"ToPort\":4222,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_INGEST}\"}]},{\"IpProtocol\":\"tcp\",\"FromPort\":5432,\"ToPort\":5432,\"UserIdGroupPairs\":[{\"GroupId\":\"${SG_INGEST}\"}]}]" >/dev/null 2>&1 || true

create_instance() {
  local name="$1"
  local sg_id="$2"
  aws ec2 run-instances \
    --region "${REGION}" \
    --image-id "${AMI_ID}" \
    --instance-type "${INSTANCE_TYPE}" \
    --key-name "${KEY_NAME}" \
    --subnet-id "${SUBNET_ID}" \
    --security-group-ids "${sg_id}" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${name}},{Key=Project,Value=${PROJECT_TAG}}]" \
    --query 'Instances[0].InstanceId' \
    --output text
}

API_INSTANCE_ID="$(create_instance urbanmove-api-ec2 "${SG_API}")"
AUTH_INSTANCE_ID="$(create_instance urbanmove-auth-ec2 "${SG_AUTH}")"
INGEST_INSTANCE_ID="$(create_instance urbanmove-ingest-ec2 "${SG_INGEST}")"

aws ec2 wait instance-running --region "${REGION}" --instance-ids "${API_INSTANCE_ID}" "${AUTH_INSTANCE_ID}" "${INGEST_INSTANCE_ID}"

API_PUBLIC_DNS="$(aws ec2 describe-instances --region "${REGION}" --instance-ids "${API_INSTANCE_ID}" --query 'Reservations[0].Instances[0].PublicDnsName' --output text)"
AUTH_PRIVATE_IP="$(aws ec2 describe-instances --region "${REGION}" --instance-ids "${AUTH_INSTANCE_ID}" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)"
INGEST_PRIVATE_IP="$(aws ec2 describe-instances --region "${REGION}" --instance-ids "${INGEST_INSTANCE_ID}" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)"

cat > "${STATE_DIR}/ec2.env" <<EOF
REGION=${REGION}
ACCOUNT_ID=${ACCOUNT_ID}
PROJECT_TAG=${PROJECT_TAG}
API_INSTANCE_ID=${API_INSTANCE_ID}
AUTH_INSTANCE_ID=${AUTH_INSTANCE_ID}
INGEST_INSTANCE_ID=${INGEST_INSTANCE_ID}
API_PUBLIC_DNS=${API_PUBLIC_DNS}
AUTH_PRIVATE_IP=${AUTH_PRIVATE_IP}
INGEST_PRIVATE_IP=${INGEST_PRIVATE_IP}
SG_API=${SG_API}
SG_AUTH=${SG_AUTH}
SG_INGEST=${SG_INGEST}
EOF

echo "EC2 topology created."
echo "State file: ${STATE_DIR}/ec2.env"
echo "API public DNS: ${API_PUBLIC_DNS}"
echo "AMI used: ${AMI_ID}"
