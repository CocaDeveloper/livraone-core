#!/usr/bin/env bash
set -euo pipefail

# PHASE9_HOST_CAPABILITY_GATE: refuse to run in sandboxed environments (no netlink/DNS)
host_capability_gate(){
  echo "hostcap: checking netlink + DNS sockets" >&2
  if ! ip -4 route >/dev/null 2>&1; then
    echo "hostcap: FAIL netlink blocked (ip route not permitted)" >&2
    return 1
  fi
  if command -v dig >/dev/null 2>&1; then
    if ! dig +time=1 +tries=1 auth.livraone.com A >/dev/null 2>&1; then
      echo "hostcap: FAIL DNS socket/egress blocked (dig cannot resolve)" >&2
      return 1
    fi
  else
    echo "hostcap: FAIL dig not installed" >&2
    return 1
  fi
  echo "hostcap: PASS" >&2
}
if ! host_capability_gate; then
  echo "FATAL: environment cannot run real gates (sandboxed: netlink/DNS blocked)." >&2
  exit 1
fi

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

exec bash --noprofile --norc -c 'cd /srv/livraone/livraone-core && scripts/run-gates-inner.sh'
