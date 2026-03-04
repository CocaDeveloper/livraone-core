#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

COMPOSE="infra/compose.yaml"
MIDDLEWARE="apps/hub/middleware.ts"
LOGIN="apps/hub/app/login/page.tsx"
NAVBAR="apps/marketing/components/Navbar.tsx"

[ -f "$COMPOSE" ] || fail "missing $COMPOSE"
[ -f "$MIDDLEWARE" ] || fail "missing $MIDDLEWARE"
[ -f "$LOGIN" ] || fail "missing $LOGIN"
[ -f "$NAVBAR" ] || fail "missing $NAVBAR"

hub_block=$(awk '
  /^  hub:/ {in_block=1; next}
  in_block && /^  [a-zA-Z0-9_-]+:/ {exit}
  in_block {print}
' "$COMPOSE")

echo "$hub_block" | grep -q 'NEXTAUTH_URL=' || fail "hub compose missing NEXTAUTH_URL"
echo "$hub_block" | grep -q 'NEXTAUTH_TRUST_HOST=1' || fail "hub compose missing NEXTAUTH_TRUST_HOST=1"
echo "$hub_block" | grep -q 'HUB_AUTH_CALLBACK_URL=' || fail "hub compose missing HUB_AUTH_CALLBACK_URL"

rg -q '"/api/auth"' "$MIDDLEWARE" || fail "middleware must allow /api/auth"
rg -q 'signIn\("keycloak"' "$LOGIN" || fail "login page must initiate keycloak sign-in"

if ! rg -n 'hub\.livraone\.com/login' "$NAVBAR" >/dev/null; then
  fail "marketing navbar must link to hub login"
fi
if rg -n 'hub\.livraone\.com/login' "$NAVBAR" | rg -q 'hidden'; then
  fail "marketing login link must be visible on mobile (remove hidden class)"
fi

echo "PASS"
