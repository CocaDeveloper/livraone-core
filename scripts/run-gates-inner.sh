#!/usr/bin/env bash
set -euo pipefail

cd /srv/livraone/livraone-core
bash scripts/preflight-phase4.sh
bash scripts/gate-traefik.sh
bash scripts/gate-tls.sh
