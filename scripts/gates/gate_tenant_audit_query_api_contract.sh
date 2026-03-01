#!/usr/bin/env bash
set -euo pipefail

fail(){ echo "FAIL: $*"; exit 1; }
pass(){ echo "PASS"; }

have_rg(){ command -v rg >/dev/null 2>&1; }
scanq(){
  local pat="$1" file="$2"
  if have_rg; then rg -n "$pat" "$file" >/dev/null
  else grep -nE "$pat" "$file" >/dev/null
  fi
}

ROUTE="$1"
test -f "$ROUTE" || fail "missing audit route: $ROUTE"

# Must enforce tenant scope (where includes tenantId)
if ! scanq 'where:\s*\{[^}]*tenantId' "$ROUTE" && ! scanq 'where\s*:\s*any\s*=\s*\{[^}]*tenantId' "$ROUTE" && ! scanq 'const\s+where[^=]*=\s*\{[^}]*tenantId' "$ROUTE"; then
  fail "route must scope query by tenantId in where"
fi

# Must enforce RBAC (Forbidden 403)
scanq 'Forbidden"\s*,\s*\{\s*status:\s*403' "$ROUTE" || fail "route must return 403 Forbidden on RBAC failure"

# Must query via prisma findMany (audit log read)
scanq 'findMany\(' "$ROUTE" || fail "route must query with findMany"

# Must not be anonymous (401 path)
scanq 'Unauthorized"\s*,\s*\{\s*status:\s*401' "$ROUTE" || fail "route must return 401 for unauth"

pass
