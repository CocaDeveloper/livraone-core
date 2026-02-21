#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

compose="ops/compose/observability/docker-compose.yml"

fail(){ echo "FAIL: $*" >&2; exit 1; }

[[ -f "$compose" ]] || fail "observability compose missing"

if rg -n 'env_file' "$compose" >/dev/null; then
  fail "env_file found in observability compose"
fi

if git ls-files | rg -n '(^|/)\.env($|\.)' >/dev/null; then
  fail "tracked .env files found"
fi

if ! rg -n 'status\.livraone\.com' "$compose" >/dev/null; then
  fail "status.livraone.com router missing"
fi

if ! rg -n 'traefik\.enable=true' "$compose" >/dev/null; then
  fail "traefik labels missing"
fi

if rg -n 'traefik\.http\.routers\.(prometheus|grafana|cadvisor|node_exporter)' "$compose" >/dev/null; then
  fail "public metrics router detected"
fi

echo "observability contract OK"
