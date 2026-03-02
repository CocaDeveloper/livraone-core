#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

f="/etc/livraone/hub.env"
[[ -f "$f" ]] || fail "missing $f"
[[ "$(stat -c '%a' "$f")" == "600" ]] || fail "hub.env perm != 600"
[[ "$(stat -c '%U:%G' "$f")" == "root:root" ]] || fail "hub.env owner != root:root"

# Forbid forbidden patterns in repo
# - .env files
# - env_file: in compose
if rg -n --hidden --glob '!.git/**' --glob '!**/node_modules/**' '(^|/)\.env(\.|$)' . >/dev/null; then
  fail "forbidden .env file present in repo"
fi

if rg -n --hidden --glob '!.git/**' --glob '!**/node_modules/**' '^\s*env_file\s*:' . >/dev/null; then
  fail "forbidden docker-compose env_file: detected"
fi

echo "PASS"
