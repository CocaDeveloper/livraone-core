#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core
ENV_FILE=".env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "$ENV_FILE missing" >&2
  exit 1
fi
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a
if [[ -z "${KEYCLOAK_HUB_SECRET:-}" ]]; then
  echo "KEYCLOAK_HUB_SECRET is required" >&2
  exit 1
fi

TOKEN_URL="https://auth.livraone.com/realms/livraone/protocol/openid-connect/token"
payload_file=$(mktemp)
trap 'rm -f "$payload_file"' EXIT
http_code=$(curl -sS -o "$payload_file" -w '%{http_code}' \
  -X POST "$TOKEN_URL" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d client_id=hub-web \
  -d client_secret="$KEYCLOAK_HUB_SECRET" \
  -d username=test.user \
  -d password=Test@12345 \
  -d grant_type=password)
if [[ "$http_code" != "200" ]]; then
  echo "token endpoint returned $http_code" >&2
  cat "$payload_file" >&2
  exit 1
fi
response=$(cat "$payload_file")
printf 'DEBUG RESPONSE=%s\n' "$response"
access_token=$(python3 - "$payload_file" <<'PY'
import json, sys

path = sys.argv[1]
with open(path) as fp:
    data = json.load(fp)
print(data["access_token"])
PY
)

ACCESS_TOKEN="$access_token" python3 - <<'PY'
import base64, json
import os

allowed_issuers = {
    'https://auth.livraone.com/realms/livraone',
    'http://auth.livraone.com/realms/livraone'
}
iss_expected = 'https://auth.livraone.com/realms/livraone'
token = os.environ.get('ACCESS_TOKEN', '').strip()
parts = token.split('.')
if len(parts) < 2:
    raise SystemExit('token format invalid')
payload = parts[1]
payload += '=' * (-len(payload) % 4)
data = json.loads(base64.urlsafe_b64decode(payload))
if data.get('iss') not in allowed_issuers:
    raise SystemExit(f"unexpected issuer {data.get('iss')}")
if data.get('iss') == 'http://auth.livraone.com/realms/livraone':
    print('WARNING: issuer is http; consider setting KEYCLOAK_FRONTEND_URL=https://auth.livraone.com to align with TLS')
roles = data.get('realm_access', {}).get('roles', [])
if 'user' not in roles:
    raise SystemExit(f"role 'user' missing, got {roles}")
print('Auth E2E gate OK')
PY
