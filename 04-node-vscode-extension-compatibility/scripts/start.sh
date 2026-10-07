#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTAINER=node-vscode-extension-lab
VOLUME=node-vscode-extension-workspace

podman rm -f "$CONTAINER" >/dev/null 2>&1 || true
podman volume rm "$VOLUME" >/dev/null 2>&1 || true
podman volume create "$VOLUME" >/dev/null

podman run -d \
  --name "$CONTAINER" \
  -p 127.0.0.1:2226:2226 \
  -p 127.0.0.1:3006:3000 \
  -v "$VOLUME":/projects \
  localhost/node-vscode-extension-lab:latest >/dev/null

podman exec --user 0 "$CONTAINER" bash -lc 'chown -R 10001:0 /projects'

podman cp "$LAB_DIR/app" "$CONTAINER":/tmp/app-seed
podman exec --user 0 "$CONTAINER" bash -lc '
  rm -rf /projects/node-extension-proof
  cp -a /tmp/app-seed /projects/node-extension-proof
  chown -R 10001:0 /projects/node-extension-proof
'

podman exec --user 10001 "$CONTAINER" bash -lc '
  cd /projects/node-extension-proof
  git init -b main >/dev/null
  git config user.name "Lab User"
  git config user.email "lab@example.invalid"
  git add .
  git commit -m "chore: seed node extension compatibility lab" >/dev/null
'

podman ps --filter name="$CONTAINER" \
  --format '{{.Names}} | {{.Status}} | {{.Ports}}'

echo "Workspace seeded at /projects/node-extension-proof"
