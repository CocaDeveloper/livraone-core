#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://hub.livraone.com}"
TIMEOUT_SEC="${TIMEOUT_SEC:-15}"

pass(){ echo "PASS: $*"; }
fail(){ echo "FAIL: $*" >&2; exit 1; }

curl_head(){
  local url="$1"
  curl -sS -o /dev/null -D - -m "$TIMEOUT_SEC" "$url" | head -n 5
}

curl_get(){
  local url="$1"
  curl -sS -m "$TIMEOUT_SEC" "$url"
}

health=$(curl_get "$BASE_URL/api/health" || true)
if echo "$health" | rg -q '"ok"\s*:\s*true'; then
  pass "health ok"
else
  fail "health failed"
fi

if curl_head "$BASE_URL/dashboard" | rg -q " 302"; then
  pass "dashboard redirect"
else
  fail "dashboard not redirecting"
fi

if curl_head "https://livraone.com" | rg -q " 200| 301| 302"; then
  pass "livraone.com ok"
else
  fail "livraone.com failed"
fi

if curl_head "https://www.livraone.com" | rg -q " 200| 301| 302"; then
  pass "www.livraone.com ok"
else
  fail "www.livraone.com failed"
fi

if curl_head "https://photos.livraone.com" | rg -q " 200| 301| 302"; then
  pass "photos.livraone.com ok"
else
  fail "photos.livraone.com failed"
fi

if curl_head "https://invoice.livraone.com" | rg -q " 200| 301| 302"; then
  pass "invoice.livraone.com ok"
else
  fail "invoice.livraone.com failed"
fi
