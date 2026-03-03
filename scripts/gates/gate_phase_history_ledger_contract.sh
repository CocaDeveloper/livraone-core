#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

f="docs/PHASE_HISTORY.md"
[[ -f "$f" ]] || fail "missing $f"

for p in 56 57 58 59 60 61 62 63 64 65 66 67 68 69; do
  grep -qE "^## Phase ${p}\b" "$f" || fail "missing Phase ${p} entry in $f"
done

echo "PASS"
