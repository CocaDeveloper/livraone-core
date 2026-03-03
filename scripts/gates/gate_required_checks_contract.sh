#!/usr/bin/env bash
set -euo pipefail

EVID_DIR="${EVID_DIR:-/tmp/livraone-gates}"
mkdir -p "$EVID_DIR"
LOG="$EVID_DIR/gate_required_checks_contract.log"
RES="$EVID_DIR/gate_required_checks_contract.result.txt"
: > "$LOG"

fail(){ echo "FAIL: $*" | tee -a "$LOG" >/dev/null; echo "FAIL" > "$RES"; exit 0; }
pass(){ echo "PASS: $*" | tee -a "$LOG" >/dev/null; echo "PASS" > "$RES"; exit 0; }

echo "== gate_required_checks_contract ==" >> "$LOG"
date -u >> "$LOG"

command -v gh >/dev/null 2>&1 || fail "gh CLI not installed"
command -v jq >/dev/null 2>&1 || fail "jq not installed"
gh auth status >/dev/null 2>&1 || fail "gh not authenticated"

REPO="CocaDeveloper/livraone-core"
JSON="$(gh api "repos/${REPO}/branches/main/protection" 2>>"$LOG" || true)"
[ -n "$JSON" ] || fail "unable to fetch branch protection"

ENF="$(printf '%s' "$JSON" | jq -r '.enforce_admins.enabled // false')"
STRICT="$(printf '%s' "$JSON" | jq -r '.required_status_checks.strict // false')"
CTX_LIST="$(printf '%s' "$JSON" | jq -r '.required_status_checks.contexts[]?')"

[ "$ENF" = "true" ] || fail "enforce_admins.enabled must be true"
[ "$STRICT" = "true" ] || fail "required_status_checks.strict must be true"

echo "$CTX_LIST" | grep -Eq '(^gates$|^gates/gates$|run-gates)' \
  || fail "required_status_checks.contexts must include gates or run-gates"

pass "required checks contract OK"
