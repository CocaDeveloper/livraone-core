#!/usr/bin/env bash
set -euo pipefail

# Contract:
# - marketing login must not link to /api/auth/signin/keycloak
# - marketing login should send users to the Hub auth entrypoint
# - hub must have apps/hub/app/login/page.tsx bootstrap

fail(){ echo "FAIL: $*" >&2; exit 1; }

# hub bootstrap exists
[[ -f apps/hub/app/login/page.tsx ]] || fail "missing hub login bootstrap page"

# marketing login must not reference nextauth direct signin
ml="$(cat /tmp/phase52_marketing_login_file.txt 2>/dev/null || true)"
if [ -z "$ml" ] || [ ! -f "$ml" ] || [[ "$ml" == *"/.next/"* ]]; then
  # deterministic fallback for marketing app
  if [ -f apps/marketing/app/login/page.tsx ]; then
    ml="apps/marketing/app/login/page.tsx"
  else
    fail "missing marketing login file (no marker and apps/marketing/app/login/page.tsx not found)"
  fi
fi

grep -qE 'hub\.livraone\.com/(login|api/auth/start/keycloak)' "$ml" || fail "marketing login does not link to a supported hub auth entrypoint"
if grep -qE 'api/auth/signin/keycloak' "$ml"; then
  fail "marketing login still references /api/auth/signin/keycloak"
fi

echo "PASS"
