# Lab 03 - Quarkus / Java / VS Code compatibility

Status: complete - Quarkus developer workflow verified locally
Started: 2026-10-06  
Completed: 2026-10-06

## Question this lab answers

Can a useful Quarkus developer workflow run inside the tested Red Hat Dev Spaces UDI with build, debug, code completion, refactoring, live coding, and remote VS Code support?

The activities under test are:

```text
compile
build
debug
refactor
code completion
Quarkus live coding
```

This lab validates the following primary Quarkus-side VS Code extensions:

```text
vscjava.vscode-java-pack
redhat.vscode-quarkus
redhat.vscode-microprofile
```

This lab recreates that developer experience locally without claiming that Podman + SSH is a real Dev Spaces control plane.

## Quick stand-up overview

```text
Developer Laptop
|
+-- Local VS Code
|   `-- Remote SSH connection
|
`-- Red Hat Dev Spaces UDI (RHEL 9)
    +-- UID 10001 developer
    +-- /projects/quarkus-extension-proof
    +-- VS Code Server
    |
    +-- Editor tooling
    |   +-- Java language server -> Java 21
    |   +-- Extension Pack for Java
    |   +-- Quarkus extension
    |   `-- MicroProfile extension
    |
    +-- Quarkus application
    |   +-- Quarkus 3.40.1
    |   +-- Maven wrapper 3.9.16
    |   +-- project target -> Java 17
    |   `-- REST endpoint /hello
    |
    `-- Verified
        +-- compile
        +-- build
        +-- code completion
        +-- navigation / refactor
        +-- debug
        `-- live coding
```

The important Java result is:

```text
VS Code Java language server -> Java 21
Quarkus project/build        -> Java 17
```

Those are separate runtimes and both worked in the tested UDI.

## Lab layout

```text
03-quarkus-java-vscode-compatibility/
|
+-- Dockerfile
|   `-- Builds the local UDI wrapper
|       Adds SSH only so desktop VS Code can connect
|
+-- sshd_config
|   `-- Configures the temporary SSH transport
|
+-- lab03-java.sh
|   `-- Restores the UDI Java environment for the SSH shell
|
+-- app/
|   +-- pom.xml
|   +-- mvnw
|   +-- .mvn/
|   +-- .vscode/
|   |   +-- settings.json
|   |   +-- extensions.json
|   |   `-- launch.json
|   `-- src/
|       +-- main/
|       `-- test/
|
+-- evidence/
|   `-- observed-results.md
|
`-- scripts/
    +-- build.sh
    +-- start.sh
    +-- bootstrap-workspace.sh
    +-- run-app.sh
    +-- open-vscode.sh
    +-- verify.sh
    +-- verify-live-reload.sh
    +-- inventory-java.sh
    `-- cleanup.sh
```

The `app/` directory is the same minimal Quarkus fixture used for the successful validation. It is copied into the temporary workspace each time the lab is started.

## Run the lab from a clean machine

### 1. Install the host prerequisites

The laptop only needs:

```text
Linux host
+-- Podman
+-- VS Code Desktop
+-- VS Code Remote - SSH extension
+-- OpenSSH client / ssh-keygen
`-- Python 3
```

Java, Maven and Quarkus do **not** need to be installed on the laptop. They run inside the UDI workspace.

The lab uses:

```text
registry.redhat.io/devspaces/udi-rhel9:3.30-1787764814
```

If required on a fresh machine:

```bash
podman login registry.redhat.io
```

### 2. Enter the lab directory

```bash
cd ~/openshift-labs/03-quarkus-java-vscode-compatibility
```

### 3. Build the local UDI wrapper

```bash
./scripts/build.sh
```

This generates a temporary SSH key and builds:

```text
localhost/quarkus-java-vscode-lab:latest
```

The wrapper does not turn the UDI into a production image. SSH exists only as local transport for this lab.

### 4. Start the workspace

