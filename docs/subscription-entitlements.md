# Phase 37 — Subscription state machine + entitlement enforcement (stub-backed)

## Goal
Introduce deterministic subscription states and entitlements, enforced server-side (contract-level).
No live billing. No infra/auth redesign.

## Subscription statuses
- trialing
- active
- past_due
- canceled

## Plans (baseline)
- free
- starter
- pro
- enterprise

## Enforcement rule (baseline)
- Access allowed only when status is `trialing` or `active`.
- Access denied when `past_due` or `canceled`.

## Implementation modules
- `apps/hub/src/lib/subscription/*`
- Stub store uses in-memory map (future phase may persist to DB).

## Non-goals
- No checkout/webhooks
- No DB migrations (unless explicitly added in later phase)
