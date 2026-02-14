#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"
url="https://auth.livraone.com/realms/livraone/.well-known/openid-configuration"
status=$(curl -s -o /dev/null -w '%{http_code}' "$url")
if [[ "$status" != "200" ]]; then
  echo "auth well-known endpoint returned $status" >&2
  exit 1
fi
echo "Auth smoke gate OK"
