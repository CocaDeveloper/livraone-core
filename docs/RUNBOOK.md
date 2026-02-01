# Runbook: Phase 4 Traefik + TLS

## Prerequisites
- Cloudflare API token scoped to `Zone.Zone`, `Zone.DNS`, and `Zone.Cache Purge` (read/write on the zones for `livraone.com`).
- Valid `CF_API_TOKEN` and `ACME_EMAIL` values stored locally in `/srv/livraone/livraone-core/.env` (the repo keeps `.env.example` as a template). The `.env` file must never be committed.

## First run
1. Copy `.env.example` to `.env` and populate the token/email:
   ```bash
   cp .env.example .env
   # edit .env to add the real CF_API_TOKEN and ACME_EMAIL values
   ```
2. Ensure `infra/acme.json` exists with tight permissions:
   ```bash
   chmod 600 infra/acme.json
   ```
3. Start Traefik via Docker Compose and let it request certificates:
   ```bash
   docker compose -f infra/compose.yaml up -d
   ```
4. Watch the logs for ACME progress (`docker compose -f infra/compose.yaml logs -f traefik`). The Cloudflare DNS-01 challenge must succeed for `hub.livraone.com`, `www.livraone.com`, etc.

## Day-to-day
- Run `./scripts/run-gates.sh` after any configuration change to ensure the Traefik container is healthy and TLS certificates remain valid.
- Monitor `infra/acme.json` size; Traefik rewrites it when certificates renew.

## Renewals
Let’s Encrypt’s automatic renewal kicks in before expiry. To force renewals:
```bash
docker compose -f infra/compose.yaml restart traefik
```
If Cloudflare limits are reached, switch to the staging CA by setting `TRAFFIC_TLS_CA_SERVER=https://acme-staging-v02.api.letsencrypt.org/directory` via an override file before debugging, then revert to production when done.
