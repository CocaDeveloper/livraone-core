#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

COMPOSE="infra/compose.yaml"
[ -f "$COMPOSE" ] || fail "missing $COMPOSE"

grep -q -- '--accesslog.filepath=/var/log/traefik/access.log' "$COMPOSE" || fail "traefik accesslog filepath must be /var/log/traefik/access.log"
grep -q -- '/srv/livraone/logs/traefik:/var/log/traefik' "$COMPOSE" || fail "traefik must mount /srv/livraone/logs/traefik:/var/log/traefik"
grep -q -- 'entrypoint: \["traefik"\]' "$COMPOSE" || fail "traefik service must set entrypoint to traefik binary"

if grep -q 'Headers(' "$COMPOSE"; then
  fail "traefik v3 matcher must use Header/HeaderRegexp, not Headers"
fi

grep -q 'traefik.http.routers.hub-canary-header.rule=.*Header(' "$COMPOSE" || fail "hub canary header rule must use Header()"

echo "PASS"
