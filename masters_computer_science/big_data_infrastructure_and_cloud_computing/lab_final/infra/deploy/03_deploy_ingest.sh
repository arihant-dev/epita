#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

SERVICE_NAME="urbanmove-ingestion-routing"
REPO_DIR="${LAB_FINAL_DIR}/repos/${SERVICE_NAME}"
ARCHIVE="${TMP_DIR}/${SERVICE_NAME}.tgz"
COMPOSE_FILE="${REPO_DIR}/deploy/docker-compose.infra.yml"

(
  cd "${REPO_DIR}"
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o "bin/${SERVICE_NAME}" "./cmd/${SERVICE_NAME}"
  tar -czf "${ARCHIVE}" -C bin "${SERVICE_NAME}"
)

scp "${SSH_OPTS[@]}" "${ARCHIVE}" "${SSH_USER}@${INGEST_HOST}:/tmp/${SERVICE_NAME}.tgz"
scp "${SSH_OPTS[@]}" "${COMPOSE_FILE}" "${SSH_USER}@${INGEST_HOST}:/tmp/docker-compose.infra.yml"

ssh "${SSH_OPTS[@]}" "${SSH_USER}@${INGEST_HOST}" "bash -s" <<'EOF'
set -euo pipefail
SERVICE_NAME="urbanmove-ingestion-routing"
APP_DIR="/opt/urbanmove/${SERVICE_NAME}"
INFRA_DIR="/opt/urbanmove/infra"

sudo mkdir -p "${APP_DIR}/bin" "${INFRA_DIR}" /etc/urbanmove
sudo tar -xzf "/tmp/${SERVICE_NAME}.tgz" -C "${APP_DIR}/bin"
sudo chmod +x "${APP_DIR}/bin/${SERVICE_NAME}"
sudo cp /tmp/docker-compose.infra.yml "${INFRA_DIR}/docker-compose.yml"

cd "${INFRA_DIR}"
if sudo docker compose version >/dev/null 2>&1; then
  sudo docker compose up -d
else
  sudo docker-compose up -d
fi

sudo tee "/etc/urbanmove/${SERVICE_NAME}.env" >/dev/null <<ENV
MOBILITY_GRPC_ADDR=:50052
MOBILITY_HTTP_ADDR=:8082
NATS_URL=nats://localhost:4222
DATABASE_URL=postgres://urbanmove:urbanmove@localhost:5432/urbanmove?sslmode=disable
SIMULATOR_ENABLED=true
SIMULATOR_INTERVAL_SECONDS=5
ENV

sudo tee "/etc/systemd/system/${SERVICE_NAME}.service" >/dev/null <<UNIT
[Unit]
Description=UrbanMove Ingestion Routing Service
After=network.target docker.service
Requires=docker.service

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

echo "Ingestion deployment complete."
