#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

podman rm -f quarkus-java-vscode-lab >/dev/null 2>&1 || true
podman volume rm quarkus-java-workspace >/dev/null 2>&1 || true
podman rmi localhost/quarkus-java-vscode-lab:latest >/dev/null 2>&1 || true

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
        skip = "quarkus-java-vscode-lab" in s.split()[1:]
        if skip:
            continue
    if not skip:
        out.append(line)

p.write_text("\n".join(out).rstrip() + "\n" if out else "")
PY

rm -f \
  "$LAB_DIR/.lab03_ed25519" \
  "$LAB_DIR/.lab03_ed25519.pub" \
  "$LAB_DIR/lab_authorized_key.pub"

ssh-keygen -R '[127.0.0.1]:2225' >/dev/null 2>&1 || true

echo "Lab 03 runtime cleaned. Documentation, evidence and app seed retained."
