#!/usr/bin/env bash
set -euo pipefail

REPO="/srv/livraone/livraone-core"
COMPOSE="$REPO/infra/compose.yaml"
SSOT="/etc/livraone/hub.env"

log(){ echo "[$(date -Is)] $*"; }
die(){ echo "FAIL: $*" >&2; exit 1; }

[ -d "$REPO/.git" ] || die "repo missing: $REPO"
[ -f "$COMPOSE" ] || die "compose missing: $COMPOSE"
[ -f "$SSOT" ] || die "SSOT missing: $SSOT"
[ "$(stat -c '%a' "$SSOT")" = "600" ] || die "SSOT perms must be 600: $SSOT"

cd "$REPO"

# Load SSOT (no secret output)
set -a
# shellcheck disable=SC1090
source "$SSOT"
set +a

required=(
  NEXTAUTH_SECRET
  HUB_AUTH_ISSUER
  HUB_AUTH_CLIENT_ID
  HUB_AUTH_CLIENT_SECRET
  HUB_AUTH_CALLBACK_URL
  NEXTAUTH_URL
)

for k in "${required[@]}"; do
  if [ -z "${!k:-}" ]; then
    die "missing required env: $k"
  fi
  log "$k: present"
done

log "Building hub image..."
docker compose -f "$COMPOSE" build hub

log "Deploying hub (remove orphans)..."
docker compose -f "$COMPOSE" up -d --remove-orphans

log "Done."
