#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://hub.livraone.com}"
EXPECTED_CALLBACK="https://hub.livraone.com/api/auth/callback/keycloak"

fail(){ echo "FAIL: $*" >&2; exit 1; }

status_root=$(curl -s -o /dev/null -w '%{http_code}' -I "$BASE_URL/" || true)
status_login=$(curl -s -o /dev/null -w '%{http_code}' -I "$BASE_URL/login" || true)
case "$status_root" in
  200|307) ;;
  *) fail "unexpected / status $status_root" ;;
esac
case "$status_login" in
  200|307) ;;
  *) fail "unexpected /login status $status_login" ;;
esac

providers="$(curl -sS "$BASE_URL/api/auth/providers" || true)"
echo "$providers" | grep -q "$EXPECTED_CALLBACK" || fail "providers callback missing/mismatch"

echo "PASS"
