# FINAL HARD GATE

Enforces:

- Clean working tree (no staged/modified tracked files)
- Untracked files only from a strict whitelist
- No submodule drift (when `.gitmodules` exists)
- SSOT policy: forbid `.env` files, `env_file:` in compose, and `source .env` patterns
- Ensures Keycloak seed & gate scripts exist

Evidence:
- `/tmp/livraone-final-hard-gate/evidence/*`
