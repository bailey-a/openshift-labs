#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

podman rm -f node-vscode-extension-lab >/dev/null 2>&1 || true
podman volume rm node-vscode-extension-workspace >/dev/null 2>&1 || true
podman rmi localhost/node-vscode-extension-lab:latest >/dev/null 2>&1 || true

python3 - "$HOME/.ssh/config" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
if not p.exists():
    raise SystemExit

lines = p.read_text().splitlines()
out = []
skip = False

for line in lines:
    s = line.strip()
    if s.lower().startswith("host "):
        skip = "node-vscode-extension-lab" in s.split()[1:]
        if skip:
            continue
    if not skip:
        out.append(line)

p.write_text("\n".join(out).rstrip() + "\n" if out else "")
PY

rm -f \
  "$LAB_DIR/.lab04_ed25519" \
  "$LAB_DIR/.lab04_ed25519.pub" \
  "$LAB_DIR/lab_authorized_key.pub"

ssh-keygen -R '[127.0.0.1]:2226' >/dev/null 2>&1 || true

echo "Lab 04 runtime cleaned. Documentation, evidence and app seed retained."
