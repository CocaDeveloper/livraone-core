#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

fail(){ echo "FAIL: $*" >&2; exit 1; }

compose="infra/compose.yaml"
[[ -f "$compose" ]] || fail "compose missing"

if rg -n 'env_file' "$compose" >/dev/null; then
  fail "env_file found"
fi
if git ls-files | rg -n '(^|/)\.env($|\.)' >/dev/null; then
  fail "tracked .env"
fi

rg -n 'Host\(`livraone\.com`\)' "$compose" >/dev/null || fail "livraone.com host missing"
rg -n 'Host\(`www\.livraone\.com`\)' "$compose" >/dev/null || fail "www host missing"
rg -n 'Host\(`photos\.livraone\.com`\)' "$compose" >/dev/null || fail "photos host missing"
rg -n 'Host\(`invoice\.livraone\.com`\)' "$compose" >/dev/null || fail "invoice host missing"
rg -n 'Host\(`hub\.livraone\.com`\)' "$compose" >/dev/null || fail "hub host missing"

echo "subdomain contract OK"
