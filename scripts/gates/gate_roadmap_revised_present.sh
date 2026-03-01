#!/usr/bin/env bash
set -euo pipefail
EVI_DIR="${EVI_DIR:-/tmp/livraone-gate-roadmap-revised}"
mkdir -p "$EVI_DIR"
fail(){ echo "FAIL: $*" | tee "$EVI_DIR/fail.txt" >&2; exit 1; }

test -f "docs/PHASE_ROADMAP_REVISED.md" || fail "missing docs/PHASE_ROADMAP_REVISED.md"
grep -q "Provider abstractions + offline stubs" "docs/PHASE_ROADMAP_REVISED.md" || fail "missing provider-stub correction text"
echo "PASS" | tee "$EVI_DIR/pass.txt"
