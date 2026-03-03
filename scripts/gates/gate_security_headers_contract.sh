#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*"; exit 1; }
pass(){ echo "PASS"; }
have_rg(){ command -v rg >/dev/null 2>&1; }
scanq(){ local pat="$1" file="$2"; if have_rg; then rg -n "$pat" "$file" >/dev/null; else grep -nE "$pat" "$file" >/dev/null; fi; }

MW="$1"
HELPER="$2"
test -f "$MW" || fail "missing middleware: $MW"
test -f "$HELPER" || fail "missing helper: $HELPER"

scanq 'applySecurityHeaders' "$HELPER" || fail "helper must define applySecurityHeaders"
scanq 'Strict-Transport-Security' "$HELPER" || fail "helper must set HSTS"
scanq 'Content-Security-Policy' "$HELPER" || fail "helper must set CSP"

scanq 'applySecurityHeaders' "$MW" || fail "middleware must reference applySecurityHeaders"

pass
