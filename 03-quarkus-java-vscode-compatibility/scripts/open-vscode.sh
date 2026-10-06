#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY="$LAB_DIR/.lab03_ed25519"
CFG="$HOME/.ssh/config"

mkdir -p "$HOME/.ssh"
touch "$CFG"
chmod 600 "$CFG"

python3 - "$CFG" "$KEY" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); key=sys.argv[2]
lines=p.read_text().splitlines()
out=[]; skip=False
for line in lines:
    s=line.strip()
    if s.lower().startswith("host "):
        skip="quarkus-java-vscode-lab" in s.split()[1:]
        if skip:
            continue
    if not skip:
        out.append(line)
block=f"""Host quarkus-java-vscode-lab
  HostName 127.0.0.1
  Port 2225
  User developer
  IdentityFile {key}
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new"""
text="\n".join(out).rstrip()
p.write_text((text+"\n\n" if text else "")+block+"\n")
PY

code --new-window --remote ssh-remote+quarkus-java-vscode-lab /projects/quarkus-extension-proof
