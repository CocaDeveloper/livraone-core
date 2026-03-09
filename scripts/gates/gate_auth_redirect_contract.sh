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

require_failfast_env(){
  local block="$1"
  local key="$2"
  printf '%s\n' "$block" | grep -Eq "${key}=\\$\\{${key}:\\?[^}]+\\}" \
    || fail "compose must fail-fast on missing $key"
}

hub_block=$(awk '
  /^  hub:/ {in_block=1; next}
  in_block && /^  [a-zA-Z0-9_-]+:/ {exit}
  in_block {print}
' "$COMPOSE")

invoice_block=$(awk '
  /^  invoice:/ {in_block=1; next}
  in_block && /^  [a-zA-Z0-9_-]+:/ {exit}
  in_block {print}
' "$COMPOSE")

echo "$hub_block" | grep -q 'NEXTAUTH_TRUST_HOST=1' || fail "hub compose missing NEXTAUTH_TRUST_HOST=1"
require_failfast_env "$hub_block" "NEXTAUTH_URL"
require_failfast_env "$hub_block" "KEYCLOAK_ISSUER"
require_failfast_env "$hub_block" "HUB_AUTH_ISSUER"
require_failfast_env "$hub_block" "HUB_AUTH_CLIENT_ID"
require_failfast_env "$hub_block" "HUB_AUTH_CLIENT_SECRET"
require_failfast_env "$hub_block" "NEXTAUTH_SECRET"
require_failfast_env "$hub_block" "HUB_AUTH_CALLBACK_URL"
printf '%s\n' "$hub_block" | grep -Eq 'DATABASE_URL=postgresql://livraone:\$\{NEXTAUTH_SECRET:\?[^}]+\}@hub-db:5432/livraone\?schema=public' \
  || fail "hub compose must fail-fast on NEXTAUTH_SECRET in DATABASE_URL"

require_failfast_env "$invoice_block" "KEYCLOAK_ISSUER"
require_failfast_env "$invoice_block" "HUB_AUTH_ISSUER"
require_failfast_env "$invoice_block" "HUB_AUTH_CLIENT_ID"
require_failfast_env "$invoice_block" "HUB_AUTH_CLIENT_SECRET"
require_failfast_env "$invoice_block" "NEXTAUTH_SECRET"
require_failfast_env "$invoice_block" "HUB_AUTH_CALLBACK_URL"

grep -q '^- NEXTAUTH_URL$' "$SECRETS_DOC" || fail "NEXTAUTH_URL not documented in SSOT contract"
grep -q '"/api/auth"' "$MIDDLEWARE" || fail "middleware must allow /api/auth"
grep -q 'HUB_AUTH_CALLBACK_URL=https://hub.livraone.com/api/auth/callback/keycloak' "$ENV_EXAMPLE" || fail "env.example must include hub auth callback URL"

echo "PASS"
