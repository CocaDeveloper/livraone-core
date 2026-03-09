#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# Contract: hub login uses @livraone/ui Card+Button
f="apps/hub/app/login/LoginPageClient.tsx"
[[ -f "$f" ]] || f="apps/hub/app/login/page.tsx"
[[ -f "$f" ]] || fail "missing login bootstrap implementation"
grep -q 'from "@livraone/ui"' "$f" || fail "hub login not importing @livraone/ui"
grep -q 'signIn("keycloak"' "$f" || fail "hub login must call signIn(keycloak)"
grep -q 'buildPostAuthCallback' "$f" || grep -q 'callbackUrl: "/post-auth"' "$f" || fail "hub login must use /post-auth callback flow"

echo "PASS"
