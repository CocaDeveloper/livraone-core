#!/usr/bin/env bash
set -euo pipefail

ROOT="/tmp/livraone-gate-keycloak-hub-client"
EVID="$ROOT/evidence"
mkdir -p "$EVID"
ts="$(date -u +%Y%m%d-%H%M%S)"
LOG="$EVID/run.$ts.log"
RES="$EVID/result.$ts.txt"
OUT="$EVID/client_summary.$ts.json"
: >"$LOG"; : >"$RES"

fail(){ echo "FAIL: $*" | tee -a "$LOG" >/dev/null; echo "FAIL" >"$RES"; exit 0; }
pass(){ echo "PASS" | tee -a "$LOG" >/dev/null; echo "PASS" >"$RES"; exit 0; }

echo "== gate keycloak hub client ==" | tee -a "$LOG" >/dev/null
date -u | tee -a "$LOG" >/dev/null

KC_CONT="$(docker ps --format '{{.Names}} {{.Image}}' | awk 'tolower($0) ~ /keycloak/ {print $1; exit}')"
[ -n "${KC_CONT:-}" ] || fail "Keycloak container not found"

docker cp ops/keycloak/seed-hub-client.sh "$KC_CONT:/tmp/seed-hub-client.sh" >>"$LOG" 2>&1 || fail "docker cp seed script failed"

docker exec "$KC_CONT" sh -lc "chmod +x /tmp/seed-hub-client.sh && /tmp/seed-hub-client.sh" \
  >"$OUT" 2>>"$LOG" || fail "seed execution failed (see log)"

python3 - <<'PY' "$OUT" || fail "client summary parse failed"
import json,sys
p=sys.argv[1]
d=json.load(open(p))
assert d.get('clientId')=="livraone-hub"
assert d.get('enabled') is True
assert d.get('standardFlowEnabled') is True
assert isinstance(d.get('redirectUris'), list) and len(d['redirectUris'])>0
assert isinstance(d.get('webOrigins'), list) and len(d['webOrigins'])>0
PY

pass
