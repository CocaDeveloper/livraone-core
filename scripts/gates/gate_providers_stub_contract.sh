#!/usr/bin/env bash
set -euo pipefail
EVI_DIR="${EVI_DIR:-/tmp/livraone-gate-providers-stub}"
mkdir -p "$EVI_DIR"
fail(){ echo "FAIL: $*" | tee "$EVI_DIR/fail.txt" >&2; exit 1; }

test -f "apps/hub/lib/providers/types.ts" || fail "missing providers/types.ts"
test -f "apps/hub/lib/providers/index.ts" || fail "missing providers/index.ts"
test -f "apps/hub/lib/providers/stub.ts" || fail "missing providers/stub.ts"

grep -q "EMAIL_PROVIDER" "apps/hub/lib/providers/index.ts" || fail "missing EMAIL_PROVIDER selection"
grep -q "SMS_PROVIDER" "apps/hub/lib/providers/index.ts" || fail "missing SMS_PROVIDER selection"
grep -q "BILLING_PROVIDER" "apps/hub/lib/providers/index.ts" || fail "missing BILLING_PROVIDER selection"

test -f "docs/SSOT_PROVIDERS_TEMPLATE.md" || fail "missing SSOT providers template doc"

echo "PASS" | tee "$EVI_DIR/pass.txt"
