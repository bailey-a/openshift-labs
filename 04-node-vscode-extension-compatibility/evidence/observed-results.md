# Lab 04 observed results

Captured: 2026-10-07

## UDI baseline

Image:

`registry.redhat.io/devspaces/udi-rhel9:3.30-1787764814`

Observed tooling:

- Node: 22.23.1
- npm: 10.9.8
- Git: 2.52.0
- curl: 7.76.1
- Corepack: not present in PATH

## Controlled Node fixture

Pinned development tooling:

- ESLint: 10.12.0
- Prettier: 3.9.9
- Vitest: 5.0.3

The fixture uses a lock file and the reproducible bootstrap command:

```text
npm ci
```

Observed install result:

- 114 packages installed
- 115 packages audited
- 0 vulnerabilities reported

## Automated validation

The clean lifecycle was exercised from a rebuilt local wrapper and fresh
workspace volume.

Observed results:

- `npm ci`: PASS
- `npm run lint`: PASS
- `npm run format:check`: PASS
- `npm test`: PASS
- Vitest: 1 test file, 2 tests passed
- remote SSH identity: UID 10001 / GID 0
- workspace: `/projects/node-extension-proof`
- seeded Git repository: PASS
- HTTP endpoint: PASS
- endpoint response: `Hello from Node REST`
- Node inspector listener: port 9229 inside the workspace
- watch-mode reload: PASS
- changed response observed: `Hello from Node LIVE`
- restored response observed: `Hello from Node REST`

## Manual VS Code extension pass

Status: partially completed. Test runner, path completion, Git context, YAML and Kubernetes manifest handling were exercised successfully. Remaining editor-only checks are retained as pending rather than inferred.

Candidate extensions installed in the remote workspace:

- `editorconfig.editorconfig@0.18.2`
- `firsttris.vscode-jest-runner@0.4.150`
- `dbaeumer.vscode-eslint@3.0.34`
- `eamodio.gitlens@19.3.0`
- `ms-kubernetes-tools.vscode-kubernetes-tools@1.4.1`
- `christian-kohler.path-intellisense@2.10.0`
- `esbenp.prettier-vscode@12.4.0`
- `mtxr.sqltools@0.28.6`
- `styled-components.vscode-styled-components@1.7.8`
- `redhat.vscode-yaml@1.24.0`

Exact remote extension versions captured. Individual manual editor checks remain
to be completed.

## Current findings matrix

| Lab capability | Result | Notes |
| --- | --- | --- |
| Node runtime | PASS | Node 22.23.1 in tested UDI |
| npm | PASS | npm 10.9.8 |
| Locked dependency install | PASS | `npm ci` |
| ESLint CLI | PASS | 10.12.0 |
| Prettier CLI | PASS | 3.9.9 |
| Vitest CLI | PASS | 5.0.3; 2 tests |
| HTTP endpoint | PASS | `/hello` |
| Node watch mode | PASS | edit and restoration observed without manual restart |
| Node inspector | READY | listener available; editor attach remains manual |
| Remote VS Code | READY | SSH transport configured; manual editor pass pending |
| EditorConfig | PENDING | manual editor check |
| Jest / Vitest Runner | PASS | Run / Debug CodeLens observed against the Vitest fixture |
| ESLint editor diagnostics | PENDING | manual editor check |
| GitLens | PASS | File-history workflow available against seeded Git history |
| Kubernetes extension | PASS | Extension activated with the Kubernetes manifest; no cluster required |
| Path Intellisense | PASS | JavaScript import-path completion exercised |
| Prettier editor formatting | PENDING | manual editor check |
| SQLTools | PENDING | SQL editor activation only |
| styled-components | PENDING | tagged-template syntax check |
| YAML extension | PASS | YAML editing/manifest completion exercised |
| Product-specific workspace connector | NOT TESTED | outside local transport proof |
| Managed extension distribution | NOT TESTED | outside local lab boundary |

## Boundary note

The Node package dependencies in this local proof were downloaded from public
upstream package sources. This validates application/tool compatibility only.

The local wrapper uses Podman and generic Remote SSH as a stand-in for remote
workspace transport. It does not prove a real remote workspace control plane or
managed extension distribution.
