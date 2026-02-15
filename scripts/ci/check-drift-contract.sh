#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BASELINE="$ROOT_DIR/.infra-baseline.json"
FINGERPRINT="$ROOT_DIR/scripts/infra/fingerprint.sh"
CHECK="$ROOT_DIR/scripts/infra/check-drift.sh"

fail(){ echo "FAIL: $*" >&2; exit 1; }

[[ -f "$FINGERPRINT" ]] || fail "fingerprint script missing"
[[ -f "$CHECK" ]] || fail "drift check script missing"
[[ -f "$BASELINE" ]] || fail "drift baseline missing"

if ! git ls-files --error-unmatch "$BASELINE" >/dev/null 2>&1; then
  fail "baseline not tracked"
fi

if rg -n 'VPS_|ssh_key' "$FINGERPRINT" "$CHECK" >/dev/null; then
  fail "drift scripts reference secrets"
fi

DRIFT_BASELINE="$BASELINE" python3 - <<'PY'
import json, os
path=os.environ.get('DRIFT_BASELINE')
if not path:
    raise SystemExit('baseline path missing')
with open(path) as fh:
    json.load(fh)
PY

echo "drift contract OK"
