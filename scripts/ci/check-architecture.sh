#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

contract="docs/ARCHITECTURE_CONTRACT.yaml"

fail(){ echo "FAIL: $*" >&2; exit 1; }

[[ -f "$contract" ]] || fail "missing contract file"

ssot=$(awk -F': ' '/secrets_ssot:/ {gsub(/"/,"",$2); print $2}' "$contract" | head -n1)
[[ "$ssot" == "/etc/livraone/hub.env" ]] || fail "secrets_ssot mismatch"

if git ls-files | rg -n '(^|/)\.env($|\.)' >/dev/null; then
  fail "tracked .env files found"
fi

if rg -n 'env_file' infra/compose.yaml >/dev/null; then
  fail "env_file found in infra/compose.yaml"
fi

if [[ ! -f apps/hub/app/api/health/route.ts && ! -f apps/hub/pages/api/health.js ]]; then
  fail "health endpoint missing"
fi

if ! rg -n 'traefik\.' infra/compose.yaml >/dev/null; then
  fail "traefik labels missing"
fi

if ! rg -n "$ssot" docs scripts .github infra >/dev/null; then
  fail "secrets ssot path not referenced"
fi

echo "architecture contract OK"
