#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://hub.livraone.com}"
TIMEOUT_SEC="${TIMEOUT_SEC:-15}"

pass(){ echo "PASS: $*"; }
fail(){ echo "FAIL: $*" >&2; exit 1; }

tmp_files=()
cleanup(){
  if [[ "${#tmp_files[@]}" -gt 0 ]]; then
    rm -f "${tmp_files[@]}"
  fi
}
trap cleanup EXIT

track_tmp(){
  local path
  path="$(mktemp)"
  tmp_files+=("$path")
  printf '%s\n' "$path"
}

curl_head(){
  local url="$1"
  curl -sS -o /dev/null -D - -m "$TIMEOUT_SEC" "$url" | head -n 5
}

curl_get(){
  local url="$1"
  curl -sS -m "$TIMEOUT_SEC" "$url"
}

curl_headers(){
  local url="$1"
  curl -sS -D - -o /dev/null -m "$TIMEOUT_SEC" "$url"
}

health=$(curl_get "$BASE_URL/api/health" || true)
if echo "$health" | rg -q '"ok"\s*:\s*true'; then
  pass "health ok"
else
  fail "health failed"
fi

auth_providers=$(curl_get "$BASE_URL/api/auth/providers" || true)
if echo "$auth_providers" | rg -q '"keycloak"\s*:'; then
  pass "auth providers ok"
else
  fail "auth providers failed"
fi

hub_login_headers="$(curl_headers "$BASE_URL/login" || true)"
if echo "$hub_login_headers" | rg -qi '^cache-control: .*no-store'; then
  pass "hub login no-store"
else
  fail "hub login cache-control failed"
fi

if echo "$hub_login_headers" | rg -qi '^x-nextjs-prerender:'; then
  fail "hub login still prerendered"
else
  pass "hub login dynamic"
fi

cookie_jar="$(track_tmp)"
csrf_json="$(curl -sS -c "$cookie_jar" -m "$TIMEOUT_SEC" "$BASE_URL/api/auth/csrf" || true)"
csrf_token="$(printf '%s' "$csrf_json" | sed -n 's/.*"csrfToken":"\([^"]*\)".*/\1/p' | head -n1)"
if [[ -n "$csrf_token" ]]; then
  pass "auth csrf ok"
else
  fail "auth csrf failed"
fi

signin_headers="$(track_tmp)"
curl -sS -o /dev/null -D "$signin_headers" -m "$TIMEOUT_SEC" -b "$cookie_jar" -c "$cookie_jar" -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "csrfToken=$csrf_token" \
  --data-urlencode "callbackUrl=$BASE_URL/post-auth" \
  "$BASE_URL/api/auth/signin/keycloak"

if rg -q '^HTTP/.* 302' "$signin_headers" && rg -qi '^location: https://auth\.livraone\.com/realms/livraone/protocol/openid-connect/auth' "$signin_headers"; then
  pass "auth signin redirect"
else
  fail "auth signin redirect failed"
fi

dashboard_headers="$(curl -sS -o /dev/null -D - -m "$TIMEOUT_SEC" "$BASE_URL/dashboard" || true)"
if echo "$dashboard_headers" | rg -q ' 302| 307' && echo "$dashboard_headers" | rg -qi '^location: /login'; then
  pass "dashboard redirect"
else
  fail "dashboard not redirecting"
fi

if curl_head "https://livraone.com" | rg -q " 200| 301| 302"; then
  pass "livraone.com ok"
else
  fail "livraone.com failed"
fi

marketing_login_headers="$(curl_headers "https://livraone.com/login" || true)"
if echo "$marketing_login_headers" | rg -qi '^cache-control: .*no-store'; then
  pass "marketing login no-store"
else
  fail "marketing login cache-control failed"
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
