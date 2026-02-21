#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

contract="docs/ARCHITECTURE_CONTRACT.yaml"

fail(){ echo "FAIL: $*" >&2; exit 1; }

[[ -f "$contract" ]] || fail "missing contract file"

ssot=$(awk -F': ' '/secrets_ssot:/ {gsub(/"/,"",$2); print $2}' "$contract" | head -n1)
[[ "$ssot" == "/etc/livraone/hub.env" ]] || fail "secrets_ssot mismatch"

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
else
  HAS_RG=0
fi

if [ "$HAS_RG" -eq 1 ]; then
  if git ls-files | rg -n '(^|/)\.env($|\.)' >/dev/null; then
    fail "tracked .env files found"
  fi
else
  if git ls-files | grep -E '(^|/)\.env($|\.)' >/dev/null; then
    fail "tracked .env files found"
  fi
fi

if [ "$HAS_RG" -eq 1 ]; then
  if rg -n 'env_file' infra/compose.yaml >/dev/null; then
    fail "env_file found in infra/compose.yaml"
  fi
else
  if grep -n 'env_file' infra/compose.yaml >/dev/null; then
    fail "env_file found in infra/compose.yaml"
  fi
fi

if [[ ! -f apps/hub/app/api/health/route.ts && ! -f apps/hub/pages/api/health.js ]]; then
  fail "health endpoint missing"
fi

if [ "$HAS_RG" -eq 1 ]; then
  if ! rg -n 'traefik\.' infra/compose.yaml >/dev/null; then
    fail "traefik labels missing"
  fi
else
  if ! grep -n 'traefik\.' infra/compose.yaml >/dev/null; then
    fail "traefik labels missing"
  fi
fi

if [ "$HAS_RG" -eq 1 ]; then
  if ! rg -n "$ssot" docs scripts .github infra >/dev/null; then
    fail "secrets ssot path not referenced"
  fi
else
  if ! grep -RIn "$ssot" docs scripts .github infra >/dev/null; then
    fail "secrets ssot path not referenced"
  fi
fi

echo "architecture contract OK"
