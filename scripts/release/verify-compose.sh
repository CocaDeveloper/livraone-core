#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

fail(){ echo "FAIL: $*"; exit 1; }

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
