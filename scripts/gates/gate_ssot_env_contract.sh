#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# If running in CI, do NOT require real /etc file
if [[ "${CI:-}" == "true" ]]; then
  echo "CI mode: skipping real /etc/livraone/hub.env check"
else
  f="/etc/livraone/hub.env"
  [[ -f "$f" ]] || fail "missing $f"
  [[ "$(stat -c '%a' "$f")" == "600" ]] || fail "hub.env perm != 600"
  [[ "$(stat -c '%U:%G' "$f")" == "root:root" ]] || fail "hub.env owner != root:root"
fi

# Repo-level invariants (always enforced)
if rg -n --hidden --glob '!.git/**' --glob '!**/node_modules/**' '(^|/)\.env(\.|$)' . >/dev/null; then
  fail "forbidden .env file present in repo"
fi

if rg -n --hidden --glob '!.git/**' --glob '!**/node_modules/**' '^\s*env_file\s*:' . >/dev/null; then
  fail "forbidden docker-compose env_file detected"
fi

echo "PASS"
