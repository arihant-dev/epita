#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ -n "${CLOUDFRONT_DOMAIN:-}" ]]; then
  BASE_URL="https://${CLOUDFRONT_DOMAIN}"
elif [[ -n "${API_GW_ENDPOINT:-}" ]]; then
  BASE_URL="${API_GW_ENDPOINT}"
elif [[ -z "${CLOUDFRONT_DOMAIN:-}" ]]; then
  BASE_URL="http://${API_HOST}:8080"
fi

echo "Using BASE_URL=${BASE_URL}"

LOGIN_JSON="$(curl -fsS -X POST "${BASE_URL}/api/v1/auth/login" \
  -H 'Content-Type: application/json' \
  -d '{"username":"operator1","password":"operator123"}')"

echo "Login response:"
echo "${LOGIN_JSON}"

TOKEN="$(echo "${LOGIN_JSON}" | awk -F'"' '/access_token/{print $4}')"
if [[ -z "${TOKEN}" ]]; then
  echo "Failed to parse token from login response."
  exit 1
fi

echo
echo "Congestion summary:"
curl -fsS "${BASE_URL}/api/v1/congestion?limit=3" -H "Authorization: Bearer ${TOKEN}"

echo
echo "Route recommendation:"
curl -fsS "${BASE_URL}/api/v1/routes/recommendation?origin=Station-A&destination=Station-B" \
  -H "Authorization: Bearer ${TOKEN}"
echo
