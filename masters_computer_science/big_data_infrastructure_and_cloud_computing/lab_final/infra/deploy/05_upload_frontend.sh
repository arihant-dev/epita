#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ -z "${UI_BUCKET:-}" ]]; then
  echo "UI_BUCKET is missing in ${STATE_FILE}."
  echo "Run infra/aws-cli/03_s3_cloudfront_setup.sh first."
  exit 1
fi

FRONTEND_DIR="${LAB_FINAL_DIR}/frontend/static"
if [[ ! -d "${FRONTEND_DIR}" ]]; then
  echo "Frontend directory not found: ${FRONTEND_DIR}"
  exit 1
fi

aws s3 sync "${FRONTEND_DIR}/" "s3://${UI_BUCKET}/" --delete --region "${REGION}"

if [[ -n "${CLOUDFRONT_DISTRIBUTION_ID:-}" ]]; then
  aws cloudfront create-invalidation \
    --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
    --paths "/*" >/dev/null
fi

echo "Frontend uploaded to s3://${UI_BUCKET}"
if [[ -n "${CLOUDFRONT_DOMAIN:-}" ]]; then
  echo "Open: https://${CLOUDFRONT_DOMAIN}"
fi
