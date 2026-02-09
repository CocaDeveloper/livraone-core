#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SECRETS_FILE="/etc/livraone/hub.env"

if [[ "$(id -u)" != "0" ]]; then
  echo "run-gates: must run as root" >&2
  exit 1
fi

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "run-gates: secrets file $SECRETS_FILE missing" >&2
  exit 1
fi

perm="$(stat -c '%a' "$SECRETS_FILE")"
if [[ "$perm" != "600" ]]; then
  echo "run-gates: $SECRETS_FILE must be mode 600 (got $perm)" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$SECRETS_FILE"
set +a

exec sudo -u livraone -E -- env "PATH=$PATH" "DOCKER_CONFIG=/home/livraone/.docker" bash --noprofile --norc -c 'cd /srv/livraone/livraone-core && scripts/run-gates-inner.sh'
