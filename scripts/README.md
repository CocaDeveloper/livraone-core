# LivraOne scripts index

- `gate-traefik.sh` – ensures the Traefik container is healthy, exposes ports 80/443, and uses the shared `livraone` network.
- `gate-tls.sh` – confirms the HTTP host redirects to HTTPS, that `https://hub.livraone.com` responds with 2xx/3xx/4xx, and that Let’s Encrypt issued the certificate via `openssl s_client`.
- `run-gates.sh` – runs both gates sequentially and fails fast so automation can detect regressions quickly.
