# Lab 04 - Node / VS Code extension compatibility

Status: automated baseline complete - selected manual extension checks verified
Started: 2026-10-07

## Question this lab answers

Can a useful Node developer workflow run inside the tested Red Hat Dev Spaces UDI
with the candidate VS Code extensions used for editing, tests, linting, formatting,
Git context, Kubernetes/YAML, SQL and styled-components work?

The activities under test are:

```text
Node runtime
npm dependency install
lint
format check
Vitest run/debug
code completion
path completion
Git context
YAML / Kubernetes editing
SQL editing
styled-components editing
Node debugging
watch-mode reload
```

This lab validates technical compatibility only. It does not make software-policy
or approval claims.

As with Lab 03, the local wrapper recreates the developer experience without
claiming that Podman + SSH is a real remote workspace control plane.

## Quick stand-up overview

```text
Developer Laptop
|
+-- Local VS Code
|   `-- Remote SSH connection
|
`-- Red Hat Dev Spaces UDI (RHEL 9)
    +-- UID 10001 developer
    +-- /projects/node-extension-proof
    +-- VS Code Server
    |
    +-- Node tooling
    |   +-- Node 22.23.1
    |   +-- npm 10.9.8
    |   +-- ESLint 10.12.0
    |   +-- Prettier 3.9.9
    |   `-- Vitest 5.0.3
    |
    +-- Editor fixtures
    |   +-- .editorconfig
    |   +-- JavaScript imports
    |   +-- Git history
    |   +-- Kubernetes YAML
    |   +-- SQL
    |   `-- styled-components syntax
    |
    `-- Verified automatically
        +-- npm ci
        +-- lint
        +-- format check
        +-- 2 Vitest tests
        +-- HTTP endpoint
        `-- watch-mode reload
```

## Candidate extension coverage

The workspace recommendations intentionally contain only extensions that can be
meaningfully exercised by this local fixture.

| Capability | Extension ID | Local lab coverage |
| --- | --- | --- |
| EditorConfig | `editorconfig.editorconfig` | Manual editor check |
| Jest / Vitest Runner | `firsttris.vscode-jest-runner` | Manual test discovery/run/debug |
| ESLint | `dbaeumer.vscode-eslint` | Automated CLI + manual editor diagnostics |
| GitLens | `eamodio.gitlens` | Manual check against seeded Git history |
| Kubernetes | `ms-kubernetes-tools.vscode-kubernetes-tools` | Manual manifest recognition/view |
| Path Intellisense | `christian-kohler.path-intellisense` | Manual import-path completion |
| Prettier | `esbenp.prettier-vscode` | Automated CLI + manual formatting |
| SQLTools | `mtxr.sqltools` | Manual SQL editor activation |
| styled-components | `styled-components.vscode-styled-components` | Manual tagged-template syntax check |
| YAML | `redhat.vscode-yaml` | Manual YAML validation/completion |

Two capabilities are deliberately outside the recommended-extension fixture:

- the product-specific workspace connector, because the local lab uses generic
  Remote SSH only as transport;
- an editor REST client, because the endpoint proof is performed with `curl`
  and does not require an editor HTTP client.

## Lab layout

```text
04-node-vscode-extension-compatibility/
|
+-- Dockerfile
|   `-- Builds the local UDI wrapper
|       Adds SSH only so desktop VS Code can connect
|
+-- sshd_config
|   `-- Configures the temporary SSH transport
|
+-- lab04-node.sh
|   `-- Restores the UDI Node environment for the SSH shell
|
+-- app/
|   +-- package.json
|   +-- package-lock.json
|   +-- eslint.config.js
|   +-- .editorconfig
|   +-- .vscode/
|   |   +-- settings.json
|   |   +-- extensions.json
|   |   `-- launch.json
|   +-- src/
|   |   +-- server.js
|   |   +-- message.js
|   |   `-- ui.styles.js
|   +-- tests/
|   |   `-- message.test.js
|   +-- k8s/
|   |   `-- deployment.yaml
|   `-- db/
|       `-- example.sql
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
    +-- inventory-node.sh
    `-- cleanup.sh
```

