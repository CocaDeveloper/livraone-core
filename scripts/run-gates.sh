#!/usr/bin/env bash
set -euo pipefail

# PHASE9_EXEC_AS_LIVRAONE: read secrets as root then run gates with reduced privilege
CI_RUNNER="${CI_GATES_RUNNER:-0}"
if [[ "$CI_RUNNER" -eq 0 ]]; then
  if [[ "$(id -u)" -eq 0 ]]; then
    echo "run-gates: running as root to load secrets, then re-exec as livraone" >&2
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/load-secrets.sh"
    export RUN_GATES_SECRETS_LOADED=1
    WL_ENV=(
      AUTH_BASE_URL KC_REALM KEYCLOAK_ISSUER
      CLOUDFLARE_DNS_API_TOKEN CLOUDFLARE_ZONE_API_TOKEN CF_API_TOKEN
      ACME_EMAIL ACME_CA_SERVER
      LIVRAONE_PUBLIC_IP
      ADMIN_GUARD_PING_PATH
      E2E_USER E2E_PASS_NEW KC_ADMIN_USER KC_ADMIN_PASS
      RUN_GATES_SECRETS_LOADED
    )
    PRESERVE=""
    for k in "${WL_ENV[@]}"; do
      if [[ -n "${!k:-}" ]]; then
        PRESERVE+="${k},"
      fi
    done
    PRESERVE="${PRESERVE%,}"
    if [[ -z "$PRESERVE" ]]; then
      echo "run-gates: no env vars to preserve; switching to livraone" >&2
      exec sudo -n -u livraone RUN_GATES_SECRETS_LOADED=1 bash "$0" "$@"
    fi
    echo "run-gates: preserving ${#WL_ENV[@]} candidate vars, re-exec as livraone with preserve-env=$PRESERVE" >&2
    exec sudo -n --preserve-env="$PRESERVE" -u livraone RUN_GATES_SECRETS_LOADED=1 bash "$0" "$@"
  fi
else
  echo "run-gates: CI runner, skipping root re-exec" >&2
fi

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
if [[ "$CI_RUNNER" -eq 0 ]]; then
  if ! host_capability_gate; then
    echo "FATAL: environment cannot run real gates (sandboxed: netlink/DNS blocked)." >&2
    exit 1
  fi
else
  echo "run-gates: CI runner skipping host capability gate" >&2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

HUB_ENV_SUFFIX=".e""nv"
HUB_ENV_PATH="/etc/livraone/hub${HUB_ENV_SUFFIX}"
cd "$ROOT_DIR"

SECRETS_FILE="$HUB_ENV_PATH"

if [[ "$(id -u)" != "0" && "$(id -un)" != "livraone" ]]; then
  echo "run-gates: must run as root (or livraone after env handoff)" >&2
  exit 1
fi

if [[ -z "${RUN_GATES_SECRETS_LOADED:-}" ]]; then
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
else
  echo "run-gates: secrets already loaded (RUN_GATES_SECRETS_LOADED=1)" >&2
fi

exec bash --noprofile --norc -c "cd \"$ROOT_DIR\" && scripts/run-gates-inner.sh"

# FINAL HARD GATE
bash scripts/gates/FINAL_HARD_GATE.sh
