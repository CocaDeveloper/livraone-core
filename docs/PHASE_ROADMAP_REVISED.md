# LivraOne — Revised Master Phase Roadmap (Post-Phase 29)
Rules: SSOT-only, deterministic gates, FINAL_HARD_GATE, PR-only merges.

## Key correction
Email/SMS/Stripe are NOT implemented live until keys/providers are available.
Instead: Provider abstractions + offline stubs + contract gates are implemented now.

## Phase 30 — Providers: abstractions + stubs + SSOT placeholders (DONE IN THIS BRANCH)
- Deliverable: provider layer + outbox tables + stub contract gate.

## Phase 31 — Governance pack (no GitHub API dependency inside gates)
Objective: Remove “network-to-GitHub” as a build dependency inside deterministic gates.
- Add PR closeout doctor that reads PR number directly (no listing by title).
- Add local gates that do not require GitHub API.
Deliverable: closeout doctor script + docs.

## Phase 32 — Admin/Client Panel Access Baseline (no external providers)
Objective: Ensure admin + client can access panel pages reliably.
- Create explicit admin role mapping (if absent) using existing NextAuth callbacks (no auth redesign).
- Add deterministic UI route contract tests (route existence + guard presence).
Deliverable: gate_admin_client_access_contract.sh PASS.

## Phase 33 — Tenant isolation foundations
Objective: Introduce tenant scoping in DB access.
Deliverable: tenant middleware + tests PASS.

## Phase 34 — RBAC matrix + enforcement
Objective: Roles/permissions file + guards applied.
Deliverable: RBAC tests PASS.

## Phase 35 — Billing stub enforcement (NO Stripe)
Objective: Gate premium features using stub entitlement in DB.
Deliverable: enforcement tests PASS.

## Phase 36 — Notifications dispatcher stub (NO Email/SMS live)
Objective: Unified notification queue writing to outbox (email/sms/inapp).
Deliverable: dispatcher tests PASS.

## Phase 37+ (later, when keys exist)
- Live Email provider implementation + verification gate
- Live SMS provider implementation + verification gate
- Live Stripe implementation + webhook verification gate
