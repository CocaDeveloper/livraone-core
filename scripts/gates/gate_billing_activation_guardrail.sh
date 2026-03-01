#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

# Ensure feature flag file exists
test -f apps/hub/src/lib/billing/feature_flag.ts || fail "feature_flag missing"
grep -q "BILLING_PROVIDER_ENABLED" apps/hub/src/lib/billing/feature_flag.ts || fail "flag missing"

# Ensure provider abstraction exists
test -f apps/hub/src/lib/billing/provider.ts || fail "provider missing"

# Block live SDK imports
if grep -R --line-number -E "stripe|paypal|braintree|square" apps/hub/src/lib/billing >/dev/null 2>&1; then
  fail "Live billing SDK detected"
fi

# Block direct fetch calls to payment endpoints
if grep -R --line-number -E "api\.stripe\.com|api\.paypal\.com" apps/hub >/dev/null 2>&1; then
  fail "Direct billing HTTP calls detected"
fi

test -f docs/billing-activation-guardrail.md || fail "docs missing"

pass
