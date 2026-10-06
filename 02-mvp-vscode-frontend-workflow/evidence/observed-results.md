# Lab 02 observed results

Date: 2026-10-04  
State: COMPLETE - automated baseline and manual remote developer workflow verified

## Environment

- Base image: Red Hat Dev Spaces UDI RHEL9 `3.30-1787764814`
- Remote user: `uid=10001(developer) gid=0(root)`
- Remote working copy: `/projects/mvp-frontend`
- Local transport substitute: VS Code Remote SSH
- Local app fallback URL: `http://127.0.0.1:3004`

## Tool versions

- NVM: 0.40.3
- Node.js selected from `.nvmrc`: v22.23.1
- npm bundled with Node: 10.9.8
- pnpm: 12.9.1
- @rspack/core: 2.2.8
- @rspack/cli: 2.2.8
- @rspack/dev-server: 2.2.1
- ESLint: 10.12.0
- @playwright/test: 1.63.0

## Automated verification

```text
pnpm lint
PASS

pnpm build
Rspack compiled successfully

pnpm test
1 passed
```

The Playwright smoke test starts the Rspack dev server and verifies both the HTML response and the generated `bundle.js`.

## Remote VS Code

Local VS Code Desktop successfully connected to `mvp-vscode-frontend-lab`.

VS Code Server processes were observed inside the UDI workspace, including:

- command shell / agent host
- `server-main.js`
- `fileWatcher`

## Git stand-in

The lab creates a bare Git repository at `/projects/_origin.git` as the local stand-in for a remote Git server and clones the developer working copy to `/projects/mvp-frontend`.

Verified commit history:

```text
a97f328 test: update smoke test for remote edit
fde7fe3 test: verify remote front end workflow
0579c89 fix: handle css in rspack lab build
d01283e fix: make frontend lab build and smoke test deterministic
1eb86e5 build: pin frontend lab dependencies
b8952b4 chore: initialise synthetic frontend lab
```

The developer changed the application heading from VS Code inside the remote UDI workspace, committed and pushed `fde7fe3`, then updated the failing smoke-test expectation and pushed `a97f328`. Both commits were verified in the bare Git origin at `/projects/_origin.git`.

## App

The app is currently running from the remote UDI workspace and responds through the fallback host mapping at:

```text
http://127.0.0.1:3004
```

The generated bundle contains the developer-edited `Adams MVP Remote Dev Lab` application content.

## Final verification

After the developer edit and test update, `./scripts/verify.sh` was rerun and passed end to end:

```text
identity: uid=10001(developer) gid=0(root)
workspace: /projects/mvp-frontend
Node: v22.23.1
pnpm: 12.9.1
git: clean main tracking origin/main
lint: PASS
build: Rspack compiled successfully
test: 1 passed
```

The final `HEAD`, `origin/main`, and bare Git origin all resolve to `a97f328`. This closes the lab at the local-proof boundary; further behaviour requires the real OpenShift / Dev Spaces platform.
