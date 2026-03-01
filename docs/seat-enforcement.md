# Phase 42 — Seat Enforcement (Membership-aware)

## Goal
Enforce max seats per tenant based on subscription plan.

## Behavior
- free: 1 seat
- pro: 5 seats
- enterprise: 1000 seats

## Flow
createMembership()
 → assertSeatAvailable()
 → prisma.membership.create()
 → audit event

## Properties
- Deterministic enforcement
- Subscription-backed
- Audit-integrated
- No billing provider dependency
