#!/usr/bin/env bash
set -euo pipefail

# SSOT loader (no secrets printed)
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/ssot_env.sh"

# Fail-fast: prevent docker compose from defaulting critical auth vars to blank
REQUIRED_AUTH_VARS=(
  NEXTAUTH_SECRET
  KEYCLOAK_ISSUER
  HUB_AUTH_ISSUER
  HUB_AUTH_CLIENT_ID
  HUB_AUTH_CLIENT_SECRET
  HUB_AUTH_CALLBACK_URL
)

for v in "${REQUIRED_AUTH_VARS[@]}"; do
  if [ -z "${!v:-}" ]; then
    echo "FAIL: missing required auth var: $v" >&2
    exit 1
  fi
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash scripts/preflight-phase4.sh
bash scripts/gates/gate_required_auth_env.sh
bash scripts/gates/gate_required_checks_contract.sh
bash scripts/gate-traefik.sh
bash scripts/gate-tls.sh
bash scripts/gates/marketing_lint.sh

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
