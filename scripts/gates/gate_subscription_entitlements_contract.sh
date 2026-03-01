#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

test -f docs/subscription-entitlements.md || fail "missing docs/subscription-entitlements.md"
test -f apps/hub/src/lib/subscription/types.ts || fail "missing subscription types"
test -f apps/hub/src/lib/subscription/entitlements.ts || fail "missing entitlements"
test -f apps/hub/src/lib/subscription/store_stub.ts || fail "missing stub store"
test -f apps/hub/src/lib/subscription/enforce.ts || fail "missing enforcement"
test -f apps/hub/src/lib/subscription/index.ts || fail "missing index"
test -f apps/hub/src/lib/subscription/contract.test.ts || fail "missing contract test"

grep -q "export function assertAccess" apps/hub/src/lib/subscription/enforce.ts || fail "assertAccess missing"
grep -q "SubscriptionStatus" apps/hub/src/lib/subscription/types.ts || fail "SubscriptionStatus missing"
grep -q "trialing" apps/hub/src/lib/subscription/types.ts || fail "trialing status missing"

pass
