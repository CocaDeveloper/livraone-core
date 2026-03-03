#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# Contract: apps/marketing and apps/hub must import shared globals
for app in marketing hub; do
  f="apps/$app/app/globals.css"
  [[ -f "$f" ]] || fail "missing $f"
  grep -q '@import "@livraone/ui/src/globals.css";' "$f" || fail "$f missing shared globals import"
done

# Contract: shared preset package exists
[[ -f packages/tailwind-config/tailwind.preset.ts ]] || fail "missing tailwind preset"
[[ -f packages/ui/src/globals.css ]] || fail "missing ui globals"

echo "PASS"
