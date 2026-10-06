# Lab 02 - MVP VS Code frontend workflow

Status: complete - all success criteria verified  
Started: 2026-10-04  
Completed: 2026-10-04

## Goal

Model the smallest useful frontend developer workflow that can be exercised before a real OpenShift / Dev Spaces environment exists.

The developer experience we are testing is:

```text
Local VS Code Desktop
        |
        | remote connection
        v
UDI RHEL9 developer workspace
        |
        +-- repo under /projects
        +-- NVM selects repo Node version
        +-- pnpm installs dependencies
        +-- ESLint checks source
        +-- Rspack builds / serves the app
        +-- Playwright runs a smoke test
        +-- Git edit / commit / push occurs remotely
        +-- developer opens the running app locally
```

This lab stops when the next meaningful behaviour depends on a real OpenShift / Dev Spaces control plane.

## Quick stand-up overview

```text
Developer Laptop
|
+-- Local VS Code
|   `-- Remote connection to UDI workspace
|
`-- Red Hat Dev Spaces UDI (RHEL 9)
    +-- UID 10001 developer
    +-- /projects/mvp-frontend
    +-- VS Code Server
    +-- NVM -> Node 22.23.1
    +-- pnpm
    +-- Rspack
    +-- ESLint
    +-- Playwright
    +-- Git
    |   `-- clone / commit / push
    `-- Frontend dev server :3000

Capabilities
+-- Edit code remotely
+-- Install dependencies
+-- Lint
+-- Build
+-- Run app
+-- Run tests
`-- Commit + push from workspace
```

```text
02-mvp-vscode-frontend-workflow/
|
+-- Dockerfile
|  `-- Builds the local UDI wrapper
|     Adds SSH so VS Code can connect remotely
|
+-- sshd_config
|  `-- Configures the SSH connection into the UDI
|
+-- app/
|  +-- .nvmrc
|  |  `-- Selects Node 22.23.1
|  |
|  +-- package.json
|  |  `-- Defines pnpm scripts + dependencies
|  |     pnpm dev
|  |     pnpm build
|  |     pnpm lint
|  |     pnpm test
|  |
|  +-- pnpm-lock.yaml
|  |  `-- Locks exact dependency versions
|  |
|  +-- rspack.config.cjs
|  |  `-- Tells Rspack how to build/serve the frontend
|  |
|  +-- eslint.config.js
|  |  `-- Defines code linting rules
|  |
|  +-- playwright.config.js
|  |  `-- Configures the automated test environment
|  |
|  +-- src/
|  |  +-- index.js
|  |  `-- styles.css
|  |     `-- Actual application source
|  |
|  +-- public/index.html
|  |  `-- Browser HTML entry point
|  |
|  `-- tests/smoke.spec.js
|     `-- Playwright smoke test
|
`-- scripts/
   +-- build.sh
   |  `-- Builds the UDI lab image
   |
   +-- start.sh
   |  `-- Starts container + workspace + Git repo
   |
   +-- bootstrap-workspace.sh
   |  `-- Installs/selects Node, pnpm, dependencies
   |
   +-- run-app.sh
   |  `-- Starts the Rspack dev server
   |
   +-- open-vscode.sh
   |  `-- Opens local VS Code connected remotely
   |
   +-- verify.sh
   |  `-- Runs identity + Git + lint + build + tests
   |
   `-- cleanup.sh
      `-- Removes the temporary lab runtime
```

## Run the lab from a clean machine

### 1. Install the host prerequisites

The host laptop only needs the tools required to run and connect to the remote UDI workspace:

```text
Linux host
+-- Podman
+-- VS Code Desktop
+-- VS Code Remote - SSH extension
+-- OpenSSH client / ssh-keygen
`-- Python 3
```

You do **not** need to install Node.js, pnpm, Rspack, ESLint or Playwright on the laptop. Those are selected or installed inside the UDI workspace.

You also need access to the Red Hat registry used by the lab:

```text
registry.redhat.io/devspaces/udi-rhel9:3.30-1787764814
```

If the registry requires authentication on a fresh machine, authenticate with Podman before building:

```bash
podman login registry.redhat.io
```

The build script will pull the UDI image automatically if it is not already available locally.

### 2. Enter the lab directory

```bash
cd ~/openshift-labs/02-mvp-vscode-frontend-workflow
```

### 3. Build the local UDI wrapper

```bash
./scripts/build.sh
```

This generates the temporary lab SSH key when required and builds:

```text
localhost/mvp-vscode-frontend-lab:latest
```

### 4. Start the workspace

```bash
./scripts/start.sh
```

This starts the UDI container, creates the `/projects` workspace volume, creates the synthetic Git repository and bare Git origin, and clones the developer working copy to:

```text
/projects/mvp-frontend
```

> **Reset warning:** `start.sh` removes and recreates the lab workspace volume. Re-running it resets the current workspace and Git stand-in.

### 5. Bootstrap the developer workspace

```bash
./scripts/bootstrap-workspace.sh
```

This prepares the workspace by selecting the repo Node version, installing pnpm and project dependencies, generating the lockfile when needed, and committing/pushing the lockfile to the lab Git origin.

### 6. Start the frontend

```bash
./scripts/run-app.sh
```

The Rspack development server runs inside the UDI on port `3000`. The lab exposes it to the laptop at:

