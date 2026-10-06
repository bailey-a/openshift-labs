#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY="$LAB_DIR/.mvp_lab_ed25519"

ssh   -o BatchMode=yes   -o StrictHostKeyChecking=accept-new   -o IdentitiesOnly=yes   -i "$KEY"   -p 2224   developer@127.0.0.1   'set -e
   export NVM_DIR="$HOME/.nvm"
   . "$NVM_DIR/nvm.sh"
   cd /projects/mvp-frontend
   echo "== identity =="
   id
   pwd
   echo "== runtime =="
   nvm use
   node --version
   pnpm --version
   echo "== git =="
   git status --short --branch
   git log --oneline -3
   echo "== lint =="
   pnpm lint
   echo "== build =="
   pnpm build
   echo "== test =="
   pnpm test'
