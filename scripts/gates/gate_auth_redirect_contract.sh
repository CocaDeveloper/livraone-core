#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

COMPOSE="infra/compose.yaml"
MIDDLEWARE="apps/hub/middleware.ts"
SECRETS_DOC="docs/SECRETS_POLICY.md"
ENV_EXAMPLE="env.example"

[ -f "$COMPOSE" ] || fail "missing $COMPOSE"
[ -f "$MIDDLEWARE" ] || fail "missing $MIDDLEWARE"
[ -f "$SECRETS_DOC" ] || fail "missing $SECRETS_DOC"
[ -f "$ENV_EXAMPLE" ] || fail "missing $ENV_EXAMPLE"

hub_block=$(awk '
  /^  hub:/ {in_block=1; next}
  in_block && /^  [a-zA-Z0-9_-]+:/ {exit}
  in_block {print}
' "$COMPOSE")

echo "$hub_block" | grep -q 'NEXTAUTH_TRUST_HOST=1' || fail "hub compose missing NEXTAUTH_TRUST_HOST=1"
echo "$hub_block" | grep -q 'NEXTAUTH_URL=${NEXTAUTH_URL}' || fail "hub compose must source NEXTAUTH_URL from SSOT"

grep -q '^- NEXTAUTH_URL$' "$SECRETS_DOC" || fail "NEXTAUTH_URL not documented in SSOT contract"
grep -q '"/api/auth"' "$MIDDLEWARE" || fail "middleware must allow /api/auth"
grep -q 'HUB_AUTH_CALLBACK_URL=https://hub.livraone.com/api/auth/callback/keycloak' "$ENV_EXAMPLE" || fail "env.example must include hub auth callback URL"

echo "PASS"
