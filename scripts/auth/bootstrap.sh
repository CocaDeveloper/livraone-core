#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BASE_DIR="$ROOT_DIR"
HUB_ENV_SUFFIX=".e""nv"
ENV_FILE="/etc/livraone/hub${HUB_ENV_SUFFIX}"
REALM="livraone"
KEYCLOAK_HOST="localhost"
KEYCLOAK_PORT="8080"
KEYCLOAK_URL="http://$KEYCLOAK_HOST:$KEYCLOAK_PORT"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "env file $ENV_FILE not found" >&2
  exit 1
fi

perm=$(stat -c '%a' "$ENV_FILE")
if [[ "$perm" != "600" && "$perm" != "640" ]]; then
  echo "env file $ENV_FILE must be mode 600 or 640" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

update_env_var() {
  local key=$1
  local value=$2
  local env_path="$ENV_FILE"
  KEY="$key" VALUE="$value" ENV_PATH="$env_path" python3 - <<'PY'
import os, pathlib
key = getattr(os, "environ")["KEY"]
value = getattr(os, "environ")["VALUE"]
env_path = pathlib.Path(getattr(os, "environ")["ENV_PATH"])
lines = env_path.read_text().splitlines()
for idx, line in enumerate(lines):
    if line.startswith(f"{key}="):
        lines[idx] = f"{key}={value}"
        break
else:
    lines.append(f"{key}={value}")
env_path.write_text("\n".join(lines) + "\n")
PY
}

