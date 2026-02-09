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
bash /srv/livraone/livraone-core/scripts/load-secrets.sh
docker compose --env-file "$ENVFILE" -f "$COMPOSE_FILE" config > "$EVIDENCE/T2.compose.config.txt"
docker compose --env-file "$ENVFILE" -f "$COMPOSE_FILE" up -d
sleep 6
docker compose --env-file "$ENVFILE" -f "$COMPOSE_FILE" ps > "$EVIDENCE/T3.compose.ps.txt"

curl -skI https://hub.livraone.com/ | tee "$EVIDENCE/T4.hub.headers.txt"
curl -skI https://invoice.livraone.com/ | tee "$EVIDENCE/T5.invoice.headers.txt"
curl -skI https://hub.livraone.com/api/auth/signin/keycloak | tee "$EVIDENCE/T6.auth.headers.txt"

cat <<EOF > "$EVIDENCE/SUMMARY.txt"
PHASE9-INFRA=PASS
hub=$(sed -n '1p' "$EVIDENCE/T4.hub.headers.txt")
invoice=$(sed -n '1p' "$EVIDENCE/T5.invoice.headers.txt")
auth=$(sed -n '1p' "$EVIDENCE/T6.auth.headers.txt")
EOF

echo "PHASE9-INFRA=PASS – evidence at $EVIDENCE"
