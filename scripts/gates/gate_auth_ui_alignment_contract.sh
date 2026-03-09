#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# Contract: hub login uses @livraone/ui Card+Button
f="apps/hub/app/login/LoginPageClient.tsx"
[[ -f "$f" ]] || f="apps/hub/app/login/page.tsx"
[[ -f "$f" ]] || fail "missing login bootstrap implementation"
grep -q 'from "@livraone/ui"' "$f" || fail "hub login not importing @livraone/ui"
grep -q 'Continue' "$f" || fail "hub login fallback must render Continue CTA"
grep -q 'href={startPath}' "$f" || fail "hub login fallback must link to auth start path"

echo "PASS"
