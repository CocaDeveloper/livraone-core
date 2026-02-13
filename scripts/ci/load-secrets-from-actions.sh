#!/usr/bin/env bash
set -euo pipefail

export RUN_GATES_SECRETS_LOADED=1
REQ=(
  AUTH_BASE_URL
  KC_REALM
  KEYCLOAK_ISSUER
  CLOUDFLARE_DNS_API_TOKEN
  CLOUDFLARE_ZONE_API_TOKEN
  LIVRAONE_PUBLIC_IP
)
MISSING=0
for k in "${REQ[@]}"; do
  if [[ -z "${!k:-}" ]]; then
    echo "ci-secrets: missing required env: $k" >&2
    MISSING=1
  fi
done
if [[ "$MISSING" -ne 0 ]]; then
  echo "ci-secrets: FAIL (set required secrets in GitHub Actions Secrets)" >&2
  exit 1
fi

echo "ci-secrets: PASS (required env present; values not printed)" >&2
