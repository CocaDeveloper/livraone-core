#!/usr/bin/env bash
set -euo pipefail

# FINAL HARD GATE — Repo hygiene + SSOT policy enforcement
# Evidence is written under /tmp/livraone-final-hard-gate/evidence/

PHASE="livraone-final-hard-gate"
BASE="/tmp/${PHASE}"
EVID="${BASE}/evidence"
mkdir -p "${EVID}"
TS="$(date -u +%Y%m%d-%H%M%S)"
RUN_LOG="${EVID}/run.${TS}.log"
DIAG_LOG="${EVID}/diagnostics.${TS}.log"
RESULT="${EVID}/result.txt"
: >"${RUN_LOG}"; : >"${DIAG_LOG}"; : >"${RESULT}"
exec > >(tee -a "${RUN_LOG}") 2>&1

fail(){
  echo "FAIL: $*" | tee -a "${DIAG_LOG}" >/dev/null
  echo "Evidence:" | tee -a "${DIAG_LOG}" >/dev/null
  echo "- ${RUN_LOG}" | tee -a "${DIAG_LOG}" >/dev/null
  echo "- ${DIAG_LOG}" | tee -a "${DIAG_LOG}" >/dev/null
  echo "- ${EVID}/*" | tee -a "${DIAG_LOG}" >/dev/null
  echo "FAIL" > "${RESULT}"
  exit 0
}
pass(){ echo "PASS" > "${RESULT}"; exit 0; }

REPO="${REPO:-/srv/livraone/livraone-core}"
if [ ! -d "${REPO}" ]; then
  REPO="$(git rev-parse --show-toplevel 2>/dev/null || true)"
fi
[ -d "${REPO}" ] && cd "${REPO}" || fail "repo missing at ${REPO}"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "not a git repo"

echo "== FINAL HARD GATE =="

PORC="${EVID}/status.${TS}.porcelain.txt"
git status --porcelain=v1 > "${PORC}" || true
git status > "${EVID}/status_human.${TS}.txt" 2>>"${DIAG_LOG}" || true

# G0: no tracked modifications/staged
if awk '($1 ~ /^(M|A|D|R|C|UU|\?\?)$/){print}' "${PORC}" | grep -Eq '^(M|A|D|R|C|UU) '; then
  fail "working tree has tracked changes (modified/staged). See ${PORC}"
fi

# G1: untracked only allowed in whitelist
WL_REGEX='^(\.DS_Store|\.idea/|\.vscode/|\.fleet/|\.env\.example|README\.local\.md)$'
UNTRACK="${EVID}/untracked.${TS}.txt"
awk '$1=="??"{print $2}' "${PORC}" > "${UNTRACK}" || true
if [ -s "${UNTRACK}" ]; then
  BAD="${EVID}/untracked_bad.${TS}.txt"
  grep -Ev "${WL_REGEX}" "${UNTRACK}" > "${BAD}" || true
  if [ -s "${BAD}" ]; then
    echo "Untracked not allowed (non-whitelisted):" >> "${DIAG_LOG}"
    sed -n '1,200p' "${BAD}" >> "${DIAG_LOG}"
    fail "untracked files present outside whitelist"
  fi
fi

# G2: submodule drift check
if [ -f .gitmodules ]; then
  git submodule status --recursive > "${EVID}/submodule_status.${TS}.txt" 2>>"${DIAG_LOG}" || true
  if awk '{print $1}' "${EVID}/submodule_status.${TS}.txt" | grep -Eq '^[-+U]'; then
    fail "submodule status indicates drift/uninitialized (see submodule_status)"
  fi
fi

# G3: SSOT policy — forbid .env + env_file + source .env
ENV_HITS="${EVID}/env_files_hits.${TS}.txt"
( find . -type f -name ".env" -o -name "*.env" 2>/dev/null \
    | grep -vE '^\./\.env\.example$' \
) > "${ENV_HITS}" || true
if [ -s "${ENV_HITS}" ]; then
  sed -n '1,200p' "${ENV_HITS}" >> "${DIAG_LOG}"
  fail "env files detected (policy violation). Use /etc/livraone/hub.env SSOT."
fi

POLICY_HITS="${EVID}/policy_hits.${TS}.txt"
: > "${POLICY_HITS}"
# Ignore docs and this gate itself to avoid self-matching policy text.
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=docs --exclude=FINAL_HARD_GATE.sh -E '^\s*env_file\s*:' . >> "${POLICY_HITS}" 2>/dev/null || true
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=docs --exclude=FINAL_HARD_GATE.sh -E '(^|\s)(source|\.)\s+(\./)?\.env(\s|$)' . >> "${POLICY_HITS}" 2>/dev/null || true
if [ -s "${POLICY_HITS}" ]; then
  sed -n '1,200p' "${POLICY_HITS}" >> "${DIAG_LOG}"
  fail "policy violation: env_file or sourcing .env detected"
fi

# G4: required seed/gate files exist
[ -f ops/keycloak/seed-hub-client.sh ] || fail "missing ops/keycloak/seed-hub-client.sh"
[ -f scripts/gates/gate_keycloak_hub_client.sh ] || fail "missing scripts/gates/gate_keycloak_hub_client.sh"

echo "PASS: repo hygiene + SSOT policy checks ok" >> "${DIAG_LOG}"
pass
