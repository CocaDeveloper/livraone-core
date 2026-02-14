# LivraOne scripts index

- `preflight-phase4.sh` – validates the user, Docker/Docker Compose, DNS records, and the hub env file at `/etc/livraone/hub` + suffix `.e` + `nv` before Traefik starts.
- `gate-traefik.sh` – ensures the Traefik container exists, is healthy, and exposes ports 80/443 on the shared `livraone` network.
- `gate-tls.sh` – waits for `hub.livraone.com` to redirect HTTP → HTTPS, checks the HTTPS status, inspects the certificate issuer, and prints the last 200 Traefik log lines plus a classified failure reason when it cannot finish.
- `run-gates.sh` – orchestrates `preflight-phase4.sh`, `gate-traefik.sh`, and `gate-tls.sh`, exiting immediately if any gate fails so automation can detect regressions.
