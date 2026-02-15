# Release Verification

## Smoke Suite
Run the smoke script against the public base URL:
```bash
BASE_URL=https://hub.livraone.com TIMEOUT_SEC=30 scripts/release/smoke.sh
```
Checks:
- DNS/TLS reachability (`curl -I` with retries)
- `GET /api/health` returns HTTP 200 and expected JSON payload
- Optional `GET /` returns HTTP 200 (warn only if not)

## Compose Verification
Validate services and health on the VPS:
```bash
scripts/release/verify-compose.sh
```
Checks:
- All services running
- No unhealthy/restarting containers
- Traefik reachable on localhost

## Evidence
Store logs under `/tmp/livraone-phase15` on the VPS or the CI runner.
