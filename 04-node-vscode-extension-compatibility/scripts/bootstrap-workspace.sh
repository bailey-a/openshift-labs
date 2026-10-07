#!/usr/bin/env bash
set -euo pipefail

CONTAINER=node-vscode-extension-lab
PROJECT=/projects/node-extension-proof

podman exec --user 10001 "$CONTAINER" bash -lc '
  set -euo pipefail
  cd /projects/node-extension-proof

  echo "== Node runtime =="
  node --version
  npm --version
  echo

  echo "== Install =="
  npm ci
  echo

  echo "== Lint =="
  npm run lint
  echo

  echo "== Format check =="
  npm run format:check
  echo

  echo "== Test =="
  npm test
'

echo "Workspace dependencies resolved and baseline checks passed at $PROJECT"
