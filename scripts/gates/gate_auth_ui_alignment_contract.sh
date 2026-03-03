#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# Contract: hub login uses @livraone/ui Card+Button
f="apps/hub/app/login/page.tsx"
[[ -f "$f" ]] || fail "missing $f"
grep -q 'from "@livraone/ui"' "$f" || fail "hub login not importing @livraone/ui"
grep -q 'signIn("keycloak"' "$f" || fail "hub login must call signIn(keycloak)"
grep -q 'callbackUrl: "/post-auth"' "$f" || fail "hub login must use callbackUrl /post-auth"

echo "PASS"
