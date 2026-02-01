# Phase 4 Gates

| Gate | Status | Command |
| --- | --- | --- |
| Traefik container healthy + ports mapped | PENDING | `./scripts/gate-traefik.sh` |
| TLS certificates valid for `hub.livraone.com` | PENDING | `./scripts/gate-tls.sh` |

Each gate prints diagnostics when it fails. Re-run `./scripts/run-gates.sh` after making corrections to keep the table up to date.
