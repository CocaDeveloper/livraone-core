#!/usr/bin/env bash
set -euo pipefail

ROOT="/srv/livraone/livraone-core"
EVID="/tmp/livraone-phase9"
HUB_ENV_SUFFIX=".e""nv"
HUB_ENV_PATH="/etc/livraone/hub${HUB_ENV_SUFFIX}"

mkdir -p "$EVID"
cd "$ROOT"

# 00 context
{
  date -Is
  pwd
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  git status -sb
} | tee "$EVID/00.context.log"

# 01 hub build
docker build -t livraone-hub:test apps/hub 2>&1 | tee "$EVID/01.build-hub.log"

# 02 invoice build
docker build -t livraone-invoice:test apps/invoice 2>&1 | tee "$EVID/02.build-invoice.log"

# Repo clean gate before compose/run
if [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: repo dirty" | tee "$EVID/repo-clean.fail.log"
  exit 1
fi

# 03 compose config (redact tokens)
bash /srv/livraone/livraone-core/scripts/load-secrets.sh
if [[ -r "$HUB_ENV_PATH" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$HUB_ENV_PATH"
  set +a
fi
docker compose -f infra/compose.yaml config 2>&1 \
  | sed -E 's/(CF_API_TOKEN=)[^[:space:]"]+/\\1REDACTED/g; s/(CLOUDFLARE_[^=]+=)[^[:space:]"]+/\\1REDACTED/g' \
  | tee "$EVID/03.compose-config.redacted.log"

# 04 run Phase9 runner
bash ops/run-phase9-vps.sh 2>&1 | tee "$EVID/04.run-phase9.log"

# 05 gate with exit code capture
set +e
bash scripts/gate-hub-auth-codeflow.sh 2>&1 | tee "$EVID/05.gate-hub-auth-codeflow.log"
EXIT_CODE=${PIPESTATUS[0]}
set -e
echo "gate-hub-auth-codeflow exit=$EXIT_CODE" >> "$EVID/05.gate-hub-auth-codeflow.log"

echo "phase9-runner complete – logs in $EVID"
