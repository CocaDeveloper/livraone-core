#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

fail(){ echo "FAIL: $*" >&2; exit 1; }

[[ -f apps/hub/middleware.ts ]] || fail "middleware missing"
[[ -f apps/hub/app/api/auth/[...nextauth]/route.ts ]] || fail "nextauth route missing"
[[ -f apps/hub/app/api/health/route.ts ]] || fail "health route missing"
[[ -f apps/hub/app/login/page.tsx ]] || fail "login page missing"
[[ -f apps/hub/app/logout/page.tsx ]] || fail "logout page missing"

echo "auth contract OK"
