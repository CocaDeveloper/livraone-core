#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# This gate is CI-only. If not CI, PASS (avoid punishing VPS variance).
if [[ "${CI:-}" != "true" ]]; then
  echo "PASS (non-CI)"
  exit 0
fi

base_file="scripts/gates/contracts/ci_timing_baseline_seconds.txt"
[[ -f "$base_file" ]] || fail "missing $base_file"
base="$(cat "$base_file" | tr -d '[:space:]')"
[[ "$base" =~ ^[0-9]+$ ]] || fail "invalid baseline seconds: $base"

# Allow +35% regression or +30s, whichever larger.
# threshold = max(base*135/100, base+30)
thr_pct=$(( (base*135 + 99)/100 ))
thr_add=$(( base + 30 ))
if (( thr_pct > thr_add )); then thr="$thr_pct"; else thr="$thr_add"; fi

# Runner may export GATES_TOTAL_SECONDS (optional). Otherwise measure a minimal no-op.
elapsed="${GATES_TOTAL_SECONDS:-}"
if [[ -z "$elapsed" ]]; then
  # Best-effort measurement: run a lightweight command; do NOT run gates again here.
  # If your workflow later exports GATES_TOTAL_SECONDS, this becomes strict.
  echo "CI timing gate: GATES_TOTAL_SECONDS not set; PASS (soft)"
  exit 0
fi

[[ "$elapsed" =~ ^[0-9]+$ ]] || fail "invalid GATES_TOTAL_SECONDS: $elapsed"

if (( elapsed > thr )); then
  fail "CI timing regression: elapsed=${elapsed}s > threshold=${thr}s (baseline=${base}s)"
fi

echo "PASS (elapsed=${elapsed}s threshold=${thr}s baseline=${base}s)"
