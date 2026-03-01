# Phase 38 — Middleware-level subscription enforcement

## Goal
Enforce subscription entitlement server-side via Next.js middleware for protected Hub surfaces.

## Enforcement module
- `apps/hub/src/lib/subscription/middleware_enforce.ts`
- Uses:
  - Phase 33 tenant host parsing (`parseTenantFromHost`)
  - Phase 37 entitlement enforcement (`assertAccess`)
- Redirects denied requests to `/subscription/required?from=...`
- If tenantId cannot be resolved from host, enforcement is skipped (baseline).

## Public allowlist
- `/_next/*`, `/favicon*`, `/robots*`, `/sitemap*`
- `/login`
- `/api/auth/*`
- `/billing/*`
- `/subscription/*`
- `/` (root)

## Middleware integration
- `apps/hub/middleware.ts` must call `enforceSubscription(req)` after auth gating.
- `export const config.matcher` must be present in `apps/hub/middleware.ts`.
