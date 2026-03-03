#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

test -f apps/hub/prisma/schema.prisma || fail "missing prisma schema"
grep -q "model Subscription" apps/hub/prisma/schema.prisma || fail "Subscription model missing"

test -f apps/hub/src/lib/subscription/store_db.ts || fail "store_db missing"
grep -q "prisma.subscription" apps/hub/src/lib/subscription/store_db.ts || fail "store_db not using prisma.subscription"

test -f docs/subscription-persistence.md || fail "docs missing"

pass
