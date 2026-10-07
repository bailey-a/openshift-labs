#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY="$LAB_DIR/.lab04_ed25519"

echo "== Remote identity and Node =="
ssh \
  -o BatchMode=yes \
  -o StrictHostKeyChecking=accept-new \
  -o IdentitiesOnly=yes \
  -i "$KEY" \
  -p 2226 \
  developer@127.0.0.1 \
  'set -e
   cd /projects/node-extension-proof
   id
   pwd
   node --version
   npm --version
   echo
   echo "== Git =="
   git status --short --branch
   git log --oneline -3
   echo
   echo "== Lint =="
   npm run lint
   echo
   echo "== Format =="
   npm run format:check
   echo
   echo "== Test =="
   npm test'

echo
echo "== Running endpoint =="
response="$(curl -fsS http://127.0.0.1:3006/hello)"
echo "$response"
[[ "$response" == "Hello from Node REST" ]]

echo
echo "Automated verification passed."
echo "VS Code extension activation/completion/debug/UI checks remain manual by design."
