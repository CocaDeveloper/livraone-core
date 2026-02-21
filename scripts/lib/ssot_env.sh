#!/usr/bin/env bash
set -euo pipefail

SSOT_FILE="${SSOT_FILE:-/etc/livraone/hub.env}"

ssot_fail(){ echo "FAIL: $*" >&2; return 1; }

# Load SSOT only when explicitly allowed by runner flags.
# We treat CI_GATES_RUNNER=1 as permission to load SSOT on server runners.
if [ "${CI_GATES_RUNNER:-0}" != "1" ]; then
  return 0
fi

if [ ! -r "$SSOT_FILE" ]; then
  ssot_fail "SSOT not readable: $SSOT_FILE (expected secrets SSOT). Fix perms/ownership."
fi

# Optional hardening: require 0600 to avoid accidental exposure
MODE="$(stat -c '%a' "$SSOT_FILE" 2>/dev/null || echo "")"
if [ "$MODE" != "600" ]; then
  ssot_fail "SSOT perms must be 600: $SSOT_FILE (actual $MODE)"
fi

# shellcheck disable=SC1090
set -a
. "$SSOT_FILE"
set +a

return 0
