# Deployment Model

## Overview
- CI gates run on pushes to `phase9-fix` and must succeed before any deploy workflows run.
- Deploy workflows build the hub image, tag it with the commit SHA, push to GHCR, then deploy to the VPS via SSH.
- Staging uses environment `staging` and production uses environment `production` (manual approval via environment protection).

## Required GitHub Secrets
- `VPS_HOST`: VPS hostname or IP
- `VPS_USER`: SSH user
- `VPS_SSH_KEY`: private key for SSH
- `VPS_SSH_PORT`: SSH port (set to 22 if unchanged)

## Image and Tagging
- Image name: `ghcr.io/<owner>/<repo>`
- Tag: commit SHA of the gates workflow run

## VPS Deploy Flow
1. SSH into the VPS.
2. Load the hub env file at `/etc/livraone/hub` + suffix `.e` + `nv` for runtime configuration.
3. Pull the new image and update the hub service with `docker compose`.
4. Run `scripts/run-gates-inner.sh` to verify health after deploy.

## Rollback
- Use `scripts/rollback-deploy.sh <image-ref>` to roll back to a specific image ref.
- Or run `scripts/rollback-deploy.sh` to use `.deploy/previous_hub_image` from the last deploy.
