#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# Contract:
# - packages/ui must export Shell wrappers
[[ -f packages/ui/src/Shell.tsx ]] || fail "missing packages/ui/src/Shell.tsx"
grep -q 'export function AuthShell' packages/ui/src/Shell.tsx || fail "AuthShell missing"
grep -q 'export \* from "\.\/Shell"' packages/ui/src/index.ts || fail "ui index not exporting Shell"

# Contract:
# - hub login must use AuthShell + signIn(keycloak)
f="apps/hub/app/login/page.tsx"
[[ -f "$f" ]] || fail "missing $f"
grep -q 'AuthShell' "$f" || fail "hub login not using AuthShell"
grep -q 'signIn("keycloak"' "$f" || fail "hub login must call signIn(keycloak)"
grep -q 'callbackUrl: "/post-auth"' "$f" || fail "hub login must use callbackUrl /post-auth"

# Contract:
# - at least one file was patched by phase script (guard against silent no-op)
cfile="/tmp/phase56_patched_count.txt"
[[ -f "$cfile" ]] || fail "missing patched count marker"
cnt="$(cat "$cfile" 2>/dev/null || echo 0)"
[[ "$cnt" -ge 1 ]] || fail "phase56 resulted in no patches (cnt=$cnt)"

echo "PASS"
