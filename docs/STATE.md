# Phase 4 Gates

| Gate | Status | Command | Notes |
| --- | --- | --- | --- |
| Preflight (user, Docker, DNS, env vars) | PASS | `./scripts/preflight-phase4.sh` | Ensures `.env` has `CF_API_TOKEN`/`ACME_EMAIL`, Docker is installed, and DNS entries all point to this VPS. |
| Traefik container healthy + ports mapped | PASS | `./scripts/gate-traefik.sh` | Container is healthy, exposing 80/443 on the shared `livraone` network. |
| TLS certificates valid for `hub.livraone.com` | FAIL | `./scripts/gate-tls.sh` | Cloudflare credentials are placeholder, so Traefik cannot complete the DNS-01 challenge (see last 200 Traefik log lines for the precise error). |

Re-run the gates after populating `.env` with a real Cloudflare token/email (and optionally `ACME_CA_SERVER` when testing against staging). The TLS gate gives classified failure reasons (`missing router`, `DNS challenge failure`, `rate limit`, etc.) to guide follow-up actions.

# Phase 5 Gates

| Gate | Status | Command | Notes |
| --- | --- | --- | --- |
| Auth discovery endpoint responds over HTTPS | PASS | `./scripts/gate-auth-smoke.sh` | Gate output: `/tmp/gate-auth-smoke.log`. |
| Password-grant token issued with `test.user` and role `user` | PASS | `./scripts/gate-auth-e2e.sh` | Gate output: `/tmp/gate-auth-e2e.log`; issuer now resolves to `https://auth.livraone.com/realms/livraone`. |

PASS criteria: both gates must reach `OK`, bootstrap must create the `livraone` realm, `hub-web`/`invoice-web` confidential clients, and the `test.user` user with the `user` realm role so automated flows can continue without manual intervention.
