#!/usr/bin/env bash
set -euo pipefail

CONTAINER=quarkus-java-vscode-lab
SRC=/projects/quarkus-extension-proof/src/main/java/org/acme/GreetingResource.java

before="$(curl -fsS http://127.0.0.1:8085/hello)"
echo "Before: $before"

podman exec --user 10001 "$CONTAINER" sh -c   "cp $SRC /tmp/GreetingResource.java.lab03 && sed -i 's/Hello from Quarkus REST/Hello from Quarkus LIVE/' $SRC"

for _ in {1..30}; do
  after="$(curl -fsS http://127.0.0.1:8085/hello 2>/dev/null || true)"
  [[ "$after" == "Hello from Quarkus LIVE" ]] && break
  sleep 0.5
done

echo "After edit: $after"
[[ "$after" == "Hello from Quarkus LIVE" ]]

podman exec --user 10001 "$CONTAINER" sh -c "cp /tmp/GreetingResource.java.lab03 $SRC"

for _ in {1..30}; do
  restored="$(curl -fsS http://127.0.0.1:8085/hello 2>/dev/null || true)"
  [[ "$restored" == "Hello from Quarkus REST" ]] && break
  sleep 0.5
done

echo "Restored: $restored"
[[ "$restored" == "Hello from Quarkus REST" ]]
