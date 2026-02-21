#!/usr/bin/env bash
set -euo pipefail

# Idempotent seed for Keycloak Hub client.
# Runs inside Keycloak container (expects /opt/keycloak/bin/kcadm.sh + admin env vars present).

KC_REALM="${KC_REALM:-livraone}"
CLIENT_ID="${CLIENT_ID:-livraone-hub}"
KC_URL="${KC_URL:-http://localhost:8080}"

REDIRECTS_DEFAULT=(
  "https://hub.livraone.com/*"
  "https://livraone.com/*"
)
WEB_ORIGINS_DEFAULT=(
  "https://hub.livraone.com"
  "https://livraone.com"
)

# Allow override via env JSON arrays (string)
REDIRECTS_JSON="${REDIRECTS_JSON:-}"
WEB_ORIGINS_JSON="${WEB_ORIGINS_JSON:-}"

if [ -z "${REDIRECTS_JSON:-}" ]; then
  REDIRECTS_JSON="$(python3 - <<'PY'
import json
print(json.dumps(["https://hub.livraone.com/*","https://livraone.com/*"]))
PY
)"
fi
if [ -z "${WEB_ORIGINS_JSON:-}" ]; then
  WEB_ORIGINS_JSON="$(python3 - <<'PY'
import json
print(json.dumps(["https://hub.livraone.com","https://livraone.com"]))
PY
)"
fi

ADMIN_USER="${KEYCLOAK_ADMIN:-${KC_BOOTSTRAP_ADMIN_USERNAME:-}}"
ADMIN_PASS="${KEYCLOAK_ADMIN_PASSWORD:-${KC_BOOTSTRAP_ADMIN_PASSWORD:-}}"

[ -n "${ADMIN_USER:-}" ] || { echo "FAIL: missing admin user env (KEYCLOAK_ADMIN or KC_BOOTSTRAP_ADMIN_USERNAME)"; exit 1; }
[ -n "${ADMIN_PASS:-}" ] || { echo "FAIL: missing admin pass env (KEYCLOAK_ADMIN_PASSWORD or KC_BOOTSTRAP_ADMIN_PASSWORD)"; exit 1; }

kcadm="/opt/keycloak/bin/kcadm.sh"
[ -x "$kcadm" ] || { echo "FAIL: kcadm.sh not found at $kcadm"; exit 1; }

"$kcadm" config credentials --server "$KC_URL" --realm master --user "$ADMIN_USER" --password "$ADMIN_PASS" >/dev/null

"$kcadm" get "realms/$KC_REALM" >/dev/null

clients_json="$($kcadm get clients -r "$KC_REALM" -q "clientId=$CLIENT_ID")"

cid="$(python3 - <<'PY'
import json,sys
try:
  d=json.loads(sys.stdin.read())
  print(d[0].get('id',''))
except Exception:
  print('')
PY
<<<"$clients_json")"

if [ -z "${cid:-}" ]; then
  "$kcadm" create clients -r "$KC_REALM" \
    -s "clientId=$CLIENT_ID" \
    -s "enabled=true" \
    -s "protocol=openid-connect" \
    -s "publicClient=false" \
    -s "serviceAccountsEnabled=false" \
    -s "standardFlowEnabled=true" \
    -s "directAccessGrantsEnabled=false" \
    -s "implicitFlowEnabled=false" >/dev/null

  clients_json="$($kcadm get clients -r "$KC_REALM" -q "clientId=$CLIENT_ID")"
  cid="$(python3 - <<'PY'
import json,sys
try:
  d=json.loads(sys.stdin.read())
  print(d[0].get('id',''))
except Exception:
  print('')
PY
<<<"$clients_json")"
fi

[ -n "${cid:-}" ] || { echo "FAIL: client id still empty after create"; exit 1; }

"$kcadm" update "clients/$cid" -r "$KC_REALM" \
  -s "redirectUris=$REDIRECTS_JSON" \
  -s "webOrigins=$WEB_ORIGINS_JSON" >/dev/null

summary_json="$($kcadm get "clients/$cid" -r "$KC_REALM")"

python3 - <<'PY'
import json,sys
try:
  d=json.loads(sys.stdin.read())
  out={k:d.get(k) for k in ["clientId","enabled","publicClient","standardFlowEnabled","redirectUris","webOrigins"]}
  print(json.dumps(out, sort_keys=True))
except Exception:
  print("{}")
PY
<<<"$summary_json"
