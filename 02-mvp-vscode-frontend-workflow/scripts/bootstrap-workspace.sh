#!/usr/bin/env bash
set -euo pipefail

podman exec --user 10001 mvp-vscode-frontend-lab bash -lc '
  set -e
  export HOME=/home/user
  export NVM_DIR="$HOME/.nvm"

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh       | PROFILE="$HOME/.bashrc" bash
  fi

  . "$NVM_DIR/nvm.sh"
  cd /projects/mvp-frontend

  nvm install
  nvm use

  npm install -g pnpm@12.9.1
  pnpm install

  git add pnpm-lock.yaml
  if ! git diff --cached --quiet; then
    git commit -m "build: pin frontend lab dependencies"
    git push origin main
  fi

  printf "NVM=%s\n" "$(nvm --version)"
  printf "NODE=%s\n" "$(node --version)"
  printf "PNPM=%s\n" "$(pnpm --version)"
'
