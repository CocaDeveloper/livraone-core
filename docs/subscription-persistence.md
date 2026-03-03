# Phase 40 — Subscription persistence (Prisma-backed)

## Goal
Move subscription state from in-memory stub to DB-backed model.

## Changes
- Added Prisma model `Subscription`
- Migration: phase40_subscription_persistence
- store_db.ts replaces store_stub.ts as primary store
- Audit integration preserved

## Guarantees
- tenantId unique
- Deterministic upsert behavior
- No provider change
- No auth redesign
