#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY="$LAB_DIR/.lab04_ed25519"
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
        skip="node-vscode-extension-lab" in s.split()[1:]
        if skip:
            continue
    if not skip:
        out.append(line)
block=f"""Host node-vscode-extension-lab
  HostName 127.0.0.1
  Port 2226
  User developer
  IdentityFile {key}
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new"""
text="\n".join(out).rstrip()
p.write_text((text+"\n\n" if text else "")+block+"\n")
PY

# When launched from a normal desktop terminal these are already present.
# Remote automation shells can be headless, so recover the active desktop
# session values from Xwayland when needed.
if [[ -z "${DISPLAY:-}" ]]; then
  xwayland_args="$(ps -u "$USER" -o args= | grep -m1 '[X]wayland :' || true)"
  if [[ -n "$xwayland_args" ]]; then
    export DISPLAY="$(printf '%s\n' "$xwayland_args" | sed -n 's/.*Xwayland \(:[0-9][0-9]*\).*/\1/p')"
    export XAUTHORITY="$(printf '%s\n' "$xwayland_args" | sed -n 's/.* -auth \([^ ]*\).*/\1/p')"
  fi
fi

if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" && -S "$XDG_RUNTIME_DIR/bus" ]]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
fi

if [[ -z "${WAYLAND_DISPLAY:-}" && -S "$XDG_RUNTIME_DIR/wayland-0" ]]; then
  export WAYLAND_DISPLAY="wayland-0"
fi

# Some nested or remote shell sessions export VSCODE_IPC_HOOK_CLI,
# which makes the code wrapper route to a remote CLI instead of opening the
# desktop application. Clear it so this script consistently launches the GUI.
unset VSCODE_IPC_HOOK_CLI

code --new-window --remote ssh-remote+node-vscode-extension-lab /projects/node-extension-proof
