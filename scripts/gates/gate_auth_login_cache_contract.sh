#!/usr/bin/env bash
set -euo pipefail

fail(){ echo "FAIL: $*" >&2; exit 1; }

hub_page="apps/hub/app/login/page.tsx"
marketing_page="apps/marketing/app/login/page.tsx"
hub_config="apps/hub/next.config.js"
marketing_config="apps/marketing/next.config.js"

[[ -f "$hub_page" ]] || fail "missing $hub_page"
[[ -f "$marketing_page" ]] || fail "missing $marketing_page"
[[ -f "$hub_config" ]] || fail "missing $hub_config"
[[ -f "$marketing_config" ]] || fail "missing $marketing_config"

grep -q 'export const dynamic = "force-dynamic"' "$hub_page" || fail "hub login must force-dynamic"
grep -q 'export const revalidate = 0' "$hub_page" || fail "hub login must disable revalidate"
grep -q 'source: "/login"' "$hub_config" || fail "hub next config missing /login headers"
grep -q 'Cache-Control' "$hub_config" || fail "hub next config missing cache-control header"

grep -q 'export const dynamic = "force-dynamic"' "$marketing_page" || fail "marketing login must force-dynamic"
grep -q 'export const revalidate = 0' "$marketing_page" || fail "marketing login must disable revalidate"
grep -q 'source: "/login"' "$marketing_config" || fail "marketing next config missing /login headers"
grep -q 'name="loginHint"' "$marketing_page" || fail "marketing login must pass loginHint to hub"

echo "PASS"
