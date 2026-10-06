#!/usr/bin/env bash
set -euo pipefail

podman exec mvp-vscode-frontend-lab bash -lc '
  pkill -f "rspack serve" >/dev/null 2>&1 || true
' || true

podman exec -d --user 10001 mvp-vscode-frontend-lab bash -lc '
  export HOME=/home/user
  export NVM_DIR="$HOME/.nvm"
  . "$NVM_DIR/nvm.sh"
  cd /projects/mvp-frontend
  nvm use >/dev/null
  exec pnpm dev >/tmp/mvp-vscode-frontend.log 2>&1
'

sleep 3
echo "Fallback host URL: http://127.0.0.1:3004"
curl -fsS http://127.0.0.1:3004/ >/dev/null
echo "App responded successfully."
