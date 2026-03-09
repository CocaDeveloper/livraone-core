#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

fail(){ echo "FAIL: $*"; exit 1; }

if [[ -z "${NEXTAUTH_SECRET:-}" && -r /etc/livraone/hub.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source /etc/livraone/hub.env
  set +a
fi

required_env=(
  NEXTAUTH_URL
  NEXTAUTH_SECRET
  KEYCLOAK_ISSUER
  HUB_AUTH_ISSUER
  HUB_AUTH_CLIENT_ID
  HUB_AUTH_CLIENT_SECRET
  HUB_AUTH_CALLBACK_URL
)

for key in "${required_env[@]}"; do
  [[ -n "${!key:-}" ]] || fail "missing $key; load /etc/livraone/hub.env before docker compose"
done

ps_out=$(docker compose -f infra/compose.yaml ps)
printf '%s\n' "$ps_out"

if printf '%s' "$ps_out" | rg -q '(Exited|exited|dead|unhealthy|restarting)'; then
  fail "compose has non-running services"
fi

code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 8 http://localhost || true)
if [[ -z "$code" || "$code" == "000" ]]; then
  fail "traefik not reachable on localhost"
fi

echo "PASS: compose"
