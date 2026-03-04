#!/usr/bin/env bash
set -euo pipefail

ts(){ date +%Y%m%d-%H%M%S; }
EVID="/srv/livraone/evidence/phase72.2-traefik-accesslog-$(ts)"
mkdir -p "$EVID"

log(){ echo "[$(date -Is)] $*" | tee -a "$EVID/run.log"; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "FAIL: missing $1"; exit 1; }; }

need docker
need sed

RAW="$EVID/traefik_accesslog_raw.txt"
SAN="$EVID/traefik_accesslog_sanitized.txt"
HITS="$EVID/auth_callback_hits.txt"

log "Capturing traefik logs (live, 5 minutes) with query redaction..."
if command -v timeout >/dev/null 2>&1; then
  timeout 300s docker logs -f --since 2m traefik 2>&1 | tee "$RAW" >/dev/null || true
else
  docker logs --since 2m traefik 2>&1 | tee "$RAW" >/dev/null || true
fi

log "Sanitizing access logs (redact query string + Set-Cookie headers if present)..."
sed -E \
  -e 's/\\?[^" ]+/\\?<redacted>/g' \
  -e 's/([Ss]et-[Cc]ookie:)[^\\r\\n]*/\\1 <redacted>/g' \
  "$RAW" > "$SAN"

log "Extracting auth callback/signin hits..."
grep -nE "/api/auth/(signin|callback)" "$SAN" > "$HITS" || true

log "Writing checksums manifest..."
(cd "$EVID" && find . -type f ! -name sha256.txt -print0 | sort -z | xargs -0 sha256sum > sha256.txt)

log "DONE"
echo "EVIDENCE: $EVID"
