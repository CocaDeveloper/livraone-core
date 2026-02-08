#!/usr/bin/env bash
set -euo pipefail

ROOT="/srv/livraone/livraone-core"
EVIDENCE="/tmp/livraone-phase9"
COMPOSE_FILE="$ROOT/infra/compose.yaml"
ENVFILE="$ROOT/.env"

mkdir -p "$EVIDENCE"
cd "$ROOT"

# 1) Gate .env (must exist + required keys)
bash ops/gate-env-required.sh

# 2) Repo must be clean
git status --short > "$EVIDENCE/T0.gitstatus.txt"
if [ -s "$EVIDENCE/T0.gitstatus.txt" ]; then
  echo "FAIL: repo dirty" >&2
  cat "$EVIDENCE/T0.gitstatus.txt" >&2
  exit 1
fi

# 3) Compose file must exist
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "FAIL: missing $COMPOSE_FILE" | tee "$EVIDENCE/T1.compose.missing.txt" >&2
  ls -la "$ROOT/infra" | tee -a "$EVIDENCE/T1.compose.missing.txt"
  exit 1
fi

# 4) Compose bootstrap (explicit env-file)
docker compose --env-file "$ENVFILE" -f "$COMPOSE_FILE" config > "$EVIDENCE/T2.compose.config.txt"
docker compose --env-file "$ENVFILE" -f "$COMPOSE_FILE" up -d
sleep 6
docker compose --env-file "$ENVFILE" -f "$COMPOSE_FILE" ps > "$EVIDENCE/T3.compose.ps.txt"

echo "PHASE9-INFRA=PASS"
echo "Evidence: $EVIDENCE"
