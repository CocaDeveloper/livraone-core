# Infrastructure catalog

- `compose.yaml` – defines Traefik v3, its health check, shared network, and placeholder services with labels tied to `auth`, `hub`, and `invoice`.
- `traefik/traefik.yaml` – the static configuration: entrypoints, Docker provider, Cloudflare certificates resolver, and ping endpoint.
- `traefik/dynamic.yaml` – shared middlewares and TLS options consumed by Traefik labels.
- `acme.json` – persistent storage for certificates (mode 600, not tracked by the gate scripts).
