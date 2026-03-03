#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# Require at least one of these to exist and be patched
candidates=(
  "apps/hub/app/page.tsx"
  "apps/hub/app/dashboard/page.tsx"
  "apps/hub/app/panel/page.tsx"
  "apps/hub/app/(panel)/page.tsx"
)

found=0
for f in "${candidates[@]}"; do
  if [[ -f "$f" ]]; then
    if grep -q "PHASE60_UI_SHELL" "$f" && grep -q "Panel" "$f" && grep -q "SurfaceCard" "$f"; then
      found=1
      break
    fi
  fi
done

[[ "$found" -eq 1 ]] || fail "no hub dashboard page patched with @livraone/ui shell marker"
echo "PASS"
