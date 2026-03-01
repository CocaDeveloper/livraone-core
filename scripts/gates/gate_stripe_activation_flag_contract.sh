#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $*"; exit 1; }
pass() { echo "PASS"; }

STRIPE_FILE="${1:-apps/hub/src/lib/billing/stripe.ts}"

has_rg() { command -v rg >/dev/null 2>&1; }

match() {
  local pattern="$1"
  local file="$2"
  if has_rg; then
    rg -n "$pattern" "$file" >/dev/null
  else
    grep -nE "$pattern" "$file" >/dev/null
  fi
}

# 1) Stripe provider file must exist
test -f "$STRIPE_FILE" || fail "missing stripe provider file: $STRIPE_FILE"

# 2) Must use lazy import("stripe")
match 'import\("stripe"\)|await[[:space:]]+import\("stripe"\)' "$STRIPE_FILE" || fail "stripe provider must use lazy import(\"stripe\")"

# 3) Must NOT have top-level static import from 'stripe'
if match '^[[:space:]]*import[[:space:]]+.*from[[:space:]]+["'"'"']stripe["'"'"']' "$STRIPE_FILE"; then
  fail "static import from stripe is forbidden (unsafe import)"
fi

# 4) Must NOT require secrets when disabled (expect STRIPE_ENABLED gating exists)
match 'STRIPE_ENABLED' "$STRIPE_FILE" || fail "expected STRIPE_ENABLED gating in provider"

# 5) Must reference expected env vars (contract)
match 'STRIPE_SECRET_KEY' "$STRIPE_FILE" || fail "expected STRIPE_SECRET_KEY reference"
match 'STRIPE_WEBHOOK_SECRET' "$STRIPE_FILE" || fail "expected STRIPE_WEBHOOK_SECRET reference"

pass
