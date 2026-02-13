#!/usr/bin/env bash
set -euo pipefail

ROOT=/srv/livraone/livraone-core
cd "$ROOT"

REQ=(
  AUTH_BASE_URL
  KC_REALM
  KEYCLOAK_ISSUER
  CLOUDFLARE_DNS_API_TOKEN
  CLOUDFLARE_ZONE_API_TOKEN
  CF_API_TOKEN
  ACME_EMAIL
  LIVRAONE_PUBLIC_IP
)
MISS=0
for key in "${REQ[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    echo "ci-gates: missing env $key" >&2
    MISS=1
  fi
done
if [[ "$MISS" -ne 0 ]]; then
  echo "ci-gates: missing required env vars" >&2
  exit 1
fi

export CI_GATES_RUNNER=1
export RUN_GATES_SECRETS_LOADED=1
exec bash --noprofile --norc -c 'cd /srv/livraone/livraone-core && scripts/run-gates-inner.sh'
