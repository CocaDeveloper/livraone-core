#!/usr/bin/env bash
set -euo pipefail

# Gate: required auth env vars must be present and non-empty
# Never print values.

REQ=(
  NEXTAUTH_SECRET
  KEYCLOAK_ISSUER
  HUB_AUTH_ISSUER
  HUB_AUTH_CLIENT_ID
  HUB_AUTH_CLIENT_SECRET
  HUB_AUTH_CALLBACK_URL
)

missing=0
for v in "${REQ[@]}"; do
  if [ -z "${!v:-}" ]; then
    echo "FAIL: missing required auth var: $v" >&2
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "PASS: required auth env vars present"
