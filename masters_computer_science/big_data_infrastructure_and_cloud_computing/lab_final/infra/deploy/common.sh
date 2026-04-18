#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_FINAL_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
STATE_FILE="${LAB_FINAL_DIR}/infra/aws-cli/.state/ec2.env"
TMP_DIR="${SCRIPT_DIR}/.tmp"
mkdir -p "${TMP_DIR}"

if [[ ! -f "${STATE_FILE}" ]]; then
  echo "Missing state file: ${STATE_FILE}"
  echo "Run AWS provisioning scripts first."
  exit 1
fi

# shellcheck source=/dev/null
source "${STATE_FILE}"

REGION="${REGION:-eu-west-3}"
SSH_USER="${SSH_USER:-ubuntu}"
KEY_PATH="${KEY_PATH:-$HOME/.ssh/aws_ec2_key.pem}"
SSH_OPTS=(-i "${KEY_PATH}" -o StrictHostKeyChecking=accept-new)
PRIVATE_NETWORK_MODE="${PRIVATE_NETWORK_MODE:-false}"

if [[ ! -f "${KEY_PATH}" ]]; then
  echo "Key file not found at ${KEY_PATH}"
  echo "Set KEY_PATH=/path/to/key.pem and rerun."
  exit 1
fi

resolve_public_dns() {
  local instance_id="$1"
  aws ec2 describe-instances \
    --region "${REGION}" \
    --instance-ids "${instance_id}" \
    --query 'Reservations[0].Instances[0].PublicDnsName' \
    --output text
}

API_HOST="$(resolve_public_dns "${API_INSTANCE_ID}")"
AUTH_HOST="$(resolve_public_dns "${AUTH_INSTANCE_ID}")"
INGEST_HOST="$(resolve_public_dns "${INGEST_INSTANCE_ID}")"

if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  if [[ -z "${BASTION_PUBLIC_DNS:-}" || "${BASTION_PUBLIC_DNS}" == "None" ]]; then
    if [[ -n "${BASTION_INSTANCE_ID:-}" ]]; then
      BASTION_PUBLIC_DNS="$(resolve_public_dns "${BASTION_INSTANCE_ID}")"
    fi
  fi
  if [[ -z "${BASTION_PUBLIC_DNS:-}" || "${BASTION_PUBLIC_DNS}" == "None" ]]; then
    echo "PRIVATE_NETWORK_MODE=true but BASTION_PUBLIC_DNS is missing."
    echo "Re-run infra/aws-cli/02_create_ec2_topology.sh."
    exit 1
  fi
  if [[ -z "${API_PRIVATE_IP:-}" || -z "${AUTH_PRIVATE_IP:-}" || -z "${INGEST_PRIVATE_IP:-}" ]]; then
    echo "PRIVATE_NETWORK_MODE=true requires API/AUTH/INGEST private IPs in state file."
    exit 1
  fi
  SSH_OPTS+=(-o "ProxyCommand=ssh -i ${KEY_PATH} -o StrictHostKeyChecking=accept-new -W %h:%p ${SSH_USER}@${BASTION_PUBLIC_DNS}")
  API_HOST="${API_PRIVATE_IP}"
  AUTH_HOST="${AUTH_PRIVATE_IP}"
  INGEST_HOST="${INGEST_PRIVATE_IP}"
fi

echo "Hosts:"
echo "  API   : ${API_HOST}"
echo "  AUTH  : ${AUTH_HOST}"
echo "  INGEST: ${INGEST_HOST}"
if [[ "${PRIVATE_NETWORK_MODE}" == "true" ]]; then
  echo "  BASTION: ${BASTION_PUBLIC_DNS}"
fi
