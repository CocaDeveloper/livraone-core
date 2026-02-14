# Phase 4 Gates

| Gate | Status | Command | Notes |
| --- | --- | --- | --- |
| Preflight (user, Docker, DNS, env vars) | PASS | `./scripts/preflight-phase4.sh` | Ensures the hub env file has `CF_API_TOKEN`/`ACME_EMAIL`, Docker is installed, and DNS entries all point to this VPS. |
| Traefik container healthy + ports mapped | PASS | `./scripts/gate-traefik.sh` | Container is healthy, exposing 80/443 on the shared `livraone` network. |
| TLS certificates valid for `hub.livraone.com` | FAIL | `./scripts/gate-tls.sh` | Cloudflare credentials are placeholder, so Traefik cannot complete the DNS-01 challenge (see last 200 Traefik log lines for the precise error). |

Re-run the gates after populating the hub env file with a real Cloudflare token/email (and optionally `ACME_CA_SERVER` when testing against staging). The TLS gate gives classified failure reasons (`missing router`, `DNS challenge failure`, `rate limit`, etc.) to guide follow-up actions.

# Phase 5 Gates

| Gate | Status | Command | Notes |
| --- | --- | --- | --- |
| Auth discovery endpoint responds over HTTPS | PASS | `./scripts/gate-auth-smoke.sh` | Gate output: `/tmp/livraone-phase5/gate-auth-smoke.log`. |
| Password-grant token issued with `test.user` and role `user` | PASS | `./scripts/gate-auth-e2e.sh` | Gate output: `/tmp/livraone-phase5/gate-auth-e2e.log`. |
| Issuer resolves to HTTPS | PASS | `./scripts/gate-auth-issuer.sh` | Gate output: `/tmp/livraone-phase5/gate-auth.log` (includes entire run); metadata captured at `/tmp/livraone-phase5/wellknown.json`. |

PASS criteria: all gates must run OK with strict issuer checks; evidence stored under `/tmp/livraone-phase5`.

# Phase 6 Gates

| Gate | Status | Command | Notes |
| --- | --- | --- | --- |
| Hub auth code-flow issues redirect to auth.livraone.com with client_id | FAIL | `./scripts/gate-hub-auth-codeflow.sh` | Verifies `/api/auth/signin/keycloak` performs a Keycloak redirect. |
| Hub admin API enforces RBAC | FAIL | `./scripts/gate-hub-rbac.sh` | Ensures unauthenticated requests are denied and optional admin credentials can exercise `/api/admin/ping`. |

PASS criteria: both gates run OK, `apps/hub` enforces the exact issuer and surfaces realm roles in `/api/admin/ping`.

PHASE 9 — Invoice Live Integration → PASS

Evidence:
- $EVIDENCE/T1.nextauth.invoice.js.txt
- $EVIDENCE/T4.invoice.signin.headers.txt
- $EVIDENCE/T5.hub.auth.gate.log

PHASE 9 — Invoice Live Integration → PASS

Evidence:
- $EVIDENCE/T1.nextauth.invoice.js.txt
- $EVIDENCE/T4.invoice.signin.headers.txt
- $EVIDENCE/T5.hub.auth.gate.log
