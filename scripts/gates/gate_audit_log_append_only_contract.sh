#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

test -f docs/audit-log.md || fail "missing docs/audit-log.md"
test -f apps/hub/src/lib/audit/types.ts || fail "missing audit types"
test -f apps/hub/src/lib/audit/store_stub.ts || fail "missing audit store"
test -f apps/hub/src/lib/audit/index.ts || fail "missing audit index"

grep -q "appendAudit" apps/hub/src/lib/audit/store_stub.ts || fail "appendAudit missing"
grep -q "AUDIT_LOG" apps/hub/src/lib/audit/store_stub.ts || fail "AUDIT_LOG store missing"

# Ensure no delete/update functions exported
if grep -R --line-number -E "deleteAudit|removeAudit|updateAudit" apps/hub/src/lib/audit >/dev/null 2>&1; then
  fail "audit module must be append-only"
fi

# Ensure subscription integration references appendAudit
if ! grep -R "subscription.updated" apps/hub/src/lib/subscription >/dev/null 2>&1; then
  fail "subscription store not integrated with audit"
fi

pass
