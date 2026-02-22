#!/usr/bin/env bash
set -euo pipefail
EVID="${EVID:-/tmp/livraone-entitlement-gate/evidence}"
mkdir -p "$EVID"
LOG="$EVID/run.log"
RES="$EVID/result.txt"
exec > >(tee -a "$LOG") 2>&1

fail(){ echo "FAIL: $*" | tee "$RES" >/dev/null; exit 0; }
pass(){ echo "PASS: $*" | tee "$RES" >/dev/null; exit 0; }

REPO="$(git rev-parse --show-toplevel)"
cd "$REPO"

if find . -maxdepth 8 -type f \( -name ".env" -o -name "*.env" \) | head -n 1 | grep -q .; then
  fail ".env-like file found"
fi
if rg -n --hidden --glob "!.git/*" --glob "!docs/**" --glob "!**/*.md" "^\s*env_file\s*:" . >/dev/null 2>&1; then
  rg -n --hidden --glob "!.git/*" --glob "!docs/**" --glob "!**/*.md" "^\s*env_file\s*:" . > "$EVID/env_file.runtime.matches.txt" || true
  fail "env_file found in runtime config"
fi

HUB=""
for p in apps/hub apps/web-hub apps/hub-web apps/app-hub; do
  if [ -d "$p" ] && [ -f "$p/package.json" ]; then HUB="$p"; break; fi
done
test -n "$HUB" || fail "hub root not found"

SCHEMA=""
for s in "$HUB/prisma/schema.prisma" "$HUB/schema.prisma" "prisma/schema.prisma"; do
  if [ -f "$s" ]; then SCHEMA="$s"; break; fi
done
test -n "$SCHEMA" || fail "schema.prisma not found"

rg -n "model Tenant|model Membership|model Subscription|model Entitlement|enum SubscriptionStatus" "$SCHEMA" \
  > "$EVID/prisma.models.txt" || fail "entitlement prisma models missing"

test -f "$HUB/app/post-auth/page.tsx" || fail "missing hub /post-auth"
rg -n "ensureTenantAndEntitlements|getServerSession" "$HUB/app/post-auth/page.tsx" \
  > "$EVID/postauth.contract.txt" || fail "/post-auth not wired to entitlement service"

if [ -d "$HUB/prisma/migrations" ]; then
  ls -la "$HUB/prisma/migrations" > "$EVID/migrations.ls.txt" 2>&1 || true
else
  fail "missing prisma/migrations (expected migration committed)"
fi

pass "entitlement contract gate PASS"
