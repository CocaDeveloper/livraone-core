#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

test -f apps/hub/src/lib/subscription/trial_engine.ts || fail "trial_engine missing"

grep -q "evaluateTrial" apps/hub/src/lib/subscription/trial_engine.ts || fail "evaluateTrial missing"

grep -q "downgradedTo" apps/hub/src/lib/subscription/trial_engine.ts || fail "downgrade logic missing"

# Ensure middleware calls evaluation
if ! grep -q "evaluateTrial" apps/hub/src/lib/subscription/middleware_enforce.ts; then
  fail "middleware enforcement missing trial evaluation"
fi

grep -q "expired" apps/hub/src/lib/subscription/types.ts || fail "expired status missing"

test -f docs/trial-expiration-downgrade.md || fail "docs missing"

pass
