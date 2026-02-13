#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core
url="https://auth.livraone.com/realms/livraone/.well-known/openid-configuration"
status=$(curl -s -o /dev/null -w '%{http_code}' "$url")
if [[ "$status" != "200" ]]; then
  echo "auth well-known endpoint returned $status" >&2
  exit 1
fi
echo "Auth smoke gate OK"
