# Secrets Policy

## Centralized Secrets Model
All runtime secrets live in a single source of truth: `/etc/livraone/hub.env` on the VPS. CI and deploy scripts source this file on the VPS when needed.

## Forbidden Patterns
- Dotenv files in the repo are disallowed
- Compose `env_file` usage is forbidden

## CI Export Logic
Deploy workflows source `/etc/livraone/hub.env` and export variables into the environment before running gates. Secrets are never printed in logs.

## Required Auth Env Vars (SSOT)
The SSOT file `/etc/livraone/hub.env` MUST define the following keys (non-empty). Values must never be committed.

- NEXTAUTH_SECRET
- KEYCLOAK_ISSUER
- HUB_AUTH_ISSUER
- HUB_AUTH_CLIENT_ID
- HUB_AUTH_CLIENT_SECRET
- HUB_AUTH_CALLBACK_URL
