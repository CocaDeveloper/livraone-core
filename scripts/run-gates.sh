#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core
./scripts/preflight-phase4.sh
./scripts/gate-traefik.sh
./scripts/gate-tls.sh
