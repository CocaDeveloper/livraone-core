# Security Hardening

## SSH Hardening
- Use a dedicated deploy user (no shared accounts).
- Key-only auth: disable passwords and challenge-response.
- Deny root login.
- Restrict access with `AllowUsers` or `AllowGroups`.
- Optional: `AuthorizedPrincipalsFile` for short-lived certs.

## GitHub Actions SSH Model
- Secrets (names only): `VPS_HOST`, `VPS_USER`, `VPS_SSH_PORT`, `VPS_SSH_KEY`, `VPS_SSH_KEY_B64`.
- Rotate keys on personnel change, incident response, or quarterly.
- Least-privilege: deploy user only needs `docker` + repo access.

## Observability Exposure Policy
- NEVER expose Prometheus, Grafana, cAdvisor, or node_exporter to the public internet.
- Status UI must be protected with middleware (BasicAuth or ForwardAuth).
- Public surface is limited to `status.livraone.com` and app domains.

Example Traefik middleware (dynamic config):
```yaml
http:
  middlewares:
    status-auth:
      basicAuth:
        users:
          - "user:hashed_password"
```

Example router binding (compose labels):
```
- "traefik.http.routers.uptime-kuma.middlewares=status-auth@file"
```

Credentials for middleware must live in GitHub Secrets or `/etc/livraone/hub.env`, never in repo.

## Log Policy
- CI and ops scripts must not print host/user/port values or key lengths.
- Do not echo secrets or derived values.
- Allowed: non-sensitive diagnostics like step start/finish and exit codes.
