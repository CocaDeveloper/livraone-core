#!/usr/bin/env bash
set -euo pipefail
ROUTE="apps/hub/app/api/admin/attribution/export/route.ts"
EVI_DIR="${EVI_DIR:-/tmp/livraone-gate-attribution-export-contract}"
mkdir -p "$EVI_DIR"
fail(){ echo "FAIL: $*" | tee "$EVI_DIR/fail.txt" >&2; exit 1; }

test -f "$ROUTE" || fail "missing route"
grep -q "export async function GET" "$ROUTE" || fail "missing GET handler"
grep -qi "text/csv" "$ROUTE" || fail "missing content-type text/csv"
grep -qi "content-disposition" "$ROUTE" || fail "missing content-disposition header"
grep -q "livraone_attribution_export.csv" "$ROUTE" || fail "missing expected filename"
grep -qi "cache-control" "$ROUTE" || fail "missing cache-control header"
grep -q "no-store" "$ROUTE" || fail "missing no-store directive"
grep -q "requireAdminOrMasterEmail" "$ROUTE" || fail "missing admin guard call"
echo "PASS" | tee "$EVI_DIR/pass.txt"
