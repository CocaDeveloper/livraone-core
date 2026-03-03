#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

# 1) Tenant contract module must exist
test -f apps/hub/src/lib/tenant.ts || fail "missing apps/hub/src/lib/tenant.ts"

# 2) Must export requireTenantId + withTenantWhere (simple grep contract)
grep -q "export function requireTenantId" apps/hub/src/lib/tenant.ts || fail "requireTenantId not exported"
grep -q "export function withTenantWhere" apps/hub/src/lib/tenant.ts || fail "withTenantWhere not exported"

# 3) Prisma contract: must have a tenant scope declaration file
# This avoids guessing which models are tenant-scoped (no redesign).
test -f docs/tenant-scope.md || fail "missing docs/tenant-scope.md (declare tenant-scoped models + invariants)"

# 4) If prisma schema exists in hub, ensure tenantId appears at least once OR a documented plan exists.
if [ -f apps/hub/prisma/schema.prisma ]; then
  if ! grep -q "tenantId" apps/hub/prisma/schema.prisma; then
    grep -q "SCHEMA_TENANTID_PLANNED" docs/tenant-scope.md || fail "schema.prisma missing tenantId and no documented plan in docs/tenant-scope.md"
  fi
fi

pass
