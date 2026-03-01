#!/usr/bin/env bash
set -euo pipefail

fail(){ echo "FAIL: $*"; exit 1; }
pass(){ echo "PASS"; }

have_rg(){ command -v rg >/dev/null 2>&1; }
scan(){
  local pat="$1" file="$2"
  if have_rg; then rg -n "$pat" "$file" >/dev/null
  else grep -nE "$pat" "$file" >/dev/null
  fi
}

HELPER="$1"
TARGET="$2"

test -f "$HELPER" || fail "missing helper: $HELPER"
test -f "$TARGET" || fail "missing target: $TARGET"

scan 'BILLING_ENFORCEMENT_ENABLED' "$HELPER" || fail "helper must be flag-controlled via BILLING_ENFORCEMENT_ENABLED"
scan 'enforceBillingForPaidFeatureAccess' "$HELPER" || fail "helper must export enforceBillingForPaidFeatureAccess"
scan 'enforceBillingForPaidFeatureAccess' "$TARGET" || fail "target must call enforceBillingForPaidFeatureAccess"

# must not require stripe vars/secrets here
if scan 'STRIPE_SECRET_KEY|STRIPE_WEBHOOK_SECRET|STRIPE_ENABLED' "$HELPER"; then
  fail "helper must not reference STRIPE_* vars (enforcement glue only)"
fi

pass