```bash
./scripts/start.sh
```

This creates a fresh workspace volume and copies the reproducible Quarkus fixture to:

```text
/projects/quarkus-extension-proof
```

> **Reset warning:** `start.sh` removes and recreates the lab workspace volume. Re-running it resets the temporary workspace back to the `app/` seed.

### 5. Bootstrap and prove the baseline build

```bash
./scripts/bootstrap-workspace.sh
```

This runs inside the UDI with Java 17 and verifies:

```text
./mvnw test
./mvnw package -DskipTests
```

Expected result: tests and package complete successfully.

### 6. Start Quarkus dev mode

```bash
./scripts/run-app.sh
```

Quarkus runs inside the UDI on port `8080`.

The lab exposes it to the laptop at:

```text
http://127.0.0.1:8085/hello
```

Expected response:

```text
Hello from Quarkus REST
```

### 7. Open the workspace in VS Code

```bash
./scripts/open-vscode.sh
```

This opens local VS Code remotely against:

```text
/projects/quarkus-extension-proof
```

The bottom-left of VS Code should show that the window is connected to the SSH target `quarkus-java-vscode-lab`.

### 8. Install the lab extensions in the remote workspace

Open Extensions with:

```text
Ctrl + Shift + X
```

Install the workspace recommendations:

```text
Extension Pack for Java
Quarkus
Tools for MicroProfile
```

IDs:

```text
vscjava.vscode-java-pack
redhat.vscode-quarkus
redhat.vscode-microprofile
```

They must be active in the **remote** workspace, not only on the laptop.

The successful validation used:

```text
redhat.java                     1.56.0
vscjava.vscode-java-pack        0.31.1
redhat.vscode-quarkus           1.24.0
redhat.vscode-microprofile      0.18.0
```

Those versions are recorded as evidence, not imposed as organisation-wide standards.

### 9. Run the VS Code checks

Open:

```text
src/main/java/org/acme/GreetingResource.java
```

#### Java project recognition

Open the Problems panel:

```text
Ctrl + Shift + M
```

Expected: the project imports cleanly and the Jakarta types resolve without Java/JDK errors.

#### Code completion

Temporarily type:

```java
MediaType.
```

Press:

```text
Ctrl + Space
```

Expected: Java suggestions such as `TEXT_PLAIN` appear.

Remove the temporary edit afterward.

#### Refactor / navigation

Right-click the `hello` method.

Verify actions such as:

```text
Rename Symbol
Go to Definition
Find All References
```

Temporarily rename `hello`, confirm the refactor works, then undo it.

#### Quarkus configuration completion

Open:

```text
src/main/resources/application.properties
```

Type:

```text
quarkus.
```

and press `Ctrl + Space`.

Expected: Quarkus configuration suggestions appear.

Remove the temporary edit afterward.

#### Compile / build from the remote terminal

Open a terminal in the remotely connected VS Code window:

```bash
./mvnw test
./mvnw package -DskipTests
```

Expected: both commands pass using the UDI Java 17 project runtime.

#### Quarkus live coding

With dev mode running, edit:

```java
return "Hello from Quarkus REST";
```

to something temporary, for example:

```java
return "Hello from Quarkus LIVE";
```

Save the file and refresh:

```text
http://127.0.0.1:8085/hello
```

Expected: the response changes without manually restarting Quarkus.

Restore the original string afterward.

The same check can also be automated from the host with:

```bash
./scripts/verify-live-reload.sh
```

#### Debug

The project already contains:

```text
.vscode/launch.json
```

with:

```text
Attach to Quarkus Dev Mode
```

Quarkus dev mode exposes JDWP on `localhost:5005` **inside the remote workspace**.

1. Put a breakpoint on the return line in `GreetingResource.java`.
2. Open Run and Debug with `Ctrl + Shift + D`.
3. Select `Attach to Quarkus Dev Mode`.
4. Press `F5`.
5. Request `http://127.0.0.1:8085/hello`.

