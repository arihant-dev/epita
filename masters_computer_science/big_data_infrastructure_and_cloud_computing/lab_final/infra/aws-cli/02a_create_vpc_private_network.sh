#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-eu-west-3}"
PROJECT_TAG="${PROJECT_TAG:-UrbanMove-FinalLab}"
VPC_CIDR="${VPC_CIDR:-10.42.0.0/16}"
PUBLIC_SUBNET_CIDR="${PUBLIC_SUBNET_CIDR:-10.42.0.0/24}"
PRIVATE_SUBNET_A_CIDR="${PRIVATE_SUBNET_A_CIDR:-10.42.1.0/24}"
PRIVATE_SUBNET_B_CIDR="${PRIVATE_SUBNET_B_CIDR:-10.42.2.0/24}"
STATE_DIR="$(cd "$(dirname "$0")" && pwd)/.state"
STATE_FILE="${STATE_DIR}/network.env"
mkdir -p "${STATE_DIR}"

AZ_A="${AZ_A:-$(aws ec2 describe-availability-zones --region "${REGION}" --filters Name=state,Values=available --query 'AvailabilityZones[0].ZoneName' --output text)}"
AZ_B="${AZ_B:-$(aws ec2 describe-availability-zones --region "${REGION}" --filters Name=state,Values=available --query 'AvailabilityZones[1].ZoneName' --output text)}"
if [[ -z "${AZ_A}" || "${AZ_A}" == "None" || -z "${AZ_B}" || "${AZ_B}" == "None" ]]; then
  echo "Could not resolve 2 availability zones in ${REGION}."
  exit 1
fi

tag_resource() {
  local resource_id="$1"
  local name="$2"
  aws ec2 create-tags \
    --region "${REGION}" \
    --resources "${resource_id}" \
    --tags "Key=Project,Value=${PROJECT_TAG}" "Key=Name,Value=${name}" >/dev/null
}

find_vpc() {
  aws ec2 describe-vpcs \
    --region "${REGION}" \
    --filters "Name=tag:Name,Values=urbanmove-vpc" "Name=tag:Project,Values=${PROJECT_TAG}" \
    --query 'Vpcs[0].VpcId' \
    --output text
}

VPC_ID="$(find_vpc || true)"
if [[ -z "${VPC_ID}" || "${VPC_ID}" == "None" ]]; then
  VPC_ID="$(aws ec2 create-vpc \
    --region "${REGION}" \
    --cidr-block "${VPC_CIDR}" \
    --query 'Vpc.VpcId' \
    --output text)"
  tag_resource "${VPC_ID}" "urbanmove-vpc"
fi

aws ec2 modify-vpc-attribute --region "${REGION}" --vpc-id "${VPC_ID}" --enable-dns-support "{\"Value\":true}" >/dev/null
aws ec2 modify-vpc-attribute --region "${REGION}" --vpc-id "${VPC_ID}" --enable-dns-hostnames "{\"Value\":true}" >/dev/null

find_igw() {
  aws ec2 describe-internet-gateways \
    --region "${REGION}" \
    --filters "Name=attachment.vpc-id,Values=${VPC_ID}" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text
}

IGW_ID="$(find_igw || true)"
if [[ -z "${IGW_ID}" || "${IGW_ID}" == "None" ]]; then
  IGW_ID="$(aws ec2 create-internet-gateway --region "${REGION}" --query 'InternetGateway.InternetGatewayId' --output text)"
  tag_resource "${IGW_ID}" "urbanmove-igw"
  aws ec2 attach-internet-gateway --region "${REGION}" --vpc-id "${VPC_ID}" --internet-gateway-id "${IGW_ID}" >/dev/null
fi

find_subnet_by_name() {
  local name="$1"
  aws ec2 describe-subnets \
    --region "${REGION}" \
    --filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=${name}" \
    --query 'Subnets[0].SubnetId' \
    --output text
}

create_subnet_if_missing() {
  local name="$1"
  local cidr="$2"
  local az="$3"
  local subnet_id
  subnet_id="$(find_subnet_by_name "${name}" || true)"
  if [[ -z "${subnet_id}" || "${subnet_id}" == "None" ]]; then
    subnet_id="$(aws ec2 create-subnet \
      --region "${REGION}" \
      --vpc-id "${VPC_ID}" \
      --cidr-block "${cidr}" \
      --availability-zone "${az}" \
      --query 'Subnet.SubnetId' \
      --output text)"
    tag_resource "${subnet_id}" "${name}"
  fi
  echo "${subnet_id}"
}

PUBLIC_SUBNET_ID="$(create_subnet_if_missing urbanmove-public-subnet "${PUBLIC_SUBNET_CIDR}" "${AZ_A}")"
PRIVATE_SUBNET_A_ID="$(create_subnet_if_missing urbanmove-private-subnet-a "${PRIVATE_SUBNET_A_CIDR}" "${AZ_A}")"
PRIVATE_SUBNET_B_ID="$(create_subnet_if_missing urbanmove-private-subnet-b "${PRIVATE_SUBNET_B_CIDR}" "${AZ_B}")"

aws ec2 modify-subnet-attribute \
  --region "${REGION}" \
  --subnet-id "${PUBLIC_SUBNET_ID}" \
  --map-public-ip-on-launch >/dev/null

find_route_table_by_name() {
  local name="$1"
  aws ec2 describe-route-tables \
    --region "${REGION}" \
    --filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=${name}" \
    --query 'RouteTables[0].RouteTableId' \
    --output text
}

