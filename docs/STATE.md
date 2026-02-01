# Phase 4 Gates

| Gate | Status | Command | Notes |
| --- | --- | --- | --- |
| Traefik container healthy + ports mapped | PASS | `./scripts/gate-traefik.sh` | Container is healthy after the compose stack started; HTTP/HTTPS ports are mapped to 80/443. |
| TLS certificates valid for `hub.livraone.com` | FAIL | `./scripts/gate-tls.sh` | Cloudflare token is not configured yet, so TLS handshake against `hub.livraone.com` fails (`curl` exit 35 / `openssl s_client` reports no certificate). |

Re-run `./scripts/run-gates.sh` after supplying a real `CF_API_TOKEN`/`ACME_EMAIL` in `.env` and once Traefik issues a certificate to flip the TLS gate to PASS.
