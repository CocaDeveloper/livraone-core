#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

s="scripts/backup/restore_simulation.sh"
[[ -f "$s" ]] || fail "missing $s"
grep -q 'pg_dump --schema-only' "$s" || fail "restore_sim must schema-dump"
grep -q 'postgres:16-alpine' "$s" || fail "restore_sim must use isolated postgres container image"
grep -q 'information_schema.tables' "$s" || fail "restore_sim must verify tables exist"
bash "$s"
echo "PASS"
