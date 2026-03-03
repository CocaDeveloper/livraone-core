# Phase 46 — Feature gating by plan

## Goal
Introduce deterministic, server-side feature gating based on subscription plan/status.

## Contract
- `apps/hub/src/lib/features/*`
  - `assertFeatureForTenant(tenantId, featureKey)`
  - `isFeatureEnabledForTenant(tenantId, featureKey)`

## Source of truth
- Subscription: DB-backed (Phase 40)
- Entitlements mapping: Phase 37 `entitlementsFor(planId, status)`

## Baseline feature keys
- exports
- audit
- advanced_rbac

## Enforcement proof point
- `POST /api/features/assert` resolves tenantId from host and asserts the feature.

## Non-goals
- No UI redesign
- No provider activation
- No auth model changes
