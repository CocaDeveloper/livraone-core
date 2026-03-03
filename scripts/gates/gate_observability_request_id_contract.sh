#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

f="apps/hub/middleware.ts"
[[ -f "$f" ]] || fail "missing $f"
grep -q 'x-request-id' "$f" || fail "middleware must set x-request-id"
grep -q 'export const config' "$f" || fail "middleware must define matcher config"
echo "PASS"
