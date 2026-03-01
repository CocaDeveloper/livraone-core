#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

grep -q "model Membership" apps/hub/prisma/schema.prisma || fail "Membership model missing"
test -f apps/hub/src/lib/seats/enforcement.ts || fail "Seat enforcement missing"
grep -q "assertSeatAvailable" apps/hub/src/lib/seats/enforcement.ts || fail "assertSeatAvailable missing"
grep -q "SEAT_LIMIT_EXCEEDED" apps/hub/src/lib/seats/enforcement.ts || fail "Seat error missing"

test -f docs/seat-enforcement.md || fail "docs missing"

pass