Expected: VS Code stops on the breakpoint.

Do not use the small **Run Java** action on `GreetingResource`; this REST resource is not a standalone Java class with a `main()` method.

### 10. Run the automated verification

From the host lab directory:

```bash
./scripts/verify.sh
```

This verifies:

```text
remote UID / workspace
JAVA_HOME
Java runtime
Maven wrapper
tests
package
running /hello endpoint
```

The editor-specific behaviours remain manual because the purpose is to prove the actual VS Code experience rather than simulate it with shell edits.

### 11. Clean up

```bash
./scripts/cleanup.sh
```

This removes the temporary container, workspace volume, wrapper image, SSH target and generated SSH keys.

The README, evidence and `app/` seed remain.

### Script order

```text
build.sh
   |
   v
start.sh
   |
   v
bootstrap-workspace.sh
   |
   v
run-app.sh
   |
   v
open-vscode.sh
   |
   v
manual VS Code checks
   |
   v
verify.sh
   |
   v
cleanup.sh   (when finished)
```

## What was proven

The Quarkus developer activities in this lab passed in the local UDI proof:

| Lab capability | Result |
| --- | --- |
| Compile | PASS |
| Build | PASS |
| Debug | PASS |
| Refactor / navigation | PASS |
| Code completion | PASS |
| Quarkus live coding | PASS |
| Java Pack / Java language support | PASS |
| Quarkus extension | PASS |
| MicroProfile extension present and active | PASS |
| Java language server on Java 21 while project builds on Java 17 | PASS |

Detailed observed evidence is in:

```text
evidence/observed-results.md
```

## Scope boundary

### Real behaviour in this lab

- real Red Hat Dev Spaces UDI;
- local VS Code Desktop;
- remote VS Code Server inside the UDI;
- Java Pack;
- Quarkus extension;
- MicroProfile extension;
- Java language server on Java 21;
- Quarkus/Maven project on Java 17;
- compile/test/package;
- Quarkus dev mode;
- code completion;
- navigation/refactor;
- debugging;
- live coding;
- REST endpoint reachable from the laptop.

### Local substitutes

- Podman container for the future Dev Spaces workspace pod;
- manual Remote SSH for Dev Spaces remote-connect plumbing;
- Podman volume for future workspace storage/PVC;
- public extension/dependency sources for the local proof.

### Stop here - requires real OpenShift / Dev Spaces

This lab does **not** prove:

- DevWorkspace creation/lifecycle;
- Dev Spaces Operator / CheCluster behaviour;
- enterprise namespace behaviour;
- OpenShift RBAC/SCC/network policy;
- managed extension mirror delivery;
- managed Maven dependency routing;
- platform-managed remote-connect configuration;
- RHDH / Golden Path provisioning.

Those require the real platform environment and its source-of-truth configuration.

## Success criteria

1. Local VS Code opens the Quarkus project remotely inside the UDI.
2. Java/Jakarta project analysis is healthy.
3. Code completion works.
4. Navigation/refactor works.
5. Maven tests pass.
6. Maven package passes.
7. Quarkus dev mode starts.
8. The REST endpoint responds.
9. Live coding updates the running endpoint.
10. VS Code attaches to the Quarkus debugger and stops on a breakpoint.
11. Quarkus configuration completion works.
12. Java language-server runtime and project runtime are independently verified.
13. The primary documented extension set is active in the remote workspace.
14. Local results are not presented as proof of real Dev Spaces control-plane behaviour.

All 14 criteria were verified on 2026-10-06.

## Files

- `Dockerfile`, `sshd_config`, `lab03-java.sh`: local remote-connect wrapper only.
- `app/`: reproducible minimal Quarkus application used for the successful proof.
- `scripts/`: repeatable build, start, validation and cleanup.
- `evidence/`: actual observed results from the completed validation.
