# Infrastructure catalog

- `compose.yaml` – defines Traefik v3, its health check, shared network, and a temporary `whoami` backend that registers HTTPS routers for `auth`, `hub`, and `invoice` via labels. Replace the placeholder service with the real stacks when they are ready.
- `traefik/traefik.yaml` – the static configuration: entrypoints, Docker provider, Cloudflare certificates resolver, and ping endpoint.
- `traefik/dynamic.yaml` – shared middlewares and TLS options consumed by Traefik labels.
- `acme/acme.json` – persistent storage for certificates (mode 600, not tracked by the gate scripts).
