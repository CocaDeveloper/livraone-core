#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core

check_unauthorized() {
  status=$(curl -s -o /dev/null -w "%{http_code}" https://hub.livraone.com/api/admin/ping)
  if [[ "$status" != "401" && "$status" != "403" ]]; then
    echo "Expected 401/403 without auth but got $status" >&2
    exit 1
  fi
}

check_authorized() {
  local token=$1
  status=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $token" https://hub.livraone.com/api/admin/ping)
  if [[ "$status" != "200" ]]; then
    echo "Expected 200 with admin token but got $status" >&2
    exit 1
  fi
}

check_unauthorized

if [[ -n "${HUB_ADMIN_EMAIL:-}" ]] && [[ -n "${HUB_ADMIN_PASSWORD:-}" ]] && [[ -n "${HUB_AUTH_CLIENT_SECRET:-}" ]]; then
  response=$(curl -s -X POST https://auth.livraone.com/realms/livraone/protocol/openid-connect/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d client_id=hub-web \
    -d client_secret="$HUB_AUTH_CLIENT_SECRET" \
    -d username="$HUB_ADMIN_EMAIL" \
    -d password="$HUB_ADMIN_PASSWORD" \
    -d grant_type=password)
  token=$(printf '%s' "$response" | python3 - <<'PY'
import json, os, sys
payload=json.loads(sys.stdin.read())
print(payload.get("access_token",""))
PY
)
  if [[ -z "$token" ]]; then
    echo "unable to retrieve admin token" >&2
    exit 1
  fi
  check_authorized "$token"
fi

echo "Hub RBAC gate OK"
