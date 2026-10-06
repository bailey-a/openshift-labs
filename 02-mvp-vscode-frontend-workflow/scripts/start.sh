#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

podman rm -f mvp-vscode-frontend-lab >/dev/null 2>&1 || true
podman volume rm mvp-vscode-workspace >/dev/null 2>&1 || true
podman volume create mvp-vscode-workspace >/dev/null

podman run -d   --name mvp-vscode-frontend-lab   -p 127.0.0.1:2224:2224   -p 127.0.0.1:3004:3000   -v mvp-vscode-workspace:/projects   localhost/mvp-vscode-frontend-lab:latest >/dev/null

podman exec --user 0 mvp-vscode-frontend-lab   bash -lc 'chown -R 10001:0 /projects'

podman cp "$LAB_DIR/app" mvp-vscode-frontend-lab:/tmp/app-seed
podman exec --user 0 mvp-vscode-frontend-lab   bash -lc 'chown -R 10001:0 /tmp/app-seed'

podman exec --user 10001 mvp-vscode-frontend-lab bash -lc '
  set -e
  rm -rf /projects/seed /projects/_origin.git /projects/mvp-frontend
  cp -a /tmp/app-seed /projects/seed
  cd /projects/seed
  git init -b main >/dev/null
  git config user.name "Lab Developer"
  git config user.email "lab-developer@example.invalid"
  git add -A
  git commit -m "chore: initialise synthetic frontend lab" >/dev/null
  git clone --bare . /projects/_origin.git >/dev/null
  git clone /projects/_origin.git /projects/mvp-frontend >/dev/null
  cd /projects/mvp-frontend
  git config user.name "Lab Developer"
  git config user.email "lab-developer@example.invalid"
'

podman ps --filter name=mvp-vscode-frontend-lab   --format '{{.Names}} | {{.Status}} | {{.Ports}}'
