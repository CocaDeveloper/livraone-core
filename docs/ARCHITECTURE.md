# LivraOne Phase 4 Architecture

## Edge Gateway
Traefik v3 runs inside `infra/compose.yaml` on the shared `livraone` Docker network. It exposes two entrypoints:
- `web` listens on port 80 and performs an automatic HTTP → HTTPS redirect via the `https-redirect` middleware defined in `infra/traefik/dynamic.yaml`.
- `websecure` listens on port 443 and terminates TLS for application hosts.

The static configuration in `infra/traefik/traefik.yaml` enables the Docker provider (services must opt-in via labels, plus placeholders for `auth`, `hub`, and `invoice`) and mounts the dynamic file that supplies the shared redirect middleware and TLS options.

## TLS and DNS-01
Traefik uses `certificatesResolvers.cloudflare` to request certificates via Let’s Encrypt DNS-01 challenges. Tokens are injected through the `.env` file (mirroring the `.env.example` variables `CF_API_TOKEN` and `ACME_EMAIL`), with credentials never checked into git.

ACME state persists to `infra/acme.json` (mode 600) so certificate renewals survive container restarts. When hostname rules resolve (e.g., `hub.livraone.com`), Traefik selects the resolver, confirms the token via Cloudflare’s API, and stores the resulting certificate for reuse.
