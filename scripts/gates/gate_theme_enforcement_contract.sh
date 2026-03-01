#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

css="packages/ui/src/globals.css"
[[ -f "$css" ]] || fail "missing $css"
grep -q '^:root' "$css" || fail "missing :root"
grep -q '^\.dark' "$css" || fail "missing .dark"
grep -q -- '--bg: 210 40% 98%' "$css" || fail "light default bg token drift"
grep -q -- '--bg: 222 47% 7%' "$css" || fail "dark bg token missing"

# Ensure hub layout does not ship with dark default
lay="apps/hub/app/layout.tsx"
[[ -f "$lay" ]] || fail "missing $lay"
if grep -qE 'className=.*dark' "$lay"; then
  fail "hub layout hardcodes dark class"
fi

echo "PASS"
