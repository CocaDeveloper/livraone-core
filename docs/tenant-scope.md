# Phase 33 — Tenant isolation foundations (contract)

## Goal
Establish an app-layer contract for tenant isolation without changing auth model or infra.

## Invariants (must hold)
- Any tenant-scoped data access MUST require a `tenantId`.
- `apps/hub/src/lib/tenant.ts` is the single contract module:
  - `requireTenantId(tenantId)` throws `TENANT_REQUIRED` if missing.
  - `withTenantWhere(tenantId, where)` merges `{ tenantId }` into Prisma `where`.

## Tenant ID Resolution (baseline)
- Prefer explicit tenantId from request context (when implemented in routes/middleware).
- Fallback: parse from host/subdomain (`parseTenantFromHost`).

## Tenant-scoped models (declare here)
- TODO: List models that are tenant-scoped in `apps/hub/prisma/schema.prisma`.
  - If schema already contains `tenantId`, ensure it is indexed appropriately (future phase).
  - If schema does not yet contain `tenantId`, Phase 34+ will introduce minimal fields/migrations per model.
  - SCHEMA_TENANTID_PLANNED

## Non-goals
- No RLS.
- No schema-per-tenant/db-per-tenant.
- No auth model change.
