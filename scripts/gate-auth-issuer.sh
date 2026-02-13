#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core
wellknown=$(curl -s https://auth.livraone.com/realms/livraone/.well-known/openid-configuration)
issuer=$(printf '%s' "$wellknown" | grep -o '"issuer":"[^"]*"' | head -n1 | cut -d':' -f2- | tr -d '"')
if [[ "$issuer" != "https://auth.livraone.com/realms/livraone" ]]; then
  echo "unexpected issuer $issuer" >&2
  exit 1
fi
printf 'Auth issuer gate OK (issuer=%s)\n' "$issuer"
