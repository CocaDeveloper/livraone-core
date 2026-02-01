#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

status=$(curl -s -D "$tmp" -o /dev/null -w "%{http_code}" https://hub.livraone.com/api/auth/signin/keycloak)
if [[ "$status" != "302" ]]; then
  echo "Expected 302 but got $status" >&2
  cat "$tmp" >&2
  exit 1
fi

location=$(grep -i '^Location:' "$tmp" | head -n1 | tr -d '\r')
if [[ ! "$location" =~ auth\.livraone\.com ]] || [[ ! "$location" =~ client_id=hub-web ]]; then
  echo "Location header missing auth redirect: $location" >&2
  exit 1
fi

echo "Hub auth codeflow gate OK"
