#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core
./scripts/gate-traefik.sh
./scripts/gate-tls.sh
