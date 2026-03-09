#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

page="apps/hub/app/login/page.tsx"
fallback="apps/hub/app/login/LoginPageClient.tsx"
route="apps/hub/app/api/auth/start/keycloak/route.ts"
[[ -f "$page" ]] || fail "missing $page"
[[ -f "$fallback" ]] || fail "missing $fallback"
[[ -f "$route" ]] || fail "missing $route"

# must auto-start keycloak via server redirect
grep -q 'buildAuthStartPath' "$page" || fail "login page must derive auth start path"
grep -q 'redirect(startPath)' "$page" || fail "login page must redirect to auth start path"
grep -q 'manual' "$page" || fail "login page must keep manual fallback"

# must NOT render any Keycloak-branded CTA by default
# (fallback CTA text must be generic)
if grep -qE 'Keycloak|CONTINUE WITH KEYCLOAK|Continue with Keycloak' "$fallback"; then
  fail "login must not show Keycloak CTA text"
fi
grep -q 'href={startPath}' "$fallback" || fail "manual fallback must link to auth start path"
grep -q 'Continue' "$fallback" || fail "manual fallback continue CTA missing"

echo "PASS"
