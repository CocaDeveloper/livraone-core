#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# Contract:
# - packages/ui must export Shell wrappers
[[ -f packages/ui/src/Shell.tsx ]] || fail "missing packages/ui/src/Shell.tsx"
grep -q 'export function AuthShell' packages/ui/src/Shell.tsx || fail "AuthShell missing"
grep -q 'export \* from "\.\/Shell"' packages/ui/src/index.ts || fail "ui index not exporting Shell"

# Contract:
# - hub login must use AuthShell + server auth start
f="apps/hub/app/login/LoginPageClient.tsx"
[[ -f "$f" ]] || f="apps/hub/app/login/page.tsx"
[[ -f "$f" ]] || fail "missing login bootstrap implementation"
grep -q 'AuthShell' "$f" || fail "hub login not using AuthShell"
grep -q 'href={startPath}' "$f" || fail "hub login fallback must link to auth start path"
[[ -f apps/hub/app/api/auth/start/keycloak/route.ts ]] || fail "hub auth start route missing"

# Contract:
echo "PASS"
