#!/usr/bin/env bash
set -euo pipefail

# PHASE9_WAIT_FOR_HEALTHY: poll container health/state with timeout to avoid flapping fails
wait_for_healthy(){
  local svc="${1:?service}"
  local timeout_s="${2:-120}"
  local start now cid status running
  start=$(date +%s)
  while true; do
    cid=$(docker compose -f infra/compose.yaml ps -q "$svc" 2>/dev/null || true)
    if [[ -n "$cid" ]]; then
      status=$(docker inspect -f '{{.State.Health.Status}}' "$cid" 2>/dev/null || echo "unknown")
      echo "gate-traefik: $svc health=$status cid=$cid" >&2
      if [[ "$status" == "healthy" ]]; then
        echo "gate-traefik: $svc reached healthy" >&2
        return 0
      fi
      if [[ "$status" == "unknown" ]]; then
        running=$(docker inspect -f '{{.State.Status}}' "$cid" 2>/dev/null || echo "unknown")
        echo "gate-traefik: $svc state=$running (no healthcheck?)" >&2
        [[ "$running" == "running" ]] && return 0
      fi
    else
      echo "gate-traefik: waiting for $svc container to appear" >&2
    fi
    now=$(date +%s)
    if (( now - start >= timeout_s )); then
      echo "gate-traefik: TIMEOUT after ${timeout_s}s waiting for $svc healthy" >&2
      return 1
    fi
    sleep 2
  done
}

cd /srv/livraone/livraone-core
compose=infra/compose.yaml
service=traefik

if [[ "${LIVRAONE_SKIP_DOCKER:-0}" -eq 1 ]]; then
  echo "gate-traefik: LIVRAONE_SKIP_DOCKER=1, skipping Traefik checks"
  exit 0
fi

bash /srv/livraone/livraone-core/scripts/load-secrets.sh
container=$(docker compose -f "$compose" ps -q "$service")
if [[ -z "$container" ]]; then
  echo "Traefik container not running"
  docker compose -f "$compose" ps "$service"
  exit 1
fi

if ! wait_for_healthy "$service" 120; then
  echo "gate-traefik: Traefik failed to become healthy within timeout" >&2
  docker compose -f "$compose" ps "$service" >&2 || true
  docker compose -f "$compose" logs --no-color --tail=200 "$service" >&2 || true
  exit 1
fi

health=$(docker inspect --format '{{.State.Health.Status}}' "$container" 2>/dev/null || echo "unknown")
if [[ "$health" != "healthy" ]]; then
  echo "Traefik health is '$health' (expected healthy)"
  exit 1
fi

for port in 80 443; do
  if ! docker compose -f "$compose" port "$service" "$port" >/dev/null; then
    echo "Port $port not exposed"
    exit 1
  fi
done

printf "Traefik container %s is healthy and ports 80/443 are mapped.\n" "$container"
