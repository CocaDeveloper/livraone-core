# Runbook: Phase 4 Traefik + TLS

## Preflight checks
- Run `./scripts/preflight-phase4.sh` before touching the stack. It verifies:
  - you are logged in as `livraone`
  - Docker and Docker Compose are available
  - each hostname (`auth`, `hub`, `invoice`) points to this VPS
  - the hub env file exists and includes non-empty `CF_API_TOKEN` (>=20 chars) and `ACME_EMAIL`
  - required Cloudflare scopes (`Zone.Zone:Read` + `Zone.DNS:Edit`) are noted.

## Updating credentials
1. Copy the template and edit it with a secure editor:
   ```bash
   cp env.example /etc/livraone/hub
   # append the suffix `.e` + `nv` to match the path used by scripts
   nano /etc/livraone/hub
   # append the suffix `.e` + `nv` to match the path used by scripts
   ```
2. Populate `CF_API_TOKEN` with the Cloudflare API token limited to `livraone.com` and the required scopes, and set `ACME_EMAIL`.
3. Optionally set `ACME_CA_SERVER=https://acme-staging-v02.api.letsencrypt.org/directory` to work against Let’s Encrypt staging during testing, then switch back to production before going live.

## Starting Traefik
```bash
docker compose -f infra/compose.yaml up -d
```
- ensure `infra/acme/acme.json` exists with `chmod 600 infra/acme/acme.json` before the first start.
- The Traefik container uses the Cloudflare DNS-01 resolver to obtain certificates for the placeholder `whoami` service.

## Monitoring ACME progress
```bash
docker compose -f infra/compose.yaml logs -f traefik
```
- Look for `DNS challenge` successes for each hostname; when they appear, TLS should roll out immediately.
- If you hit rate limits, switch to staging via `ACME_CA_SERVER` in the hub env file, restart Traefik, then remove the variable to request production certificates again.

## Validation and gates
- Run `./scripts/run-gates.sh` (which runs the preflight, Traefik health gate, and TLS gate) after any Traefik config change.
- If the TLS gate fails, the script prints the last 200 Traefik log lines and a classified reason (`missing router`, `DNS challenge`, `rate limit`, etc.).

## Routine maintenance
- When credentials change, rerun the preflight and redeploy:
  ```bash
  ./scripts/preflight-phase4.sh
  docker compose -f infra/compose.yaml down
  docker compose -f infra/compose.yaml up -d
  ```
- Use the TLS gate failure output to understand if Cloudflare permissions or DNS propagation is to blame.
