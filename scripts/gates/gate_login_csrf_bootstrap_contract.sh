#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

f="apps/hub/app/login/LoginPageClient.tsx"
[[ -f "$f" ]] || f="apps/hub/app/login/page.tsx"
[[ -f "$f" ]] || fail "missing login bootstrap implementation"

grep -qE "fetch\(['\"]/api/auth/csrf['\"].*credentials:\\s*['\"]include['\"]" "$f" \
  || fail "login missing csrf bootstrap fetch with credentials: include"

csrf_line=$(grep -nE "fetch\(['\"]/api/auth/csrf" "$f" | head -n1 | cut -d: -f1 || true)
signin_line=$(grep -nE "\\bsignIn\\(" "$f" | head -n1 | cut -d: -f1 || true)
[[ -n "${csrf_line:-}" && -n "${signin_line:-}" ]] || fail "missing csrf fetch or signIn"
if [[ "$csrf_line" -gt "$signin_line" ]]; then
  fail "csrf bootstrap must appear before signIn in source order"
fi

echo "PASS"
