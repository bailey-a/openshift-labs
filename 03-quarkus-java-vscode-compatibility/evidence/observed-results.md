# Lab 03 observed results

Captured: 2026-10-06

## UDI baseline

Image:

`registry.redhat.io/devspaces/udi-rhel9:3.30-1787764814`

Observed default environment:

- UDI startup selects Java 17.
- `JAVA_HOME=/home/user/.java/current`
- `java -version`: OpenJDK 17.0.20.1 (Red Hat)
- `javac -version`: 17.0.20.1
- Maven: 3.9.9 (Red Hat)
- Maven runs with Java 17.0.20.1.
- Quarkus CLI is not present in PATH.

Observed JDK families under `/usr/lib/jvm`:

- Java 8: 1.8.0_504
- Java 11: 11.0.25
- Java 17: 17.0.20.1
- Java 21: 21.0.12.1

## First useful conclusion

The tested UDI is not limited to one JDK. It contains Java 8, 11, 17 and 21, while Java 17 is the default.

Therefore a report that "the Java version will not run Quarkus" must be split into at least:

1. Which JDK is running the VS Code Java language server?
2. Which JDK is selected for Maven/Gradle and the project?
3. Which Java level does the specific Quarkus project require?
4. Which exact Quarkus / extension versions are being tested?

At this baseline stage no Quarkus compatibility conclusion was made. The controlled Quarkus fixture and completed VS Code validation below provide the final lab conclusion.

## Phase 2 - Controlled Quarkus fixture

Fixture generated from inside the UDI using the upstream Quarkus Maven plugin:

- Quarkus platform: 3.40.1
- Project: `org.acme:quarkus-extension-proof`
- Extension: `rest`
- Maven compiler release: 17
- Generated Maven wrapper: Maven 3.9.16
- System Maven present in UDI: Maven 3.9.9

Observed results:

- Project generation succeeded.
- `./mvnw test` succeeded.
- Test result: 1 test, 0 failures, 0 errors, 0 skipped.
- Compile output explicitly used `release 17`.
- `./mvnw package -DskipTests` succeeded.
- Packaged JVM application started successfully under Java 17.
- Host request through the lab port mapping returned:
  `Hello from Quarkus REST`
- Quarkus dev mode started successfully under Java 17.
- Dev mode reported `Live Coding activated`.
- Quarkus opened its debug listener on port 5005.
- Live reload was verified by changing the endpoint response to:
  `Hello from Quarkus LIVE`
  and observing that response without restarting the application.
- Restoring the source changed the live endpoint back to:
  `Hello from Quarkus REST`

## Phase 3 - editor/runtime split verified

The remote VS Code Java language server was observed running on Java 21 while the Quarkus Maven/dev process ran on Java 17.

This validates the intended separation:

- Java language server runtime: Java 21
- Project/build runtime: Java 17

## Phase 4 - VS Code extension experience verified

Exact remote extension versions observed under the remote VS Code server:

- `redhat.java-1.56.0-linux-x64`
- `vscjava.vscode-java-pack-0.31.1`
- `redhat.vscode-quarkus-1.24.0`
- `redhat.vscode-microprofile-0.18.0`

Manual VS Code validation completed successfully:

- Java project imported without Problems-panel errors.
- Java/Jakarta types resolved.
- Code completion worked, including `MediaType.` completion.
- Navigation/refactor actions worked.
- `./mvnw test` and `./mvnw package -DskipTests` worked from the remote VS Code terminal after restoring the UDI Java environment to the SSH stand-in shell.
- Quarkus dev mode ran successfully.
- Live coding worked after editing and saving `GreetingResource.java`.
- VS Code attached to the running Quarkus JVM debugger on port 5005 and breakpoint debugging worked.
- Quarkus configuration completion worked in `application.properties` with `quarkus.` + completion.
- Quarkus and MicroProfile extensions were present in the remote VS Code server.

## Final findings matrix

| Lab capability | Result | Notes |
| --- | --- | --- |
| Compile | PASS | Java 17 project target |
| Build/package | PASS | Maven wrapper 3.9.16 |
| Debug | PASS | VS Code attach to Quarkus dev JVM |
| Refactor/navigation | PASS | Exercised in remote editor |
| Code completion | PASS | Java/Jakarta completion verified |
| Quarkus live coding | PASS | Endpoint changed without manual restart |
| Java tooling/runtime split | PASS | Java LS on 21; project on 17 |
| Quarkus extension | PASS | 1.24.0 installed remotely; config completion verified |
| MicroProfile extension | PASS (presence/activation) | 0.18.0 installed remotely; no separate MicroProfile-specific application feature was required for this lab |
| Real Dev Spaces control plane | NOT TESTED | Outside local lab boundary |
| Managed extension/dependency distribution | NOT TESTED | Local/public sources used for proof only |

## Boundary note

The Quarkus dependencies in this local proof were downloaded from public upstream repositories. This validates application/tool compatibility only. It does not prove a managed dependency/extension distribution path or real Dev Spaces configuration.


## Reproducibility pass

After restructuring Lab 03 to match the Lab 02 pattern, the lab was rerun from a clean local runtime on 2026-10-06:

```text
cleanup
build
start
bootstrap-workspace
run-app
verify
verify-live-reload
```

All automated steps completed successfully. The reproducible `app/` seed, lifecycle scripts and README now recreate the same Quarkus proof without relying on the original workspace volume.
