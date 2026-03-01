#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

# Contract files
test -f docs/billing-policy.md || fail "missing docs/billing-policy.md"
test -f apps/hub/src/lib/billing/types.ts || fail "missing billing types"
test -f apps/hub/src/lib/billing/stub.ts || fail "missing billing stub provider"
test -f apps/hub/src/lib/billing/index.ts || fail "missing billing provider selector"
test -f apps/hub/src/lib/billing/policy.ts || fail "missing billing policy guard"

# Ensure stub-only provider name referenced
grep -q "name: 'stub'" apps/hub/src/lib/billing/stub.ts || fail "stub provider must be named 'stub'"
grep -q "return billingStubProvider" apps/hub/src/lib/billing/index.ts || fail "getBillingProvider must return stub provider"

# Block direct Stripe SDK usage inside hub (no redesign, hard guard)
# Allow docs mentions; block imports/requires.
if command -v rg >/dev/null 2>&1; then
  if rg -n --glob '!**/*.md' --glob '!**/*.mdx' --glob '!**/node_modules/**' "(from ['\"]stripe['\"]|require\\(['\"]stripe['\"]\\))" apps/hub >/dev/null; then
    rg -n --glob '!**/*.md' --glob '!**/*.mdx' --glob '!**/node_modules/**' "(from ['\"]stripe['\"]|require\\(['\"]stripe['\"]\\))" apps/hub || true
    fail "stripe sdk import detected in apps/hub (stub-only policy)"
  fi
else
  if grep -R --line-number --exclude-dir=node_modules --exclude='*.md' --exclude='*.mdx' -E "from ['\"]stripe['\"]|require\\(['\"]stripe['\"]\\)" apps/hub >/dev/null 2>&1; then
    grep -R --line-number --exclude-dir=node_modules --exclude='*.md' --exclude='*.mdx' -E "from ['\"]stripe['\"]|require\\(['\"]stripe['\"]\\)" apps/hub || true
    fail "stripe sdk import detected in apps/hub (stub-only policy)"
  fi
fi

# SSOT check: if hub.env declares BILLING_PROVIDER, it must be stub
# Do NOT print secrets. Only evaluate the key/value of BILLING_PROVIDER if present.
SSOT="/etc/livraone/hub.env"
test -f "$SSOT" || fail "missing SSOT hub.env"
if grep -qE '^BILLING_PROVIDER=' "$SSOT"; then
  v="$(grep -E '^BILLING_PROVIDER=' "$SSOT" | tail -n1 | cut -d= -f2- | tr -d '\r' | tr '[:upper:]' '[:lower:]')"
  if [ "$v" != "stub" ]; then
    fail "BILLING_PROVIDER must be stub in SSOT"
  fi
fi

pass
