#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*"; exit 1; }
pass(){ echo "PASS"; }
have_rg(){ command -v rg >/dev/null 2>&1; }
scanq(){ local pat="$1" file="$2"; if have_rg; then rg -n "$pat" "$file" >/dev/null; else grep -nE "$pat" "$file" >/dev/null; fi; }

HELPER="$1"
ROOT="$2"

test -f "$HELPER" || fail "missing rate limiter helper: $HELPER"
scanq 'RATE_LIMIT_ENABLED' "$HELPER" || fail "helper must be flag-controlled via RATE_LIMIT_ENABLED"
scanq 'Too Many Requests' "$ROOT" || true

# require at least one usage reference in hub API code
if have_rg; then
  rg -n 'getRateLimitConfigFromEnv|rateLimitAllowOrThrow' apps/hub >/dev/null || fail "expected at least one rate limit usage in apps/hub"
  rg -n 'status:\s*429|status\s*==\s*429|429' apps/hub >/dev/null || fail "expected 429 response handling in apps/hub"
else
  grep -RInE 'getRateLimitConfigFromEnv|rateLimitAllowOrThrow' apps/hub >/dev/null || fail "expected at least one rate limit usage in apps/hub"
  grep -RInE 'status:\s*429|429' apps/hub >/dev/null || fail "expected 429 response handling in apps/hub"
fi

pass
