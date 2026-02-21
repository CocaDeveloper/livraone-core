#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-${1:-}}"
TIMEOUT_SEC="${TIMEOUT_SEC:-30}"
RETRIES=5
SLEEP_SEC=3

fail(){ echo "FAIL: $*"; exit 1; }

if [[ -z "$BASE_URL" ]]; then
  fail "BASE_URL required"
fi

ok_tls=0
for i in $(seq 1 "$RETRIES"); do
  code=$(curl -sS -o /dev/null -w '%{http_code}' -I --max-time "$TIMEOUT_SEC" "$BASE_URL" || true)
  if [[ -n "$code" && "$code" != "000" ]]; then
    ok_tls=1
    break
  fi
  sleep "$SLEEP_SEC"
done
[[ "$ok_tls" -eq 1 ]] || fail "TLS/DNS check failed"

health_url="${BASE_URL%/}/api/health"
health_body=$(curl -sS --max-time "$TIMEOUT_SEC" "$health_url" || true)
health_code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time "$TIMEOUT_SEC" "$health_url" || true)
if [[ "$health_code" != "200" ]]; then
  fail "health endpoint HTTP $health_code"
fi
if ! printf '%s' "$health_body" | rg -q '"ok"\s*:\s*true|"status"\s*:\s*"ok"'; then
  fail "health endpoint payload mismatch"
fi

root_code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time "$TIMEOUT_SEC" "$BASE_URL" || true)
if [[ "$root_code" != "200" ]]; then
  echo "WARN: root HTTP $root_code"
fi

echo "PASS: smoke"
