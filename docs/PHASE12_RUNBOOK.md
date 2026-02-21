# Phase 12 Runbook

## Trigger Deploys
- Staging:
  ```bash
  gh workflow run deploy-staging.yml --repo CocaDeveloper/livraone-core --ref phase9-fix
  ```
- Production:
  ```bash
  gh workflow run deploy-production.yml --repo CocaDeveloper/livraone-core --ref phase9-fix
  ```

## Verify Deploy
```bash
# check latest staging run
GH_TOKEN=... gh api repos/CocaDeveloper/livraone-core/actions/workflows/deploy-staging.yml/runs?branch=phase9-fix&per_page=1 --jq '.workflow_runs[0] | {status, conclusion, head_sha, html_url}'

# public HTTPS check
curl -I --max-time 8 https://hub.livraone.com
curl -sS -o /dev/null -w '%{http_code}' --max-time 8 https://hub.livraone.com/api/health
curl -sS -o /dev/null -w '%{http_code}' --max-time 8 https://hub.livraone.com/api/auth/providers
```

## VPS Health Checks
```bash
cd /srv/livraone/livraone-core
docker compose -f infra/compose.yaml ps
curl -I --max-time 8 https://hub.livraone.com
```

## Rollback
```bash
cd /srv/livraone/livraone-core
# rollback to previous recorded tag
scripts/rollback-deploy.sh

# or rollback to a specific tag
scripts/rollback-deploy.sh ghcr.io/cocadeveloper/livraone-core:<commit-sha>
```

## Required GitHub Secrets
- `VPS_HOST`
- `VPS_USER`
- `VPS_SSH_KEY`
- `VPS_SSH_PORT`
