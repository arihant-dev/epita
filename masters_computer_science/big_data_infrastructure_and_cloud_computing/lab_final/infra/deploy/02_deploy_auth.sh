#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

SERVICE_NAME="urbanmove-auth"
REPO_DIR="${LAB_FINAL_DIR}/repos/${SERVICE_NAME}"
ARCHIVE="${TMP_DIR}/${SERVICE_NAME}.tgz"
JWT_SECRET="${JWT_SECRET:-urbanmove-demo-secret-change-me}"

(
  cd "${REPO_DIR}"
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o "bin/${SERVICE_NAME}" "./cmd/${SERVICE_NAME}"
  tar -czf "${ARCHIVE}" -C bin "${SERVICE_NAME}"
)

scp "${SSH_OPTS[@]}" "${ARCHIVE}" "${SSH_USER}@${AUTH_HOST}:/tmp/${SERVICE_NAME}.tgz"

ssh "${SSH_OPTS[@]}" "${SSH_USER}@${AUTH_HOST}" "JWT_SECRET='${JWT_SECRET}' bash -s" <<'EOF'
set -euo pipefail
SERVICE_NAME="urbanmove-auth"
APP_DIR="/opt/urbanmove/${SERVICE_NAME}"

sudo mkdir -p "${APP_DIR}/bin" /etc/urbanmove
sudo tar -xzf "/tmp/${SERVICE_NAME}.tgz" -C "${APP_DIR}/bin"
sudo chmod +x "${APP_DIR}/bin/${SERVICE_NAME}"

sudo tee "/etc/urbanmove/${SERVICE_NAME}.env" >/dev/null <<ENV
AUTH_GRPC_ADDR=:50051
AUTH_HTTP_ADDR=:8081
JWT_SECRET=${JWT_SECRET}
ENV

sudo tee "/etc/systemd/system/${SERVICE_NAME}.service" >/dev/null <<UNIT
[Unit]
Description=UrbanMove Auth Service
After=network.target

[Service]
Type=simple
User=ubuntu
EnvironmentFile=/etc/urbanmove/${SERVICE_NAME}.env
WorkingDirectory=${APP_DIR}
ExecStart=${APP_DIR}/bin/${SERVICE_NAME}
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable "${SERVICE_NAME}.service"
sudo systemctl restart "${SERVICE_NAME}.service"
sudo systemctl --no-pager --full status "${SERVICE_NAME}.service" | head -n 20
EOF

echo "Auth deployment complete."
