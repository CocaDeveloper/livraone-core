# UI Routing Contract

This document is the single source of truth for core UI routes and their app ownership.

## Reference Images

- `reference/land.png` (marketing landing reference)
- `reference/login.png` (hub login reference)
- `reference/painel.png` (hub dashboard reference)

## Marketing App (Public)

Domain: `livraone.com` (and `www.livraone.com`)

Routes:

- `/`
  - Source: `apps/marketing/app/page.tsx`
  - Expected: HTTP `200` on `https://livraone.com/`

## Hub App (Authenticated)

Domain: `hub.livraone.com`

Routes:

- `/login`
  - Source: `apps/hub/app/login/page.tsx`
  - Expected: HTTP `200` on `https://hub.livraone.com/login`

- `/dashboard`
  - Source: `apps/hub/app/dashboard/page.tsx`
  - Expected unauthenticated behavior: HTTP `302` or `307` redirect to `/login` (middleware-driven)

- `/painel`
  - Source: `apps/hub/app/painel/page.tsx`
  - Behavior: aliases `/dashboard` by redirecting to `/dashboard` OR rendering the same UI.
  - Expected unauthenticated behavior: HTTP `302` or `307` redirect to `/login` (either directly, or after redirecting to `/dashboard`).
