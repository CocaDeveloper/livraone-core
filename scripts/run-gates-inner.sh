#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash scripts/preflight-phase4.sh
bash scripts/gate-traefik.sh
bash scripts/gate-tls.sh

# FINAL HARD GATE: must explicitly check result file (gate exits 0 even on FAIL)
bash scripts/gates/FINAL_HARD_GATE.sh
FINAL_RES="/tmp/livraone-final-hard-gate/evidence/result.txt"
if [[ ! -f "$FINAL_RES" ]]; then
  echo "run-gates: FINAL_HARD_GATE missing result.txt at $FINAL_RES" >&2
  exit 1
fi
if ! grep -qx "PASS" "$FINAL_RES"; then
  echo "run-gates: FINAL_HARD_GATE failed (see $FINAL_RES and diagnostics)" >&2
  exit 1
fi
