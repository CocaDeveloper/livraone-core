#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

test -f docs/rbac-matrix.md || fail "missing docs/rbac-matrix.md"
test -f docs/rbac-matrix.json || fail "missing docs/rbac-matrix.json"
test -f apps/hub/src/lib/rbac.ts || fail "missing apps/hub/src/lib/rbac.ts"
test -f apps/hub/src/lib/rbac.contract.test.ts || fail "missing apps/hub/src/lib/rbac.contract.test.ts"

grep -q "export function hasPermission" apps/hub/src/lib/rbac.ts || fail "hasPermission not exported"
grep -q "export function assertPermission" apps/hub/src/lib/rbac.ts || fail "assertPermission not exported"

# Matrix sanity (no jq dependency): ensure grants exists + wildcard owner
grep -q '"grants"' docs/rbac-matrix.json || fail "rbac-matrix.json missing grants"
grep -q '"owner"[[:space:]]*:[[:space:]]*\[[^]]*"\*"' docs/rbac-matrix.json || fail "owner must have wildcard grant (*)"

pass
