# Node VS Code extension proof fixture

This fixture exists only to give the editor extensions in the parent lab small,
repeatable files and commands to work against.

It includes:

- a minimal Node HTTP endpoint at `/hello`;
- a Vitest test;
- ESLint and Prettier configuration;
- an EditorConfig file;
- an import path for path-completion checks;
- a styled-components syntax fixture;
- a Kubernetes YAML manifest;
- a small SQL file;
- VS Code extension recommendations and debugger configuration.

The product-specific remote workspace connector is intentionally outside this
local fixture. The parent lab uses generic Remote SSH only as transport.
