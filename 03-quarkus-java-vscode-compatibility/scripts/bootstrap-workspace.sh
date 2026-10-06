#!/usr/bin/env bash
set -euo pipefail

CONTAINER=quarkus-java-vscode-lab
PROJECT=/projects/quarkus-extension-proof

podman exec --user 10001 "$CONTAINER" bash -lc '
  set -euo pipefail
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
  export PATH="$JAVA_HOME/bin:$PATH"
  cd /projects/quarkus-extension-proof

  echo "== Project JDK =="
  java -version
  echo

  echo "== Maven wrapper =="
  ./mvnw -version | head -n 5
  echo

  echo "== Test =="
  ./mvnw -B test
  echo

  echo "== Package =="
  ./mvnw -B package -DskipTests
'

echo "Workspace dependencies resolved and baseline build passed at $PROJECT"