The `app/` directory is the reproducible Node fixture. It is copied into a
fresh temporary workspace each time the lab is started.


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

Node, npm, ESLint, Prettier and Vitest do **not** need to be installed on the
laptop. They run inside the UDI workspace.

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
cd ~/openshift-labs/04-node-vscode-extension-compatibility
```

### 3. Build the local UDI wrapper

```bash
./scripts/build.sh
```

This generates a temporary SSH key and builds:

```text
localhost/node-vscode-extension-lab:latest
```

The wrapper does not turn the UDI into a production image. SSH exists only as
local transport for this lab.

### 4. Start the workspace

```bash
./scripts/start.sh
```

This creates a fresh workspace volume, copies the reproducible Node fixture to:

```text
/projects/node-extension-proof
```

and creates a small local Git history so Git-aware editor tooling has something
real to inspect.

> **Reset warning:** `start.sh` removes and recreates the lab workspace volume.
> Re-running it resets the temporary workspace back to the `app/` seed.

### 5. Bootstrap and prove the baseline

```bash
./scripts/bootstrap-workspace.sh
```

This runs inside the UDI and verifies:

```text
npm ci
npm run lint
npm run format:check
npm test
```

Expected result:

```text
Node    22.23.1
npm     10.9.8
ESLint  10.12.0
Prettier 3.9.9
Vitest  5.0.3
2 tests passed
```

### 6. Start Node watch mode

```bash
./scripts/run-app.sh
```

The Node application runs inside the UDI on port `3000`.

The lab exposes it to the laptop at:

```text
http://127.0.0.1:3006/hello
```

Expected response:

```text
Hello from Node REST
```

The dev process also exposes the Node inspector on `localhost:9229` inside the
remote workspace for the included VS Code attach configuration.

### 7. Open the workspace in VS Code

```bash
./scripts/open-vscode.sh
```

This opens local VS Code remotely against:

```text
/projects/node-extension-proof
```

The bottom-left of VS Code should show that the window is connected to the SSH
target `node-vscode-extension-lab`.

### 8. Install the workspace recommendations

Open Extensions:

```text
Ctrl + Shift + X
```

Install the workspace recommendations from:

```text
.vscode/extensions.json
```

The extensions must be active in the **remote** workspace, not only on the
laptop.

The recommended IDs are:

```text
editorconfig.editorconfig
firsttris.vscode-jest-runner
dbaeumer.vscode-eslint
eamodio.gitlens
ms-kubernetes-tools.vscode-kubernetes-tools
christian-kohler.path-intellisense
esbenp.prettier-vscode
mtxr.sqltools
styled-components.vscode-styled-components
redhat.vscode-yaml
```

Record exact installed versions in `evidence/observed-results.md` after the
manual validation pass. Versions are evidence for this lab run, not universal
version requirements.


## Manual VS Code checks

### EditorConfig

Open:

```text
src/server.js
```

Verify the editor follows the workspace formatting rules from `.editorconfig`,
including two-space indentation and LF line endings.

### Jest / Vitest Runner

Open:

```text
tests/message.test.js
```

Verify the extension discovers the Vitest tests and can run or debug an
individual test from the editor.

The CLI baseline is:

```bash
npm test
```

with two passing tests.

### ESLint

Open:

```text
src/server.js
```

Temporarily introduce an unused variable, for example:

```js
const unusedValue = true;
```

Expected: ESLint reports the problem in the editor.

Remove the temporary edit afterward.

### GitLens

Open any tracked source file and verify GitLens can read the seeded repository
history.

The workspace contains a real initial commit created by `start.sh`, so Git-aware
editor functionality is not being tested against an empty directory.

### Kubernetes

Open:

```text
k8s/deployment.yaml
```

Verify the Kubernetes extension recognises the manifest and provides its normal
manifest/editor experience.

A real cluster connection is not required for this lab.

### Path Intellisense

In:

```text
src/server.js
```

temporarily begin typing an import path such as:

```js
import { getMessage } from "./mes
```

Expected: path suggestions include `message.js`.

Undo the temporary edit afterward.

### Prettier

Open:

```text
src/server.js
```

Use **Format Document**.

Expected: the file formats cleanly with the workspace Prettier configuration.

The same formatting baseline can be checked from the terminal:

```bash
npm run format:check
```

### SQLTools

Open:

```text
db/example.sql
```

Verify SQLTools activates for the SQL file and provides the expected SQL editor
experience.

This lab does not configure a database connection or store database credentials.

### styled-components

Open:

```text
src/ui.styles.js
```

Verify the styled-components tagged template is recognised and highlighted as
CSS-in-JS content.

The file is an editor fixture and is intentionally not imported by the running
Node server.

### YAML

Open:

```text
k8s/deployment.yaml
```

Verify YAML validation and completion are active and the file has no syntax
errors.

### Node debug

The project contains:

```text
.vscode/launch.json
```

with:

```text
Attach to Node dev server
```

With `./scripts/run-app.sh` running:

1. Put a breakpoint inside the `/hello` branch in `src/server.js`.
2. Open Run and Debug with `Ctrl + Shift + D`.
3. Select `Attach to Node dev server`.
4. Press `F5`.
5. Request `http://127.0.0.1:3006/hello`.

