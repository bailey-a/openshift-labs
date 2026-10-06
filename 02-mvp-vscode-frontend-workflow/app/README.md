# MVP frontend seed repo

Synthetic frontend repository used by Lab 02.

It deliberately contains no proprietary source code or credentials.

The repository owns its developer/runtime intent:

- `.nvmrc` selects the Node.js version for the project.
- `packageManager` pins pnpm.
- Rspack owns build/dev serving.
- ESLint owns linting.
- Playwright owns the smoke test.

The lab copies this seed into the remote UDI workspace, initialises a Git repository, creates a local bare origin as a stand-in for a remote Git server, and then clones the developer working copy into `/projects/mvp-frontend`.
