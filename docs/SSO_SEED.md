# Keycloak SSO Seed (Hub Client)

This repo maintains an idempotent seed for the Keycloak OIDC client used by the Hub (`livraone-hub`) in realm `livraone`.

## Why
Manual Keycloak edits cause drift between environments and break auth during deploys. This seed makes the client config reproducible.

## How it runs
Run inside the Keycloak container (where `kcadm.sh` exists and admin env vars are already present):

```bash
./ops/keycloak/seed-hub-client.sh
```

## Config

Environment overrides:

KC_REALM (default: livraone)

CLIENT_ID (default: livraone-hub)

KC_URL (default: http://localhost:8080)

REDIRECTS_JSON (JSON array)

WEB_ORIGINS_JSON (JSON array)

The script prints a sorted JSON summary for drift checking.
