#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

# Critical flows that MUST contain appendAudit
CRITICAL_FILES=(
  "apps/hub/src/lib/subscription/store_db.ts"
  "apps/hub/src/lib/membership/create.ts"
)

for file in "${CRITICAL_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    fail "Missing critical file: $file"
  fi

  if ! grep -q "appendAudit" "$file"; then
    fail "appendAudit missing in $file"
  fi
done

# Ensure audit store remains append-only (no delete/update)
if grep -R --line-number -E "deleteAudit|updateAudit|removeAudit" apps/hub/src/lib/audit >/dev/null 2>&1; then
  fail "Audit must remain append-only"
fi

pass
