#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $*"; exit 1; }
pass() { echo "PASS"; }

STRIPE_FILE="${1:-apps/hub/src/lib/billing/stripe.ts}"

# 1) Stripe provider file must exist
test -f "$STRIPE_FILE" || fail "missing stripe provider file: $STRIPE_FILE"

# 2) Must use lazy import("stripe")
rg -n 'import\("stripe"\)|await\s+import\("stripe"\)' "$STRIPE_FILE" >/dev/null || fail "stripe provider must use lazy import(\"stripe\")"

# 3) Must NOT have top-level static import from 'stripe'
if rg -n '^\s*import\s+.*from\s+["'\'']stripe["'\'']' "$STRIPE_FILE" >/dev/null; then
  fail "static import from stripe is forbidden (unsafe import)"
fi

# 4) Must NOT require secrets when disabled (expect STRIPE_ENABLED gating exists)
rg -n 'STRIPE_ENABLED' "$STRIPE_FILE" >/dev/null || fail "expected STRIPE_ENABLED gating in provider"

# 5) Must reference expected env vars (contract)
rg -n 'STRIPE_SECRET_KEY' "$STRIPE_FILE" >/dev/null || fail "expected STRIPE_SECRET_KEY reference"
rg -n 'STRIPE_WEBHOOK_SECRET' "$STRIPE_FILE" >/dev/null || fail "expected STRIPE_WEBHOOK_SECRET reference"

pass
