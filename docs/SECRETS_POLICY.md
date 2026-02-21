# Secrets Policy

## Centralized Secrets Model
All runtime secrets live in a single source of truth: `/etc/livraone/hub.env` on the VPS. CI and deploy scripts source this file on the VPS when needed.

## Forbidden Patterns
- Dotenv files in the repo are disallowed
- Compose `env_file` usage is forbidden

## CI Export Logic
Deploy workflows source `/etc/livraone/hub.env` and export variables into the environment before running gates. Secrets are never printed in logs.
