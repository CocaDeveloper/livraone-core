#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

DOCKERFILE="apps/hub/Dockerfile"
COMPOSE="infra/compose.yaml"
TSCONFIG="apps/hub/tsconfig.json"
TAILWIND="apps/hub/tailwind.config.js"

[ -f "$DOCKERFILE" ] || fail "missing $DOCKERFILE"
[ -f "$COMPOSE" ] || fail "missing $COMPOSE"
[ -f "$TSCONFIG" ] || fail "missing $TSCONFIG"
[ -f "$TAILWIND" ] || fail "missing $TAILWIND"

if rg -q "@livraone/ui" apps/hub; then
  [ -d packages/ui ] || fail "missing packages/ui"
  rg -q "^COPY[[:space:]]+packages/ui" "$DOCKERFILE" || fail "hub Dockerfile must copy packages/ui when @livraone/ui is referenced"

  hub_block=$(awk '
    /^  hub:/ {in=1; next}
    in && /^  [a-zA-Z0-9_-]+:/ {exit}
    in {print}
  ' "$COMPOSE")

  echo "$hub_block" | grep -q 'context: \.' || fail "hub build context must be repo root when @livraone/ui is referenced"
fi

python - <<'PY'
import json, sys
path = "apps/hub/tsconfig.json"
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)
opts = data.get("compilerOptions", {})
if opts.get("baseUrl") != ".":
    sys.exit("FAIL: tsconfig compilerOptions.baseUrl must be '.'")
paths = opts.get("paths", {})
alias = paths.get("@/*")
if not isinstance(alias, list) or not any(p.endswith("/*") for p in alias):
    sys.exit("FAIL: tsconfig paths must include '@/*'")
PY

command -v node >/dev/null 2>&1 || fail "node is required for tailwind config syntax check"
node --check "$TAILWIND" >/dev/null 2>&1 || fail "tailwind config syntax invalid: $TAILWIND"

echo "PASS"
