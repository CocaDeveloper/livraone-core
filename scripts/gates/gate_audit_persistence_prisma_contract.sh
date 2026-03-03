#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

grep -q "model AuditLog" apps/hub/prisma/schema.prisma || fail "AuditLog model missing"
test -f apps/hub/src/lib/audit/store_db.ts || fail "store_db missing"
grep -q "prisma.auditLog" apps/hub/src/lib/audit/store_db.ts || fail "store_db not using prisma.auditLog"

test -f docs/audit-persistence.md || fail "docs missing"

# Ensure no delete/update exported
if grep -R --line-number -E "updateAudit|deleteAudit|removeAudit" apps/hub/src/lib/audit >/dev/null 2>&1; then
  fail "audit must remain append-only"
fi

pass
