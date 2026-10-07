#!/usr/bin/env bash
set -euo pipefail

CONTAINER=node-vscode-extension-lab
SRC=/projects/node-extension-proof/src/server.js

before="$(curl -fsS http://127.0.0.1:3006/hello)"
echo "Before: $before"
[[ "$before" == "Hello from Node REST" ]]

podman exec --user 10001 "$CONTAINER" sh -c \
  "sed -i 's/const responseMode = \"REST\";/const responseMode = \"LIVE\";/' $SRC"

for _ in {1..40}; do
  after="$(curl -fsS http://127.0.0.1:3006/hello 2>/dev/null || true)"
  [[ "$after" == "Hello from Node LIVE" ]] && break
  sleep 0.25
done

echo "After edit: $after"
[[ "$after" == "Hello from Node LIVE" ]]

sleep 1

podman exec --user 10001 "$CONTAINER" sh -c \
  "sed -i 's/const responseMode = \"LIVE\";/const responseMode = \"REST\";/' $SRC"

for _ in {1..40}; do
  restored="$(curl -fsS http://127.0.0.1:3006/hello 2>/dev/null || true)"
  [[ "$restored" == "Hello from Node REST" ]] && break
  sleep 0.25
done

echo "Restored: $restored"
[[ "$restored" == "Hello from Node REST" ]]
