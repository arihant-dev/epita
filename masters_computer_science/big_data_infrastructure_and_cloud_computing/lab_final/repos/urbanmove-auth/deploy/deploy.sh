#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="urbanmove-auth"
APP_DIR="/opt/urbanmove/${SERVICE_NAME}"

sudo mkdir -p "${APP_DIR}/bin"
sudo tar -xzf "/tmp/${SERVICE_NAME}.tgz" -C "${APP_DIR}/bin"
sudo systemctl restart "${SERVICE_NAME}.service"
sudo systemctl status "${SERVICE_NAME}.service" --no-pager
