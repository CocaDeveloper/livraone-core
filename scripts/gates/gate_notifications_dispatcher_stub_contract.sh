#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS"; }

# Contract files
test -f docs/notifications-policy.md || fail "missing docs/notifications-policy.md"
test -f apps/hub/src/lib/notifications/types.ts || fail "missing notifications types"
test -f apps/hub/src/lib/notifications/policy.ts || fail "missing notifications policy"
test -f apps/hub/src/lib/notifications/dispatcher.ts || fail "missing notifications dispatcher"
test -f apps/hub/src/lib/notifications/outbox.ts || fail "missing notifications outbox"
test -f apps/hub/src/lib/notifications/index.ts || fail "missing notifications index"
test -f apps/hub/src/lib/notifications/contract.test.ts || fail "missing notifications contract test"

grep -q "export async function dispatchNotification" apps/hub/src/lib/notifications/dispatcher.ts || fail "dispatchNotification not exported"
grep -q "assertNotificationsProviderIsStub" apps/hub/src/lib/notifications/policy.ts || fail "policy guard missing"

# Block live provider SDK imports inside hub (allow docs mentions)
PATTERN="(from ['\"]nodemailer['\"]|require\\(['\"]nodemailer['\"]\\)|from ['\"]@sendgrid/|from ['\"]twilio['\"]|require\\(['\"]twilio['\"]\\)|from ['\"]aws-sdk['\"]|from ['\"]@aws-sdk/|from ['\"]postmark['\"]|require\\(['\"]postmark['\"]\\))"
if command -v rg >/dev/null 2>&1; then
  if rg -n --glob '!**/*.md' --glob '!**/*.mdx' --glob '!**/node_modules/**' "$PATTERN" apps/hub >/dev/null; then
    rg -n --glob '!**/*.md' --glob '!**/*.mdx' --glob '!**/node_modules/**' "$PATTERN" apps/hub || true
    fail "live notifications sdk import detected in apps/hub (stub-only policy)"
  fi
else
  if grep -R --line-number --exclude-dir=node_modules --exclude='*.md' --exclude='*.mdx' -E "$PATTERN" apps/hub >/dev/null 2>&1; then
    grep -R --line-number --exclude-dir=node_modules --exclude='*.md' --exclude='*.mdx' -E "$PATTERN" apps/hub || true
    fail "live notifications sdk import detected in apps/hub (stub-only policy)"
  fi
fi

# SSOT provider vars: if present must be stub (do not print secrets).
# In CI, /etc/livraone/hub.env may be absent; fall back to env vars if provided.
SSOT="/etc/livraone/hub.env"

check_stub_var() {
  local key="$1"
  local v=""
  if [ -f "$SSOT" ] && grep -qE "^${key}=" "$SSOT"; then
    v="$(grep -E "^${key}=" "$SSOT" | tail -n1 | cut -d= -f2- | tr -d '\r' | tr '[:upper:]' '[:lower:]')"
  else
    v="$(printenv "$key" 2>/dev/null | tr '[:upper:]' '[:lower:]')"
  fi
  if [ -n "$v" ] && [ "$v" != "stub" ]; then
    fail "${key} must be stub when set"
  fi
}

check_stub_var "NOTIFICATIONS_PROVIDER"
check_stub_var "EMAIL_PROVIDER"
check_stub_var "SMS_PROVIDER"

pass
