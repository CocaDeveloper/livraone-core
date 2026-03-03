#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

test -f docs/feature-gating.md || fail "missing docs/feature-gating.md"

test -f apps/hub/src/lib/features/types.ts || fail "missing feature types"
test -f apps/hub/src/lib/features/guard.ts || fail "missing feature guard"
test -f apps/hub/src/lib/features/index.ts || fail "missing feature index"

grep -q "assertFeatureForTenant" apps/hub/src/lib/features/guard.ts || fail "assertFeatureForTenant missing"
grep -q "isFeatureEnabledForTenant" apps/hub/src/lib/features/guard.ts || fail "isFeatureEnabledForTenant missing"
grep -q "entitlementsFor" apps/hub/src/lib/features/guard.ts || fail "guard must use entitlementsFor"
grep -q "getOrInitSubscription" apps/hub/src/lib/features/guard.ts || fail "guard must load subscription"

test -f apps/hub/src/app/api/features/assert/route.ts || fail "missing proof API route"
grep -q "assertFeatureForTenant" apps/hub/src/app/api/features/assert/route.ts || fail "API route must call assertFeatureForTenant"
grep -q "parseTenantFromHost" apps/hub/src/app/api/features/assert/route.ts || fail "API route must resolve tenant from host"

pass
