#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY="$LAB_DIR/.lab03_ed25519"

echo "== Remote identity and Java =="
ssh \
  -o BatchMode=yes \
  -o StrictHostKeyChecking=accept-new \
  -o IdentitiesOnly=yes \
  -i "$KEY" \
  -p 2225 \
  developer@127.0.0.1 \
  'set -e
   cd /projects/quarkus-extension-proof
   id
   pwd
   echo "JAVA_HOME=$JAVA_HOME"
   java -version 2>&1 | head -n 1
   ./mvnw -version | head -n 4
   echo
   echo "== Test =="
   ./mvnw -B test
   echo
   echo "== Package =="
   ./mvnw -B package -DskipTests'

echo
echo "== Running endpoint =="
response="$(curl -fsS http://127.0.0.1:8085/hello)"
echo "$response"
[[ "$response" == "Hello from Quarkus REST" ]]

echo
echo "Automated verification passed."
echo "VS Code extension, completion, refactor, debug and live-coding checks remain manual by design."
