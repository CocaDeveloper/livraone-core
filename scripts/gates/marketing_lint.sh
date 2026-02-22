#!/usr/bin/env bash
set -euo pipefail
# Deterministic marketing lint/typecheck (no secrets)
cd "$(git rev-parse --show-toplevel)/apps/marketing"
if [ -f package-lock.json ]; then
  npm -s ci --ignore-scripts
else
  npm -s install --ignore-scripts
fi
npm -s run lint
npm -s run typecheck
rm -rf node_modules .next tsconfig.tsbuildinfo
