# Phase 34 — RBAC matrix + enforcement (contract)

## Goal
Define a deterministic RBAC contract and provide a single enforcement module.
No auth model changes. No infra changes.

## Roles (baseline)
- owner
- admin
- member
- viewer
- billing
- support

> If your current session/claims uses different role strings, map them at the integration edge (do not change auth model).

## Permissions (baseline)
- tenant:read
- tenant:write
- users:read
- users:invite
- users:remove
- billing:read
- billing:write
- settings:read
- settings:write
- audit:read
- content:read
- content:write

## Surfaces requiring enforcement (baseline)
- Admin panel (server-side guards)
- Client panel (server-side guards)
- API routes (route handlers must assert)
- Server actions (must assert)

## Integration contract
- Use `assertPermission({ roles }, permission)` on the server.
- UI-only gating is not sufficient; enforcement must happen server-side.

## Non-goals
- No role storage redesign
- No Keycloak claim schema changes
- No new providers
