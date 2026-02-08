#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s extglob

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
EVIDENCE="/tmp/livraone-phase9"
ENVFILE="$ROOT/.env"
OUT="$EVIDENCE/env-check.txt"

mkdir -p "$EVIDENCE"

if [ ! -f "$ENVFILE" ]; then
  echo "GATE-ENV-REQUIRED=FAIL"
  cat <<MSG >&2
.env missing in $ROOT.
Create $ENVFILE with:
  ACME_EMAIL="you@example.com"
  CF_API_TOKEN="your-cloudflare-token"
Then: chmod 600 .env
MSG
  exit 1
fi

declare -A env_values=()

while IFS= read -r raw || [ -n "$raw" ]; do
  line="${raw%%#*}"
  line="${line##+([[:space:]])}"
  line="${line%%+([[:space:]])}"
  [[ -z "$line" ]] && continue

  if [[ $line =~ ^(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
    key="${BASH_REMATCH[2]}"
    val="${BASH_REMATCH[3]}"
    val="${val##+([[:space:]])}"
    val="${val%%+([[:space:]])}"

    if [[ "${val:0:1}" == '"' && "${val: -1}" == '"' ]]; then
      val="${val:1:-1}"
    elif [[ "${val:0:1}" == "'" && "${val: -1}" == "'" ]]; then
      val="${val:1:-1}"
    fi

    env_values["$key"]="$val"
  fi
done < "$ENVFILE"

REQUIRED=(ACME_EMAIL CF_API_TOKEN)
PASS=true
: > "$OUT"

for key in "${REQUIRED[@]}"; do
  val="${env_values[$key]:-}"
  if [[ -z "$val" ]]; then
    PASS=false
    echo "missing $key" >> "$OUT"
  else
    if [[ "$key" == "CF_API_TOKEN" ]]; then
      echo "CF_API_TOKEN=[REDACTED]" >> "$OUT"
    else
      echo "$key=$val" >> "$OUT"
    fi
  fi
done

if ! $PASS; then
  echo "GATE-ENV-REQUIRED=FAIL"
  echo "see $OUT" >&2
  exit 1
fi

sha256sum "$OUT" > "$EVIDENCE/env-check.sha256"
echo "GATE-ENV-REQUIRED=PASS"
