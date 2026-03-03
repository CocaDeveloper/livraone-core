#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

f="apps/hub/app/login/page.tsx"
[[ -f "$f" ]] || fail "missing $f"

# must auto-start keycloak signIn
grep -q 'signIn("keycloak"' "$f" || fail "login must call signIn(keycloak)"
grep -q 'callbackUrl: "/post-auth"' "$f" || fail "login must use callbackUrl /post-auth"

# must NOT render any Keycloak-branded CTA by default
# (CTA text must be generic and behind a showFallback guard)
if grep -qE 'Keycloak|CONTINUE WITH KEYCLOAK|Continue with Keycloak' "$f"; then
  fail "login must not show Keycloak CTA text"
fi
grep -q 'showFallback' "$f" || fail "fallback guard missing"
grep -q 'FALLBACK_MS' "$f" || fail "fallback timeout missing"

echo "PASS"
