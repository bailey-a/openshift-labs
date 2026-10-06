#!/usr/bin/env bash
set -euo pipefail

IMAGE="${UDI_IMAGE:-registry.redhat.io/devspaces/udi-rhel9:3.30-1787764814}"

echo "UDI image: $IMAGE"
echo

podman run --rm "$IMAGE" bash -lc '
set -u

echo "== Default Java environment =="
echo "JAVA_HOME=$JAVA_HOME"
java -version 2>&1
javac -version 2>&1
echo

echo "== Maven =="
mvn -version 2>&1 | head -n 5
echo

echo "== Installed JDK directories =="
find /usr/lib/jvm -maxdepth 1 -mindepth 1 -type d -printf "%f\n" 2>/dev/null | sort
echo

echo "== Java executables =="
for j in /usr/lib/jvm/java-*/bin/java; do
  [[ -x "$j" ]] || continue
  echo "-- $j"
  "$j" -version 2>&1 | head -n 1
done
echo

echo "== Quarkus CLI =="
if command -v quarkus >/dev/null 2>&1; then
  command -v quarkus
  quarkus --version || true
else
  echo "not present in PATH"
fi
'
