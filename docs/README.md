# LivraOne Hub Documentation

## Technical Overview
LivraOne Hub is a Next.js service deployed as a container in a Docker Compose stack. It is fronted by Traefik and shares infrastructure with other services in the same stack.

## Multi-App Structure
- `apps/hub`: primary user-facing service
- `apps/invoice`: secondary service
- supporting services in compose: Traefik and a whoami test container

## Traefik Routing Concept
Traefik terminates TLS and routes requests by hostname to services defined in `infra/compose.yaml`. The hub hostname is routed to the hub service. Routing rules and TLS configuration live in the Traefik service labels and config.

## Phase Gate Philosophy
Phase gates are scripted checks that enforce invariants before and after deploys. They are used in CI and on the VPS to validate readiness, TLS, and critical paths. The goal is to fail fast on misconfiguration and keep deploys deterministic.
