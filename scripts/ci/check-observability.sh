#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

compose="ops/compose/observability/docker-compose.yml"

if command -v rg >/dev/null 2>&1; then
  RG=(rg -n)
else
  RG=(grep -n)
fi

fail(){ echo "FAIL: $*" >&2; exit 1; }

[[ -f "$compose" ]] || fail "observability compose missing"

if "${RG[@]}" 'env_file' "$compose" >/dev/null; then
  fail "env_file found in observability compose"
fi

if command -v rg >/dev/null 2>&1; then
  if git ls-files | rg -n '(^|/)\.env($|\.)' >/dev/null; then
    fail "tracked .env files found"
  fi
else
  if git ls-files | grep -n -E '(^|/)\.env($|\.)' >/dev/null; then
    fail "tracked .env files found"
  fi
fi

if ! "${RG[@]}" 'status\.livraone\.com' "$compose" >/dev/null; then
  fail "status.livraone.com router missing"
fi

if ! "${RG[@]}" 'traefik\.enable=true' "$compose" >/dev/null; then
  fail "traefik labels missing"
fi

if "${RG[@]}" 'traefik\.http\.routers\.(prometheus|grafana|cadvisor|node_exporter)' "$compose" >/dev/null; then
  fail "public metrics router detected"
fi

echo "observability contract OK"
