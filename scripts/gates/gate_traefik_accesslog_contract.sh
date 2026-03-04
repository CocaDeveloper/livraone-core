#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

COMPOSE="infra/compose.yaml"

[ -f "$COMPOSE" ] || fail "missing $COMPOSE"

traefik_block=$(awk '
  /^  traefik:/ {in_block=1; next}
  in_block && /^  [a-zA-Z0-9_-]+:/ {exit}
  in_block {print}
' "$COMPOSE")

echo "$traefik_block" | grep -Eq -- '"--accesslog(=true)?"' || fail "traefik accesslog must be enabled"
echo "$traefik_block" | grep -q -- '--accesslog.format=json' || fail "traefik accesslog must use json format"
echo "$traefik_block" | grep -q -- '--accesslog.fields.defaultmode=keep' || fail "traefik accesslog must keep default fields"
echo "$traefik_block" | grep -q -- '--accesslog.fields.headers.defaultmode=drop' || fail "traefik accesslog must drop headers by default"
echo "$traefik_block" | grep -q -- '--accesslog.fields.headers.names.User-Agent=keep' || fail "traefik accesslog must keep User-Agent"
echo "$traefik_block" | grep -q -- '--accesslog.fields.headers.names.X-Forwarded-For=keep' || fail "traefik accesslog must keep X-Forwarded-For"
echo "$traefik_block" | grep -q -- '--accesslog.fields.headers.names.X-Forwarded-Proto=keep' || fail "traefik accesslog must keep X-Forwarded-Proto"
echo "$traefik_block" | grep -q -- '--accesslog.fields.headers.names.X-Forwarded-Host=keep' || fail "traefik accesslog must keep X-Forwarded-Host"

echo "PASS"
