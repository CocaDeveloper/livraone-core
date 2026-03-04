#!/usr/bin/env bash
set -euo pipefail

REPO="/srv/livraone/livraone-core"
EVID_ROOT="/srv/livraone/evidence"

TS=$(date +%Y%m%d-%H%M%S)
EVID="$EVID_ROOT/auth-loop-debug-$TS"
mkdir -p "$EVID"

log(){ echo "[$(date -Is)] $*"; }

log "Collecting hub/traefik logs (last 30m)"
docker logs hub --since 30m > "$EVID/hub_logs_30m.txt" 2>&1 || true
docker logs traefik --since 30m > "$EVID/traefik_logs_30m.txt" 2>&1 || true

log "Collecting headers"
curl -sS -D "$EVID/hub_root_headers.txt" -o /dev/null https://hub.livraone.com/ || true
curl -sS -D "$EVID/hub_login_headers.txt" -o /dev/null https://hub.livraone.com/login || true
curl -sS -D "$EVID/auth_providers_headers.txt" -o "$EVID/auth_providers_body.json" https://hub.livraone.com/api/auth/providers || true
curl -sS -D "$EVID/auth_csrf_headers.txt" -o "$EVID/auth_csrf_body.json" https://hub.livraone.com/api/auth/csrf || true

log "Checking env presence inside hub container"
docker exec hub sh -lc '
  for k in NEXTAUTH_URL NEXTAUTH_SECRET NEXTAUTH_TRUST_HOST HUB_AUTH_ISSUER HUB_AUTH_CLIENT_ID HUB_AUTH_CALLBACK_URL KEYCLOAK_ISSUER; do
    v=$(printenv "$k" || true)
    if [ -z "$v" ]; then echo "MISSING:$k"; else echo "PRESENT:$k"; fi
  done
' > "$EVID/hub_env_presence.txt" 2>&1 || true

log "Writing sha256 manifest"
(
  cd "$EVID"
  find . -type f ! -name sha256.txt -print0 | sort -z | xargs -0 sha256sum > sha256.txt
)

log "EVIDENCE: $EVID"
