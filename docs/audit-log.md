# Phase 39 — Audit log (append-only baseline)

## Goal
Introduce deterministic append-only audit log for critical domain changes.

## Properties
- Append-only (no delete/update operations exposed)
- Stub-backed (in-memory)
- Deterministic ID generation
- No network
- No secrets printed

## Event types (baseline)
- subscription.updated
- rbac.role_changed
- auth.login
- auth.logout
- system.event

## Current integration
- Subscription updates call appendAudit().

Future phases may:
- Persist audit to DB
- Enforce audit on RBAC changes
- Add middleware hooks for auth events
