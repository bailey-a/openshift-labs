#!/usr/bin/env bash
set -euo pipefail

CONTAINER=quarkus-java-vscode-lab
PROJECT=/projects/quarkus-extension-proof

podman exec --user 10001 "$CONTAINER" sh -c "pkill -f '[q]uarkus-extension-proof-dev.jar' || true"
podman exec --user 10001 "$CONTAINER" sh -c "pkill -f '[L]auncher quarkus:dev' || true"

podman exec --user 10001 "$CONTAINER" sh -c \
  "cd $PROJECT && JAVA_HOME=/usr/lib/jvm/java-17-openjdk PATH=/usr/lib/jvm/java-17-openjdk/bin:\$PATH nohup ./mvnw quarkus:dev -Dquarkus.http.host=0.0.0.0 -Dquarkus.analytics.disabled=true >/tmp/lab03-dev.log 2>&1 </dev/null &"

for _ in {1..120}; do
  if curl -fsS http://127.0.0.1:8085/hello >/dev/null 2>&1; then
    echo "Quarkus dev mode ready: http://127.0.0.1:8085/hello"
    echo "Remote VS Code debugger target: localhost:5005 inside the workspace"
    exit 0
  fi
  sleep 0.5
done

podman exec "$CONTAINER" sh -c 'tail -n 120 /tmp/lab03-dev.log || true'
exit 1
