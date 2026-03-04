#!/usr/bin/env bash
set -euo pipefail

TS=$(date +%Y%m%d-%H%M%S)
EVID="/srv/livraone/evidence/auth-e2e-$TS"
mkdir -p "$EVID"

log(){ echo "[$(date -Is)] $*"; }
# Redact cookie values but preserve attributes (domain/path/samesite/secure).
redact_cookies(){
  sed -E 's/^([Ss]et-[Cc]ookie: [^=]+=)[^;]*(;.*)?$/\1[REDACTED]\2/';
}

log "Collecting hub/traefik logs (last 10m)"
docker logs hub --since 10m > "$EVID/hub_logs_10m.txt" 2>&1 || true
docker logs traefik --since 10m > "$EVID/traefik_logs_10m.txt" 2>&1 || true

log "Collecting headers (sanitized)"
curl -sS -D - -o /dev/null https://hub.livraone.com/login \
  | redact_cookies > "$EVID/login_headers.txt" || true
curl -sS -D - -o /dev/null https://hub.livraone.com/api/auth/signin/keycloak \
  | redact_cookies > "$EVID/signin_keycloak_headers.txt" || true
curl -sS -D - -o /dev/null "https://hub.livraone.com/api/auth/callback/keycloak" \
  | redact_cookies > "$EVID/callback_keycloak_headers.txt" || true

log "Collecting OAuth init headers (POST /api/auth/signin/keycloak)"
cookie_jar="$(mktemp)"
csrf_json="$(curl -sS -c "$cookie_jar" https://hub.livraone.com/api/auth/csrf || true)"
csrf_token="$(printf '%s' "$csrf_json" | sed -n 's/.*"csrfToken":"\([^"]*\)".*/\1/p' | head -n1)"
if [ -n "$csrf_token" ]; then
  curl -sS -D - -o /dev/null -b "$cookie_jar" -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data "csrfToken=${csrf_token}&callbackUrl=https%3A%2F%2Fhub.livraone.com%2Fpost-auth" \
    https://hub.livraone.com/api/auth/signin/keycloak \
    | redact_cookies > "$EVID/signin_keycloak_post_headers.txt" || true
else
  echo "csrfToken missing (skipped POST signin capture)" > "$EVID/signin_keycloak_post_headers.txt"
fi
rm -f "$cookie_jar"

log "Writing sha256 manifest"
(
  cd "$EVID"
  find . -type f ! -name sha256.txt -print0 | sort -z | xargs -0 sha256sum > sha256.txt
)

log "EVIDENCE: $EVID"
