#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

bootstrap_base() {
  local host="$1"
  ssh "${SSH_OPTS[@]}" "${SSH_USER}@${host}" <<'EOF'
set -euo pipefail
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl jq unzip
sudo mkdir -p /opt/urbanmove /etc/urbanmove
EOF
}

bootstrap_base "${API_HOST}"
bootstrap_base "${AUTH_HOST}"
bootstrap_base "${INGEST_HOST}"

ssh "${SSH_OPTS[@]}" "${SSH_USER}@${INGEST_HOST}" <<'EOF'
set -euo pipefail
sudo apt-get update -y
if ! sudo apt-get install -y docker.io docker-compose-plugin; then
  sudo apt-get install -y docker.io docker-compose
fi
sudo systemctl enable docker
sudo systemctl start docker
sudo mkdir -p /opt/urbanmove/infra
EOF

echo "Bootstrap complete on all 3 hosts."
