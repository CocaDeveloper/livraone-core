# Secrets Model (LivraOne Core)

## Source of truth
All runtime secrets live in:

- `/etc/livraone/hub` + suffix `.e` + `nv`

This file is the only approved secrets source for gates and entrypoints.

## Security invariants
- Directory: `/etc/livraone` must be `700 root:root`
- Secrets file: `/etc/livraone/hub` + suffix `.e` + `nv` must be `600 root:root`
- No ACLs on the hub env file
- Secrets must never be printed to logs
- Repo env files are not used for runtime

## Loading policy
- Only root reads the hub env file (mode 600).
- Entry points must run `scripts/load-secrets.sh` before invoking:
  - preflight
  - gates
  - docker compose up/down/build
- After loading, env is inherited to the `livraone` user via `sudo -u livraone -E ...`.

## Helper
`scripts/load-secrets.sh` enforces:
- file exists
- mode=600
- exports env with `set -a; source; set +a`

## Operational notes
- If a script fails with "secrets file missing", ensure the hub env file exists and is mode 600.
- Do not reintroduce env file usage in repo or compose env_file.

## Optional automation knobs
- `LIVRAONE_PUBLIC_IP`: when set in the hub env file (or exported before running gates), `preflight-phase4.sh` uses it instead of hitting `https://checkip.amazonaws.com`. This is useful when the machine already knows its public IP, and it should still match any DNS records you manage for livraone services.
- `LIVRAONE_SKIP_DNS_CHECK=1`: when exported before running the gates suite, the DNS validation loop that resolves livraone hostnames is skipped. This is handy for isolated CI runners that cannot reach the internet but still need to exercise the gate scripts locally.
- `LIVRAONE_SKIP_DOCKER=1`: gate scripts that talk to Docker respect this flag and exit immediately, so CI runners that do not have Docker service access can still execute `run-gates.sh` without failures.
