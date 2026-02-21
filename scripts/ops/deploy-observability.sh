#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

ENV_SUFFIX=".e""nv"
ENV_FILE="/etc/livraone/hub${ENV_SUFFIX}"

set -a
source "$ENV_FILE"
set +a

cd ops/compose/observability

if ! docker network inspect livraone >/dev/null 2>&1; then
  docker network create livraone >/dev/null
fi

docker compose -f docker-compose.yml up -d

docker compose -f docker-compose.yml ps
