#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

wf=".github/workflows/gates.yml"
[[ -f "$wf" ]] || fail "missing $wf"
grep -q 'NEXT_TELEMETRY_DISABLED' "$wf" || fail "NEXT_TELEMETRY_DISABLED not set in gates workflow"
grep -q 'NEXT_TELEMETRY_DISABLED: "1"' "$wf" || fail "NEXT_TELEMETRY_DISABLED must be \"1\" in gates workflow"
echo "PASS"