create_route_table_if_missing() {
  local name="$1"
  local rt_id
  rt_id="$(find_route_table_by_name "${name}" || true)"
  if [[ -z "${rt_id}" || "${rt_id}" == "None" ]]; then
    rt_id="$(aws ec2 create-route-table \
      --region "${REGION}" \
      --vpc-id "${VPC_ID}" \
      --query 'RouteTable.RouteTableId' \
      --output text)"
    tag_resource "${rt_id}" "${name}"
  fi
  echo "${rt_id}"
}

PUBLIC_ROUTE_TABLE_ID="$(create_route_table_if_missing urbanmove-public-rt)"
PRIVATE_ROUTE_TABLE_ID="$(create_route_table_if_missing urbanmove-private-rt)"

aws ec2 create-route \
  --region "${REGION}" \
  --route-table-id "${PUBLIC_ROUTE_TABLE_ID}" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "${IGW_ID}" >/dev/null 2>&1 || true

NAT_EIP_ALLOCATION_ID="$(aws ec2 describe-addresses \
  --region "${REGION}" \
  --filters "Name=tag:Name,Values=urbanmove-nat-eip" "Name=tag:Project,Values=${PROJECT_TAG}" \
  --query 'Addresses[0].AllocationId' \
  --output text)"
if [[ -z "${NAT_EIP_ALLOCATION_ID}" || "${NAT_EIP_ALLOCATION_ID}" == "None" ]]; then
  NAT_EIP_ALLOCATION_ID="$(aws ec2 allocate-address --region "${REGION}" --domain vpc --query 'AllocationId' --output text)"
  aws ec2 create-tags \
    --region "${REGION}" \
    --resources "${NAT_EIP_ALLOCATION_ID}" \
    --tags "Key=Project,Value=${PROJECT_TAG}" "Key=Name,Value=urbanmove-nat-eip" >/dev/null
fi

NAT_GW_ID="$(aws ec2 describe-nat-gateways \
  --region "${REGION}" \
  --filter "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=urbanmove-natgw" \
  --query 'NatGateways[?State==`available` || State==`pending`][0].NatGatewayId' \
  --output text)"
if [[ -z "${NAT_GW_ID}" || "${NAT_GW_ID}" == "None" ]]; then
  NAT_GW_ID="$(aws ec2 create-nat-gateway \
    --region "${REGION}" \
    --subnet-id "${PUBLIC_SUBNET_ID}" \
    --allocation-id "${NAT_EIP_ALLOCATION_ID}" \
    --query 'NatGateway.NatGatewayId' \
    --output text)"
  tag_resource "${NAT_GW_ID}" "urbanmove-natgw"
fi

aws ec2 wait nat-gateway-available --region "${REGION}" --nat-gateway-ids "${NAT_GW_ID}"

aws ec2 create-route \
  --region "${REGION}" \
  --route-table-id "${PRIVATE_ROUTE_TABLE_ID}" \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id "${NAT_GW_ID}" >/dev/null 2>&1 || true

associate_subnet_route_table() {
  local subnet_id="$1"
  local route_table_id="$2"
  local assoc_id
  assoc_id="$(aws ec2 describe-route-tables \
    --region "${REGION}" \
    --route-table-ids "${route_table_id}" \
    --query "RouteTables[0].Associations[?SubnetId=='${subnet_id}'].RouteTableAssociationId | [0]" \
    --output text)"
  if [[ -z "${assoc_id}" || "${assoc_id}" == "None" ]]; then
    aws ec2 associate-route-table \
      --region "${REGION}" \
      --subnet-id "${subnet_id}" \
      --route-table-id "${route_table_id}" >/dev/null
  fi
}

associate_subnet_route_table "${PUBLIC_SUBNET_ID}" "${PUBLIC_ROUTE_TABLE_ID}"
associate_subnet_route_table "${PRIVATE_SUBNET_A_ID}" "${PRIVATE_ROUTE_TABLE_ID}"
associate_subnet_route_table "${PRIVATE_SUBNET_B_ID}" "${PRIVATE_ROUTE_TABLE_ID}"

cat > "${STATE_FILE}" <<EOF
REGION=${REGION}
PROJECT_TAG=${PROJECT_TAG}
PRIVATE_NETWORK_MODE=true
VPC_ID=${VPC_ID}
VPC_CIDR=${VPC_CIDR}
IGW_ID=${IGW_ID}
NAT_GW_ID=${NAT_GW_ID}
NAT_EIP_ALLOCATION_ID=${NAT_EIP_ALLOCATION_ID}
PUBLIC_SUBNET_ID=${PUBLIC_SUBNET_ID}
PRIVATE_SUBNET_A_ID=${PRIVATE_SUBNET_A_ID}
PRIVATE_SUBNET_B_ID=${PRIVATE_SUBNET_B_ID}
PUBLIC_ROUTE_TABLE_ID=${PUBLIC_ROUTE_TABLE_ID}
PRIVATE_ROUTE_TABLE_ID=${PRIVATE_ROUTE_TABLE_ID}
AZ_A=${AZ_A}
AZ_B=${AZ_B}
EOF

echo "Private VPC network created/updated."
echo "State file: ${STATE_FILE}"
echo "VPC: ${VPC_ID}"
echo "Public subnet: ${PUBLIC_SUBNET_ID}"
echo "Private subnets: ${PRIVATE_SUBNET_A_ID}, ${PRIVATE_SUBNET_B_ID}"
echo "NAT gateway: ${NAT_GW_ID}"
