#!/usr/bin/env bash
set -euo pipefail

ROOT="/srv/livraone/livraone-core"
EVIDENCE="/tmp/livraone-phaseLanding"

mkdir -p "$EVIDENCE"
cd "$ROOT"

git status --short > "$EVIDENCE/T0.status.txt"
[ -s "$EVIDENCE/T0.status.txt" ] && { cat "$EVIDENCE/T0.status.txt" >&2; exit 1; }
[ -f "$ROOT/.env" ] || { echo "FAIL: missing .env" >&2; exit 1; }

if ! grep -q "LIVRAONE-HUB-LANDING-OK" apps/hub/pages/index.tsx; then
  echo "FAIL: landing marker missing" >&2
  exit 1
fi
cp apps/hub/pages/index.tsx "$EVIDENCE/T1.landing.copy.txt"

docker compose down
docker compose up -d
sleep 6

curl -sk https://hub.livraone.com/ | tee "$EVIDENCE/T3.hub.body.txt"
curl -skI https://hub.livraone.com/ | tee "$EVIDENCE/T3.hub.headers.txt"
grep -q "HTTP/2 200" "$EVIDENCE/T3.hub.headers.txt"
grep -q "LIVRAONE-HUB-LANDING-OK" "$EVIDENCE/T3.hub.body.txt"

cat >> docs/STATE.md <<EOF

PHASE (landing) — Hub Public Page → PASS

Evidence:
- $EVIDENCE/T1.landing.copy.txt
- $EVIDENCE/T3.hub.body.txt
- $EVIDENCE/T3.hub.headers.txt
EOF

git add apps/hub/pages/index.tsx docs/STATE.md ops/
git commit -m "phase(landing): hub public landing page"

echo "Landing PASS: $EVIDENCE"