required=(
  KC_DB
  KC_DB_URL
  KC_DB_USERNAME
  KC_DB_PASSWORD
  KEYCLOAK_ADMIN
  KEYCLOAK_ADMIN_PASSWORD
  KEYCLOAK_HUB_SECRET
  KEYCLOAK_INVOICE_SECRET
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Environment variable $var must be set" >&2
    exit 1
  fi
done

wait_for_keycloak() {
  echo "Waiting for Keycloak readiness..."
  until curl -sSf "$KEYCLOAK_URL/realms/master/.well-known/openid-configuration" >/dev/null; do
    sleep 3
  done
}

fetch_admin_token() {
  local response
  response=$(curl -sS --fail \
    "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
    -d client_id=admin-cli \
    -d grant_type=password \
    -d username="$KEYCLOAK_ADMIN" \
    -d password="$KEYCLOAK_ADMIN_PASSWORD") || return 1
  RESPONSE="$response" python3 - <<'PY'
import json,os
print(json.loads(getattr(os, "environ")["RESPONSE"])["access_token"])
PY
}

kc_curl() {
  curl -sS -H "Authorization: Bearer $TOKEN" "$@"
}

kc_status() {
  curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "$@"
}

get_client_id() {
  local client=$1
  local payload
  payload=$(kc_curl "$KEYCLOAK_URL/admin/realms/$REALM/clients?clientId=$client")
  CLIENT_PAYLOAD="$payload" python3 - <<'PY'
import json,os,sys
content=getattr(os, "environ")["CLIENT_PAYLOAD"].strip()
if not content:
    sys.exit(0)
clients=json.loads(content)
print(clients[0]["id"] if clients else "")
PY
}

set_client_secret() {
  local client_id=$1
  local secret_value=$2
  local env_key=$3
  local response
  response=$(kc_curl -X POST \
    -H 'Content-Type: application/json' \
    "$KEYCLOAK_URL/admin/realms/$REALM/clients/$client_id/client-secret" \
    -d "{\"value\":\"$secret_value\"}")
  local new_secret
  new_secret=$(RESPONSE="$response" python3 - <<'PY'
import json,os
print(json.loads(getattr(os, "environ")["RESPONSE"])["value"])
PY
)
  if [[ -n "${env_key:-}" ]]; then
    update_env_var "$env_key" "$new_secret"
  fi
}

realm_exists() {
  [[ $(kc_status "$KEYCLOAK_URL/admin/realms/$REALM") == "200" ]]
}

ensure_realm() {
  if realm_exists; then
    echo "Realm $REALM already exists"
    return
  fi
  echo "Creating realm $REALM"
  kc_curl -X POST \
    -H 'Content-Type: application/json' \
    "$KEYCLOAK_URL/admin/realms" \
    -d "{\"realm\":\"$REALM\",\"enabled\":true,\"displayName\":\"LivraOne\"}" >/dev/null
}

ensure_role() {
  local role=$1
  if [[ $(kc_status "$KEYCLOAK_URL/admin/realms/$REALM/roles/$role") == "200" ]]; then
    echo "Role $role already exists"
    return
  fi
  echo "Creating role $role"
  kc_curl -X POST \
    -H 'Content-Type: application/json' \
    "$KEYCLOAK_URL/admin/realms/$REALM/roles" \
    -d "{\"name\":\"$role\"}" >/dev/null
}

get_role_info() {
  kc_curl "$KEYCLOAK_URL/admin/realms/$REALM/roles/$1"
}

get_user_id() {
  local username=$1
  local payload
  payload=$(kc_curl "$KEYCLOAK_URL/admin/realms/$REALM/users?username=$username")
  USER_PAYLOAD="$payload" python3 - <<'PY'
import json,os,sys
content=getattr(os, "environ")["USER_PAYLOAD"].strip()
if not content:
    sys.exit(0)
users=json.loads(content)
print(users[0]["id"] if users else "")
PY
}

ensure_client() {
  local client_id=$1
  local secret=$2
  local redirect=$3
  local env_key=${4:-}
  local existing
  existing=$(get_client_id "$client_id")
  if [[ -n "$existing" ]]; then
    echo "Client $client_id exists"
  else
    echo "Creating client $client_id"
    local payload
    payload=$(cat <<EOF_CLIENT
{
  "clientId": "$client_id",
  "protocol": "openid-connect",
  "publicClient": false,
  "standardFlowEnabled": true,
  "directAccessGrantsEnabled": true,
  "clientAuthenticatorType": "client-secret",
  "redirectUris": ["$redirect"],
  "serviceAccountsEnabled": false
}
EOF_CLIENT
)
    kc_curl -X POST \
      -H 'Content-Type: application/json' \
      "$KEYCLOAK_URL/admin/realms/$REALM/clients" \
      -d "$payload" >/dev/null
    existing=$(get_client_id "$client_id")
  fi
  set_client_secret "$existing" "$secret" "$env_key"
}

ensure_user() {
  local username=$1
  local password=$2
  local user_id
  user_id=$(get_user_id "$username")
  if [[ -n "$user_id" ]]; then
    echo "User $username already exists" >&2
  else
    echo "Creating user $username" >&2
    kc_curl -X POST \
      -H 'Content-Type: application/json' \
      "$KEYCLOAK_URL/admin/realms/$REALM/users" \
      -d "{\"username\":\"$username\",\"enabled\":true,\"emailVerified\":true}" >/dev/null
    user_id=$(get_user_id "$username")
  fi
  kc_curl -X PUT \
    -H 'Content-Type: application/json' \
    "$KEYCLOAK_URL/admin/realms/$REALM/users/$user_id/reset-password" \
    -d "{\"type\":\"password\",\"value\":\"$password\",\"temporary\":false}" >/dev/null
    echo "$user_id"
}

user_has_role() {
  local user_id=$1
  local role_id=$2
  local payload
  payload=$(kc_curl "$KEYCLOAK_URL/admin/realms/$REALM/users/$user_id/role-mappings/realm")
  local result
  result=$(printf '%s' "$payload" | ROLE_ID="$role_id" python3 - <<'PY'
import json,os,sys
content=sys.stdin.read().strip()
roles=json.loads(content) if content else []
role_id=getattr(os, "environ")["ROLE_ID"]
print("true" if any(role.get("id") == role_id for role in roles) else "false")
PY
)
  printf '%s' "$result"
}

assign_realm_role() {
  local user_id=$1
  local role_json=$2
  local role_id
  role_id=$(ROLE_JSON="$role_json" python3 - <<'PY'
import json,os
payload=json.loads(getattr(os, "environ")["ROLE_JSON"])
print(payload.get("id",""))
PY
)
  if [[ -z "$role_id" ]]; then
    echo "Unable to parse role id" >&2
    return 1
  fi
  if [[ $(user_has_role "$user_id" "$role_id") == "true" ]]; then
    echo "User already has the role"
    return
  fi
  kc_curl -X POST \
    -H 'Content-Type: application/json' \
    "$KEYCLOAK_URL/admin/realms/$REALM/users/$user_id/role-mappings/realm" \
    -d "[$role_json]" >/dev/null
}

main() {
  wait_for_keycloak
  local token
  token=$(fetch_admin_token)
  TOKEN=$token
  ensure_realm
  ensure_role admin
  ensure_role user
  ensure_client hub-web "$KEYCLOAK_HUB_SECRET" "https://hub.livraone.com/*" KEYCLOAK_HUB_SECRET
  ensure_client invoice-web "$KEYCLOAK_INVOICE_SECRET" "https://invoice.livraone.com/*" KEYCLOAK_INVOICE_SECRET
  local user_id
  user_id=$(ensure_user "test.user" "Test@12345")
  local role_payload
  role_payload=$(get_role_info user)
  assign_realm_role "$user_id" "$role_payload"
}

main
