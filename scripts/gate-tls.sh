#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core
host=hub.livraone.com

location=$(curl -sI http://"$host" | awk -F': ' '/[Ll]ocation/ {print $2; exit}')
if [[ -z "$location" ]]; then
  echo "no HTTP redirect location header from http://$host"
  exit 1
fi
if [[ "$location" != https://* ]]; then
  echo "expected HTTP redirect to HTTPS but got $location"
  exit 1
fi

status=$(curl -s -o /dev/null -w '%{http_code}' -I https://"$host") || {
  echo "failed to fetch https://$host (curl exit $?); ensure Traefik has a valid certificate"
  exit 1
}
if [[ "$status" != "200" && "$status" != "301" && "$status" != "302" && "$status" != "303" && "$status" != "404" ]]; then
  echo "unexpected HTTPS status code $status"
  exit 1
fi

issuer=$(openssl s_client -servername "$host" -connect "$host:443" </dev/null 2>&1 | awk '/issuer=/{print; exit}')
if [[ "$issuer" != *"Let's Encrypt"* ]]; then
  echo "certificate issuer did not mention Let's Encrypt: $issuer"
  exit 1
fi

printf "TLS gate OK (%s, issuer: %s)\n" "$status" "$issuer"
