#!/usr/bin/env bash
set -euo pipefail

EVI_DIR="${EVI_DIR:-/tmp/livraone-gate-admin-client-access-contract}"
mkdir -p "$EVI_DIR"
fail(){ echo "FAIL: $*" | tee "$EVI_DIR/fail.txt" >&2; exit 1; }

need_file(){ test -f "$1" || fail "missing $1"; }

# Core artifacts must exist
need_file "docs/PANEL_ACCESS_CONTRACT.md"
need_file "apps/hub/lib/auth/admin_guard.ts"
need_file "apps/hub/app/api/admin/attribution/export/route.ts"
need_file "apps/hub/lib/providers/index.ts"

ROUTE="apps/hub/app/api/admin/attribution/export/route.ts"
GUARD="apps/hub/lib/auth/admin_guard.ts"

# Route must have GET handler + CSV contract markers
grep -q "export async function GET" "$ROUTE" || fail "route missing GET handler"
grep -qi "text/csv" "$ROUTE" || fail "route missing content-type text/csv"
grep -qi "content-disposition" "$ROUTE" || fail "route missing content-disposition header"
grep -qi "cache-control" "$ROUTE" || fail "route missing cache-control header"
grep -q "no-store" "$ROUTE" || fail "route missing no-store directive"

# Must not ship placeholder guard markers
! grep -q "Admin guard not wired" "$ROUTE" || fail "placeholder guard text present"
! grep -q 'throw new Error("Admin guard not wired' "$ROUTE" || fail "placeholder throw present"

# Guard file must export a callable/usable guard symbol (string contract)
# (We don't assume exact function name; we assert it exports something stable.)
grep -Eq "export (async )?function|export const" "$GUARD" || fail "admin_guard has no exports"

# Route should reference the guard module (best-effort contract)
# Accept both relative and alias imports since you hardened import paths earlier.
grep -Eq "admin_guard|assertAdmin|requireAdmin|ensureAdmin" "$ROUTE" || fail "route does not appear to invoke an admin guard"

echo "PASS" | tee "$EVI_DIR/pass.txt"
