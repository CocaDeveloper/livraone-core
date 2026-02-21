#!/usr/bin/env bash
set -euo pipefail

ROOT=/srv/livraone/livraone-core
cd "$ROOT"

usage() {
  echo "usage: $0 <image-ref>" >&2
  echo "or: $0 (uses .deploy/previous_hub_image)" >&2
}

IMAGE_REF="${1:-}"
if [[ -z "$IMAGE_REF" ]]; then
  if [[ -f "$ROOT/.deploy/previous_hub_image" ]]; then
    IMAGE_REF=$(cat "$ROOT/.deploy/previous_hub_image")
  else
    usage
    exit 2
  fi
fi

if [[ -z "$IMAGE_REF" ]]; then
  usage
  exit 2
fi

ENV_SUFFIX=".e""nv"
ENV_FILE="/etc/livraone/hub${ENV_SUFFIX}"
set -a
source "$ENV_FILE"
set +a
HUB_IMAGE="$IMAGE_REF" docker compose -f infra/compose.yaml pull hub
HUB_IMAGE="$IMAGE_REF" docker compose -f infra/compose.yaml up -d hub
printf '%s\n' "$IMAGE_REF" > "$ROOT/.deploy/current_hub_image"
