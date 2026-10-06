#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY="$LAB_DIR/.mvp_lab_ed25519"

if [[ ! -f "$KEY" ]]; then
  ssh-keygen -t ed25519 -N '' -C mvp-vscode-frontend-lab -f "$KEY" >/dev/null
fi

cp "$KEY.pub" "$LAB_DIR/lab_authorized_key.pub"

podman build   -t localhost/mvp-vscode-frontend-lab:latest   "$LAB_DIR"

echo "Built localhost/mvp-vscode-frontend-lab:latest"
