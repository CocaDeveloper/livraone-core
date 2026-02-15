#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BASELINE="$ROOT_DIR/.infra-baseline.json"
FINGERPRINT="$ROOT_DIR/scripts/infra/fingerprint.sh"
RESULT_FILE="${DRIFT_RESULT_FILE:-$ROOT_DIR/.infra-drift.status}"

run_fingerprint(){
  bash "$FINGERPRINT"
}

CURRENT="$(run_fingerprint)"

status="PASS"
message="drift check ok"
diff_summary=""

if [ ! -f "$BASELINE" ]; then
  printf '%s
' "$CURRENT" > "$BASELINE"
  message="baseline created"
else
  set +e
  diff_output=$(printf '%s' "$CURRENT" | python3 - "$BASELINE" <<'PY'
import json, sys
base=json.load(open(sys.argv[1]))
curr=json.loads(sys.stdin.read())
diff=[]
for key in sorted(set(base.keys()) | set(curr.keys())):
    if base.get(key) != curr.get(key):
        diff.append(f"{key}: baseline={json.dumps(base.get(key), sort_keys=True)} current={json.dumps(curr.get(key), sort_keys=True)}")
if diff:
    print("\n".join(diff))
    sys.exit(1)
PY
)
  diff_rc=$?
  set -e
  if [ "$diff_rc" -ne 0 ]; then
    status="FAIL"
    message="drift detected"
    diff_summary="$diff_output"
  fi
fi

if [ -n "$RESULT_FILE" ]; then
  printf '%s:%s
' "$status" "${diff_summary:-$message}" > "$RESULT_FILE"
fi

echo "$message"
if [ "$status" = "FAIL" ] && [ -n "$diff_summary" ]; then
  echo "$diff_summary"
fi
