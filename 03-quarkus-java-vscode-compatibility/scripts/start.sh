#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTAINER=quarkus-java-vscode-lab
VOLUME=quarkus-java-workspace

podman rm -f "$CONTAINER" >/dev/null 2>&1 || true
podman volume rm "$VOLUME" >/dev/null 2>&1 || true
podman volume create "$VOLUME" >/dev/null

podman run -d \
  --name "$CONTAINER" \
  -p 127.0.0.1:2225:2225 \
  -p 127.0.0.1:8085:8080 \
  -v "$VOLUME":/projects \
  localhost/quarkus-java-vscode-lab:latest >/dev/null

podman exec --user 0 "$CONTAINER" \
  bash -lc 'chown -R 10001:0 /projects'

podman cp "$LAB_DIR/app" "$CONTAINER":/tmp/app-seed
podman exec --user 0 "$CONTAINER" \
  bash -lc 'rm -rf /projects/quarkus-extension-proof && cp -a /tmp/app-seed /projects/quarkus-extension-proof && chown -R 10001:0 /projects/quarkus-extension-proof'

podman ps --filter name="$CONTAINER" \
  --format '{{.Names}} | {{.Status}} | {{.Ports}}'

echo "Workspace seeded at /projects/quarkus-extension-proof"
