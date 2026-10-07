#!/usr/bin/env bash
set -euo pipefail

IMAGE="${UDI_IMAGE:-registry.redhat.io/devspaces/udi-rhel9:3.30-1787764814}"

echo "UDI image: $IMAGE"
echo

podman run --rm "$IMAGE" bash -lc '
set -u

echo "== Node =="
command -v node
node --version
echo

echo "== npm =="
command -v npm
npm --version
echo

echo "== Corepack =="
if command -v corepack >/dev/null 2>&1; then
  command -v corepack
  corepack --version
else
  echo "not present in PATH"
fi
echo

echo "== Git and curl =="
git --version
curl --version | head -n 1
'