```text
http://127.0.0.1:3004
```

### 7. Open the workspace in VS Code

Convenience script:

```bash
./scripts/open-vscode.sh
```

This configures the temporary SSH target and opens local VS Code against:

```text
/projects/mvp-frontend
```

`open-vscode.sh` is optional. You can also open VS Code yourself, connect to the `mvp-vscode-frontend-lab` Remote SSH target, and open `/projects/mvp-frontend`.

### 8. Work entirely inside the remote workspace

From the terminal in the remotely connected VS Code window you can edit source, install dependencies, lint, build, test, run, commit and push without using the laptop's Node toolchain.

### 9. Verify the completed workflow

From the host lab directory:

```bash
./scripts/verify.sh
```

This reconnects to the workspace and verifies identity, runtime versions, Git state, linting, build and Playwright tests.

### 10. Clean up when finished

```bash
./scripts/cleanup.sh
```

This removes the lab container, workspace volume, local wrapper image, temporary SSH target and generated lab SSH keys. The lab documentation and seed repository remain.

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
develop / commit / push
   |
   v
verify.sh
   |
   v
cleanup.sh   (when finished)
```

### Useful tests from the remote workspace

Run these from the VS Code terminal connected to `/projects/mvp-frontend`:

```bash
# Confirm developer identity and workspace
id
pwd

# Confirm tool versions
nvm use
node --version
pnpm --version
git --version

# Check repository state
git status
git log --oneline -5

# Make and inspect a repo change
git diff

# Commit and push entirely from the workspace
git add .
git commit -m "test: verify remote development workflow"
git push

# Run the frontend quality/build workflow
pnpm lint
pnpm build
pnpm test

# Run the application from the workspace
pnpm dev
```

## Tool choices

The frontend architecture guidance supplied for this lab is the basis for the tool selection.

| Tool | Guidance observed | Lab use |
| --- | --- | --- |
| NVM | Default / Maintain | Select the Node.js version declared by the repository |
| pnpm | Default / Invest | Project package manager |
| Rspack | Default / Invest | Build and development server |
| ESLint | Default / Invest | Linting |
| Playwright | Default / Invest | Smoke/integration test |

Tools marked Exception, Avoid or Retire are not introduced by this lab.

The exact Node version was not specified in the supplied frontend guidance. The lab pins `22.23.1` because that is the Node.js runtime already present in the tested Red Hat Dev Spaces UDI `3.30-1787764814`. That is a lab baseline, not a claim that Node 22.23.1 is the organisation-wide application standard.

Package versions are pinned for repeatability after checking the public package metadata on 2026-10-04:

- pnpm 12.9.1
- @rspack/core 2.2.8
- @rspack/cli 2.2.8
- @rspack/dev-server 2.2.1
- ESLint 10.12.0
- @playwright/test 1.63.0

## Scope boundary

### Real behaviour in this lab

- local VS Code Desktop;
- remote VS Code Server;
- UDI-based remote developer environment;
- repository-owned `.nvmrc`;
- NVM Node selection;
- pnpm install;
- ESLint;
- Rspack build and dev server;
- Playwright request-level smoke test;
- Git work performed inside the remote workspace;
- running app reachable from the laptop.

### Local substitutes

- Podman container for the future CDE pod;
- manual Remote SSH for Dev Spaces remote connect;
- Podman volume for the future workspace/PVC;
- bare Git repository inside the lab workspace as a stand-in for a remote Git server.

### Stop here - requires real OpenShift / Dev Spaces

- DevWorkspace creation and lifecycle;
- namespace/PVC provisioning;
- Dev Spaces Operator / CheCluster;
- platform-managed desktop remote-connect setup;
- OpenShift authentication/RBAC/SCC;
- workspace policy and network policy;
- RHDH / Golden Path provisioning;
- enterprise Git/registry integration from the workspace.

## Repository shape

The synthetic repo intentionally resembles a normal frontend repository without copying proprietary source code:

```text
mvp-frontend/
|-- .nvmrc
|-- package.json
|-- pnpm-lock.yaml        # generated by pnpm install
|-- eslint.config.js
|-- playwright.config.js
|-- rspack.config.cjs
|-- public/
|   `-- index.html
|-- src/
|   |-- index.js
|   `-- styles.css
`-- tests/
    `-- smoke.spec.js
```

## Success criteria

1. Local VS Code opens `/projects/mvp-frontend` remotely.
2. Terminal proves commands are executing in the UDI workspace as UID 10001.
3. `nvm use` resolves `.nvmrc` and activates Node 22.23.1.
4. `pnpm install` completes and produces a lockfile.
5. `pnpm lint` passes.
6. `pnpm build` produces `dist/`.
7. `pnpm test` passes using Playwright.
8. `pnpm dev` serves the app on remote port 3000.
9. The app can be opened from the laptop.
10. A source edit is committed and pushed from the remote workspace to the local bare Git origin.
11. All commands and observed results are captured under `evidence/`.

All 11 criteria were verified on 2026-10-04. The final developer-driven change was committed and pushed from the remote UDI workspace, and the full verification suite passed afterward.

## Files

- `Dockerfile` and `sshd_config`: local remote-connect transport only.
- `app/`: synthetic frontend repository seed.
- `scripts/`: repeatable lab setup, validation and cleanup.
- `evidence/`: actual results as the lab progresses.
