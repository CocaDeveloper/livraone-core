#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

test -f docs/subscription-enforcement.md || fail "missing docs/subscription-enforcement.md"
test -f apps/hub/src/lib/subscription/middleware_enforce.ts || fail "missing middleware enforcement module"
test -f apps/hub/middleware.ts || fail "missing apps/hub/middleware.ts"
test -f apps/hub/app/subscription/required/page.tsx || fail "missing subscription required page"

grep -q "enforceSubscription" apps/hub/middleware.ts || fail "hub middleware does not reference enforceSubscription"
grep -q "assertAccess" apps/hub/src/lib/subscription/middleware_enforce.ts || fail "middleware enforcement missing assertAccess"
grep -q "parseTenantFromHost" apps/hub/src/lib/subscription/middleware_enforce.ts || fail "middleware enforcement missing tenant parsing"
grep -q "isPublicPath" apps/hub/src/lib/subscription/middleware_enforce.ts || fail "public allowlist function missing"

grep -q "export const config" apps/hub/middleware.ts || fail "hub middleware missing export const config"
grep -q "matcher" apps/hub/middleware.ts || fail "hub middleware missing matcher config"

pass
