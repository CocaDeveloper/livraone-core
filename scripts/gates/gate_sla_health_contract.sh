#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

f="apps/hub/app/api/sla/health/route.ts"
[[ -f "$f" ]] || fail "missing $f"
grep -q 'ok: true' "$f" || fail "health must return ok:true"
grep -q 'service: "hub"' "$f" || fail "health must return service:\"hub\""
grep -q 'new Date().toISOString()' "$f" || fail "health must include ts"
echo "PASS"
