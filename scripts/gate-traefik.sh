#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core
compose=infra/compose.yaml
service=traefik

container=$(docker compose -f "$compose" ps -q "$service")
if [[ -z "$container" ]]; then
  echo "Traefik container not running"
  docker compose -f "$compose" ps "$service"
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
