#!/usr/bin/env bash
set -euo pipefail

# SSOT loader (no secrets printed)
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/ssot_env.sh"

# Phase 51: release env defaults (deterministic CI)
[ -f ./scripts/release/release-env.sh ] && source ./scripts/release/release-env.sh

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

# Phase 29 - Attribution export contract
bash scripts/gates/gate_attribution_export_contract.sh

# Phase 30 - Providers stub contract
bash scripts/gates/gate_providers_stub_contract.sh

# Phase 31 - Roadmap revised present
bash scripts/gates/gate_roadmap_revised_present.sh

# Phase 32 - Admin/Client access contract
bash scripts/gates/gate_admin_client_access_contract.sh

# Phase 33 - Tenant isolation contract
bash scripts/gates/gate_tenant_isolation_contract.sh

# Phase 34 - RBAC contract
bash scripts/gates/gate_rbac_contract.sh

# Phase 35 - Billing stub contract
bash scripts/gates/gate_billing_stub_contract.sh

# Phase 36 - Notifications dispatcher stub contract
bash scripts/gates/gate_notifications_dispatcher_stub_contract.sh

# Phase 37 - Subscription entitlements contract
bash scripts/gates/gate_subscription_entitlements_contract.sh

# Phase 38 - Subscription middleware enforcement contract
bash scripts/gates/gate_subscription_middleware_enforcement_contract.sh

# Phase 39 - Audit log append-only contract
bash scripts/gates/gate_audit_log_append_only_contract.sh

# Phase 40 - Subscription persistence (Prisma-backed) contract
bash scripts/gates/gate_subscription_persistence_prisma_contract.sh

# Phase 41 - Audit persistence (Prisma-backed) contract
bash scripts/gates/gate_audit_persistence_prisma_contract.sh

# Phase 42 - Seat enforcement contract
bash scripts/gates/gate_seat_enforcement_contract.sh

# Phase 43 - Billing activation guardrail
bash scripts/gates/gate_billing_activation_guardrail.sh

# Phase 44 - Mandatory audit enforcement gate
bash scripts/gates/gate_mandatory_audit_enforcement.sh

# Phase 45 - Trial expiration + downgrade engine
bash scripts/gates/gate_trial_expiration_engine.sh

# Phase 46 - Feature gating by plan
bash scripts/gates/gate_feature_gating_contract.sh

# Phase 47 - Stripe activation (flag-controlled)
bash scripts/gates/gate_stripe_activation_flag_contract.sh "apps/hub/src/lib/billing/stripe.ts"

# Phase 48 - Feature-level billing enforcement
bash scripts/gates/gate_billing_feature_enforcement_contract.sh "apps/hub/src/lib/billing/feature-enforcement.ts" "apps/hub/src/lib/features/guard.ts"

# Phase 49 - Tenant-scoped audit query API
bash scripts/gates/gate_tenant_audit_query_api_contract.sh "apps/hub/src/app/api/audit/route.ts"

# Phase 50 - Security headers baseline
bash scripts/gates/gate_security_headers_contract.sh "apps/hub/middleware.ts" "apps/hub/src/lib/security/headers.ts"

# Phase 50 - Rate limit baseline
bash scripts/gates/gate_rate_limit_contract.sh "apps/hub/src/lib/security/rate-limit.ts" "apps/hub"

# FINAL HARD GATE: must explicitly check result file (gate exits 0 even on FAIL)
# Phase 51 — Release tag + changelog snapshot contract
./scripts/gates/gate_release_tag_and_changelog_snapshot.sh

bash scripts/gates/gate_auth_entrypoint_contract.sh

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
