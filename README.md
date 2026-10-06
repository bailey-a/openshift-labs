# OpenShift Labs

Small, reproducible labs for validating OpenShift and Red Hat Dev Spaces developer-workflow concepts.

Each lab is built around one concrete question and is designed so another engineer can clone the repository, follow the lab README from top to bottom, and reproduce the result.

## Labs

### 02 - MVP VS Code frontend workflow

Proves the basic remote developer workflow using a Red Hat Dev Spaces UDI, local VS Code, a synthetic frontend application, build/test tooling, and Git.

See [02-mvp-vscode-frontend-workflow/README.md](02-mvp-vscode-frontend-workflow/README.md).

### 03 - Quarkus / Java / VS Code compatibility

Proves a Quarkus developer workflow inside the tested UDI: compile, build, code completion, refactor/navigation, debugging, live coding, and separate Java runtimes for editor tooling and the project.

See [03-quarkus-java-vscode-compatibility/README.md](03-quarkus-java-vscode-compatibility/README.md).

## Lab boundary

These are local reproducibility labs. Podman, local volumes, SSH, local Git repositories, and public dependency/extension sources may stand in for platform services.

A successful local lab demonstrates the developer workflow or compatibility being tested. It does **not** by itself prove production OpenShift/Dev Spaces control-plane configuration, organization-specific policy, RBAC, network policy, managed mirrors, or other environment-specific controls.
