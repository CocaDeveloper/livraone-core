# Current Infrastructure State

## Snapshot
- Ubuntu 22.04 VPS
- Docker Compose stack (`infra/compose.yaml`)
- Traefik v3 for TLS termination and routing
- GitHub Actions deploy workflows for staging and production
- Secrets SSOT: `/etc/livraone/hub.env`
- No dotenv file usage in repo; `env_file` in Compose is forbidden
