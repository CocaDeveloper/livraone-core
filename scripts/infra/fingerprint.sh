#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

compose_file="$ROOT_DIR/infra/compose.yaml"
dynamic_file="$ROOT_DIR/infra/dynamic.yaml"

compose_sha=""
if [ -f "$compose_file" ]; then
  compose_sha=$(sha256sum "$compose_file" | awk '{print $1}')
fi

dynamic_sha="null"
if [ -f "$dynamic_file" ]; then
  dynamic_sha=$(sha256sum "$dynamic_file" | awk '{print $1}')
fi

docker_version="missing-docker"
docker_compose_version="missing-docker"
running_images_json="[]"
containers_json="[]"
if command -v docker >/dev/null 2>&1; then
  docker_version_raw=$(docker version --format '{{.Server.Version}}' 2>/dev/null || true)
  if [ -z "$docker_version_raw" ]; then
    docker_version_raw=$(docker version 2>/dev/null | awk '/Server Version/ {print $NF; exit}')
  fi
  if [ -n "$docker_version_raw" ]; then
    docker_version="$docker_version_raw"
  fi

  compose_version_raw=$(docker compose version 2>/dev/null || true)
  compose_line=$(printf '%s' "$compose_version_raw" | awk 'NR==1 {print}')
  if [ -n "$compose_line" ]; then
    docker_compose_version="$compose_line"
  fi

  running_images_raw=$(docker ps --format '{{.Image}}' 2>/dev/null || true)
  running_images_json=$(RUNNING_IMAGES_RAW="$running_images_raw" python3 - <<'PY'
import json, os
lines=[line.strip() for line in os.environ.get('RUNNING_IMAGES_RAW', '').splitlines() if line.strip()]
print(json.dumps(sorted(set(lines))))
PY
)

  containers_raw=$(docker ps --format '{{.Names}}|{{.Image}}|{{.Status}}' 2>/dev/null || true)
  containers_json=$(CONTAINERS_RAW="$containers_raw" python3 - <<'PY'
import json, os
rows=[line.strip() for line in os.environ.get('CONTAINERS_RAW', '').splitlines() if line.strip()]
out=[]
for row in rows:
    parts=row.split('|',2)
    if len(parts) != 3:
        continue
    out.append({'name':parts[0], 'image':parts[1], 'status':parts[2]})
print(json.dumps(out))
PY
)
fi

hub_env_file="/etc/livraone/hub.env"
hub_env_owner=""
hub_env_group=""
hub_env_mode=""
hub_env_uid=""
hub_env_gid=""
hub_env_exists=false
if [ -f "$hub_env_file" ]; then
  hub_env_owner=$(stat -c '%U' "$hub_env_file")
  hub_env_group=$(stat -c '%G' "$hub_env_file")
  hub_env_mode=$(stat -c '%a' "$hub_env_file")
  hub_env_uid=$(stat -c '%u' "$hub_env_file")
  hub_env_gid=$(stat -c '%g' "$hub_env_file")
  hub_env_exists=true
fi

kernel_version=$(uname -r)
uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || true)

export COMPOSE_SHA="$compose_sha"
export DYNAMIC_SHA="$dynamic_sha"
export DOCKER_VERSION="$docker_version"
export DOCKER_COMPOSE_VERSION="$docker_compose_version"
export RUNNING_IMAGES_JSON="$running_images_json"
export CONTAINERS_JSON="$containers_json"
export HUB_ENV_OWNER="$hub_env_owner"
export HUB_ENV_GROUP="$hub_env_group"
export HUB_ENV_MODE="$hub_env_mode"
export HUB_ENV_UID="$hub_env_uid"
export HUB_ENV_GID="$hub_env_gid"
export HUB_ENV_EXISTS="$hub_env_exists"
export KERNEL_VERSION="$kernel_version"
export UPTIME_SECONDS="$uptime_seconds"

python3 - <<'PY'
import json, os
compose_sha = os.environ.get('COMPOSE_SHA', '')
dynamic_sha = os.environ.get('DYNAMIC_SHA', 'null')
docker_version = os.environ.get('DOCKER_VERSION', 'missing-docker')
docker_compose_version = os.environ.get('DOCKER_COMPOSE_VERSION', 'missing-docker')
running_images = json.loads(os.environ.get('RUNNING_IMAGES_JSON', '[]'))
containers = json.loads(os.environ.get('CONTAINERS_JSON', '[]'))
hub_env = None
if os.environ.get('HUB_ENV_EXISTS') == 'true':
    hub_env = {
        'owner': os.environ.get('HUB_ENV_OWNER'),
        'group': os.environ.get('HUB_ENV_GROUP'),
        'mode': os.environ.get('HUB_ENV_MODE'),
        'uid': int(os.environ.get('HUB_ENV_UID')),    
        'gid': int(os.environ.get('HUB_ENV_GID')),
    }
kernel = os.environ.get('KERNEL_VERSION', '')
uptime = os.environ.get('UPTIME_SECONDS', '')
data = {
    'compose_sha': compose_sha,
    'dynamic_sha': dynamic_sha if dynamic_sha != 'null' else None,
    'docker_version': docker_version,
    'docker_compose_version': docker_compose_version,
    'running_images': running_images,
    'containers': containers,
    'hub_env': hub_env,
    'kernel_version': kernel,
    'uptime_seconds': int(uptime) if uptime.isdigit() else uptime,
}
print(json.dumps(data, sort_keys=True))
PY
