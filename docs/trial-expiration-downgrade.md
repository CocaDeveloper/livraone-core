# Phase 45 — Trial Expiration + Downgrade Engine

## Goal
Automatically expire trials and downgrade to free plan.

## Behavior
If:
  status = trialing
  currentPeriodEnd < now()

Then:
  planId → free
  status → expired
  audit event generated

Middleware blocks when:
  status != active|trialing

## Economic Effect
Introduces time-based pressure for upgrade.
