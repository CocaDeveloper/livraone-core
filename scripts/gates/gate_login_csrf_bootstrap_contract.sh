#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

f="apps/hub/app/api/auth/start/keycloak/route.ts"
[[ -f "$f" ]] || fail "missing $f"

grep -q '/api/auth/csrf' "$f" || fail "auth start route must fetch /api/auth/csrf"
grep -q '/api/auth/signin/keycloak' "$f" || fail "auth start route must post to /api/auth/signin/keycloak"
grep -q 'buildPostAuthCallback' "$f" || fail "auth start route must derive callback via buildPostAuthCallback"

csrf_line=$(grep -n '/api/auth/csrf' "$f" | head -n1 | cut -d: -f1 || true)
signin_line=$(grep -n '/api/auth/signin/keycloak' "$f" | head -n1 | cut -d: -f1 || true)
[[ -n "${csrf_line:-}" && -n "${signin_line:-}" ]] || fail "missing csrf fetch or signin POST"
if [[ "$csrf_line" -gt "$signin_line" ]]; then
  fail "csrf fetch must appear before signin POST in source order"
fi

echo "PASS"