Expected: VS Code stops at the breakpoint inside the remote workspace.

### Watch-mode reload

The automated form is:

```bash
./scripts/verify-live-reload.sh
```

It changes the watched entrypoint from:

```text
Hello from Node REST
```

to:

```text
Hello from Node LIVE
```

and verifies that Node watch mode reloads the process without a manual restart,
then restores the original source and response.

## Automated verification

At any point after bootstrap and `run-app.sh`:

```bash
./scripts/verify.sh
```

This verifies from the remote SSH shell:

```text
UID 10001
/projects/node-extension-proof
Node / npm
Git history
ESLint
Prettier
Vitest
HTTP endpoint
```

The script intentionally leaves editor-extension activation and UI behaviour as
manual checks.

## Inspect the UDI Node baseline

Run:

```bash
./scripts/inventory-node.sh
```

This reports the Node, npm, Corepack, Git and curl baseline directly from the
tested UDI image.

## Cleanup

```bash
./scripts/cleanup.sh
```

This removes:

```text
lab container
workspace volume
local wrapper image
temporary SSH config entry
runtime SSH key files
known-host entry
```

The reproducible `app/` seed, README and evidence remain.

## What this lab proves

When the automated and manual checks are complete, the lab can provide evidence
for:

- Node and npm operation inside the tested UDI;
- repeatable dependency installation from a lock file;
- lint, formatting and Vitest execution;
- remote VS Code operation against the UDI workspace;
- editor compatibility for the recommended local fixture extensions;
- Node debugger attachment;
- Node watch-mode development iteration;
- representative JavaScript, Git, Kubernetes/YAML, SQL and CSS-in-JS editing
  fixtures.

## What this lab does not prove

This local proof does **not** prove:

- a real remote workspace control plane;
- a product-specific workspace connector;
- managed extension distribution or allow-list configuration;
- organisation-specific software approval;
- a real Kubernetes cluster connection;
- a production database connection;
- production image suitability.

The wrapper adds SSH solely to make the local remote-editor proof possible.

## Reproducibility lifecycle

The intended lifecycle matches the previous compatibility lab:

```text
cleanup
build
start
bootstrap-workspace
run-app
verify
verify-live-reload
open-vscode
manual extension checks
cleanup
```

Keep observed versions and pass/fail results in:

```text
evidence/observed-results.md
```

so the README remains the runbook and the evidence file remains the record of
what actually happened.
