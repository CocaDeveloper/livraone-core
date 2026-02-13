#!/usr/bin/env bash
set -euo pipefail

SECRETS_FILE="/etc/livraone/hub.env"

# Must be root to read mode 600 secrets
if [[ "$(id -u)" != "0" ]]; then
  exec sudo -n bash "$0" "$@"
fi

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "secrets: file missing: $SECRETS_FILE" >&2
  exit 1
fi

perm="$(stat -c '%a' "$SECRETS_FILE")"
if [[ "$perm" != "600" ]]; then
  echo "secrets: $SECRETS_FILE must be mode 600 (got $perm)" >&2
  exit 1
fi

# Export env safely (no printing)
set -a
# shellcheck disable=SC1090
source "$SECRETS_FILE"
set +a
