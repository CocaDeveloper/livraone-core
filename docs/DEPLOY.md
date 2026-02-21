# Deploy Guide

## Staging Workflow
- Workflow file: `.github/workflows/deploy-staging.yml`
- Trigger: `workflow_dispatch`
- Environment: `staging`
- Builds and pushes GHCR image tagged with commit SHA
- SSH deploys to VPS, runs compose pull/up, then runs gates

## Production Workflow
- Workflow file: `.github/workflows/deploy-production.yml`
- Environment: `production`
- Requires manual approval via environment protection
- Otherwise identical to staging flow

## Rollback
Use the rollback script on the VPS:
```bash
scripts/rollback-deploy.sh
```
Or specify a tag explicitly:
```bash
scripts/rollback-deploy.sh ghcr.io/cocadeveloper/livraone-core:<commit-sha>
```

## RUN_GATES_SECRETS_LOADED
The variable `RUN_GATES_SECRETS_LOADED=1` signals that secrets are already exported from `/etc/livraone/hub.env`, so gate scripts should not attempt privileged secret loading.

## Release Verification
After deploy, run:
```bash
BASE_URL=https://hub.livraone.com TIMEOUT_SEC=30 scripts/release/smoke.sh
scripts/release/verify-compose.sh
```
Logs should be stored under `/tmp/livraone-phase15` on the VPS.

## Canary Routing (Optional)
- `canary.hub.livraone.com` routes to the Hub service
- `X-Canary: 1` header routes to the canary router
This is a traffic segregation mechanism; it uses the same service unless a separate canary service is introduced.
