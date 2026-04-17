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

echo "Hosts:"
echo "  API   : ${API_HOST}"
echo "  AUTH  : ${AUTH_HOST}"
echo "  INGEST: ${INGEST_HOST}"
