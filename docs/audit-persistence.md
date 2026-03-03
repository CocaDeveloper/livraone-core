# Phase 41 — Audit persistence (Prisma-backed)

## Goal
Persist audit events in database using append-only model.

## Changes
- Added Prisma model `AuditLog`
- Migration: phase41_audit_persistence
- store_db.ts replaces store_stub.ts
- Subscription audit integration preserved

## Properties
- Append-only (no update/delete APIs)
- Indexed by tenantId, type, createdAt
- Deterministic ordering
- No provider integration
