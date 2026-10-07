#!/usr/bin/env bash
set -euo pipefail

CONTAINER=node-vscode-extension-lab
PROJECT=/projects/node-extension-proof

podman exec --user 10001 "$CONTAINER" sh -c "pkill -f '[n]ode --watch --inspect=0.0.0.0:9229 src/server.js' || true"

podman exec --user 10001 "$CONTAINER" sh -c \
  "cd $PROJECT && nohup npm run dev >/tmp/lab04-node.log 2>&1 </dev/null &"

for _ in {1..60}; do
  if curl -fsS http://127.0.0.1:3006/hello >/dev/null 2>&1; then
    echo "Node dev server ready: http://127.0.0.1:3006/hello"
    echo "Remote VS Code debugger target: localhost:9229 inside the workspace"
    exit 0
  fi
  sleep 0.5
done

podman exec "$CONTAINER" sh -c 'tail -n 120 /tmp/lab04-node.log || true'
exit 1
