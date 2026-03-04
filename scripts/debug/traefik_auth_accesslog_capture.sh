#!/usr/bin/env bash
set -euo pipefail

ts(){ date +%Y%m%d-%H%M%S; }
EVID="/srv/livraone/evidence/traefik-auth-accesslog-capture-$(ts)"
mkdir -p "$EVID"

log(){ echo "[$(date -Is)] $*" | tee -a "$EVID/run.log"; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "FAIL: missing $1"; exit 1; }; }

need docker
need curl
need sed
need grep

DURATION="${1:-300}"
COMPOSE="/srv/livraone/livraone-core/infra/compose.yaml"
ACCESS_LOG="/var/log/traefik/access.log"
SSOT="/etc/livraone/hub.env"

if [[ -f "$SSOT" ]]; then
  if [[ "$(stat -c '%a' "$SSOT")" == "600" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$SSOT"
    set +a
  else
    log "WARN: SSOT perms not 600; skipping auto-load"
  fi
fi

log "Resolve Traefik container ID"
TRAEFIK_CID="$(docker compose -f "$COMPOSE" ps -q traefik || true)"
[[ -n "$TRAEFIK_CID" ]] || { log "FAIL: traefik container not found"; exit 1; }
echo "$TRAEFIK_CID" > "$EVID/traefik_cid.txt"

log "Verify access log path exists"
if ! docker exec "$TRAEFIK_CID" sh -lc "[ -f '$ACCESS_LOG' ]"; then
  log "Access log missing; creating file and retrying"
  docker exec "$TRAEFIK_CID" sh -lc "mkdir -p /var/log/traefik && touch '$ACCESS_LOG'" || true
fi
docker exec "$TRAEFIK_CID" sh -lc "[ -f '$ACCESS_LOG' ]" || { log "FAIL: access log not found at $ACCESS_LOG"; exit 1; }

log "Record access log size and tail (sanitized)"
docker exec "$TRAEFIK_CID" sh -lc "stat -c '%s' '$ACCESS_LOG'" > "$EVID/accesslog_size_bytes.txt" 2>/dev/null || true
docker exec "$TRAEFIK_CID" sh -lc "tail -n 20 '$ACCESS_LOG'" \
  | sed -E 's/("RequestPath":"[^"?]*)\\?[^"]*/\\1?<redacted>/g' \
  > "$EVID/accesslog_tail_before.txt" 2>/dev/null || true

RAW="$EVID/accesslog_tail_raw.txt"
SAN="$EVID/accesslog_tail_sanitized.txt"

log "Capture access log tail for ${DURATION}s"
if command -v timeout >/dev/null 2>&1; then
  timeout "${DURATION}s" docker exec "$TRAEFIK_CID" sh -lc "tail -F '$ACCESS_LOG'" \
    > "$RAW" 2>/dev/null & TAIL_PID=$!
  sleep 2
  log "Force origin traffic via Traefik during capture (curl --resolve)"
  curl -sS -I --resolve hub.livraone.com:443:127.0.0.1 https://hub.livraone.com/ \
    > "$EVID/curl_hub_root.headers.txt" || true
  curl -sS -I --resolve hub.livraone.com:443:127.0.0.1 https://hub.livraone.com/login \
    > "$EVID/curl_hub_login.headers.txt" || true
  curl -sS -I --resolve hub.livraone.com:443:127.0.0.1 https://hub.livraone.com/api/auth/signin \
    > "$EVID/curl_auth_signin.headers.txt" || true
  wait "$TAIL_PID" || true
else
  end=$((SECONDS + DURATION))
  while [[ $SECONDS -lt $end ]]; do
    docker exec "$TRAEFIK_CID" sh -lc "tail -n 5 '$ACCESS_LOG'" >> "$RAW" 2>/dev/null || true
    sleep 2
  done
fi

log "Sanitize captured access logs"
sed -E 's/("RequestPath":"[^"?]*)\\?[^"]*/\\1?<redacted>/g' "$RAW" > "$SAN"
rm -f "$RAW"

log "Extract auth paths"
grep -nE "/api/auth/signin" "$SAN" > "$EVID/auth_signin_hits.txt" || true
grep -nE "/api/auth/callback" "$SAN" > "$EVID/auth_callback_hits.txt" || true

log "Extract auth paths from recent access.log tail (sanitized)"
docker exec "$TRAEFIK_CID" sh -lc "tail -n 2000 '$ACCESS_LOG'" \
  | sed -E 's/("RequestPath":"[^"?]*)\\?[^"]*/\\1?<redacted>/g' \
  | grep -nE "/api/auth/(signin|callback)" \
  > "$EVID/accesslog_auth_lines.txt" || true

{
  echo "auth_signin_hits: $(wc -l < "$EVID/auth_signin_hits.txt" | tr -d ' ')"
  echo "auth_callback_hits: $(wc -l < "$EVID/auth_callback_hits.txt" | tr -d ' ')"
  echo "accesslog_auth_lines: $(wc -l < "$EVID/accesslog_auth_lines.txt" | tr -d ' ')"
} > "$EVID/auth_hits_summary.txt"

log "Manifest"
(cd "$EVID" && find . -type f ! -name sha256.txt -print0 | sort -z | xargs -0 sha256sum > sha256.txt)

log "DONE"
echo "EVIDENCE: $EVID"
