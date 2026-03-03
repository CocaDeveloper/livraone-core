# Panel Access Contract (Baseline)

This contract is deterministic and enforces file/guard presence, not live provider behavior.

## Required
- Admin guard helper must exist:
  - apps/hub/lib/auth/admin_guard.ts
- Admin-only export endpoint must exist and use admin guard:
  - apps/hub/app/api/admin/attribution/export/route.ts
- Provider layer must remain stub-friendly (no live provider assumption):
  - apps/hub/lib/providers/index.ts exists
- No placeholder messages that indicate incomplete wiring:
  - "Admin guard not wired" MUST NOT exist

## Notes
- Runtime auth/role correctness is validated later (RBAC/claims mapping phases).
