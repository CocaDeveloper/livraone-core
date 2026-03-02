#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# Scan tracked files only (deterministic)
# Exclude known safe paths
files="$(git ls-files \
  ':!:pnpm-lock.yaml' \
  ':!:package-lock.json' \
  ':!:yarn.lock' \
  ':!:**/*.svg' \
  ':!:**/*.png' \
  ':!:**/*.jpg' \
  ':!:**/*.jpeg' \
  ':!:**/*.webp' \
  ':!:**/*.ico' \
  ':!:**/*.pdf' \
  ':!:**/*.woff' \
  ':!:**/*.woff2' \
  ':!:**/*.ttf' \
  ':!:**/*.eot' \
  ':!:**/*.map' \
  ':!:**/CHANGELOG.md' \
  ':!:docs/releases/*.md' \
  )"

# Fast regexes for common secret patterns (keep conservative)
# - private keys
# - AWS keys
# - Stripe secret
# - JWT-like long tokens
# - "password=" etc (non-test)
rg_opts=(--no-heading --line-number --fixed-strings)

# 1) Private keys
if printf "%s\n" "$files" | xargs -r rg -n 'BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY' >/dev/null; then
  fail "private key material detected"
fi

# 2) Common vendor secrets (regex mode)
if printf "%s\n" "$files" | xargs -r rg -n 'AKIA[0-9A-Z]{16}' >/dev/null; then
  fail "AWS access key detected"
fi
if printf "%s\n" "$files" | xargs -r rg -n 'sk_live_[0-9a-zA-Z]+' >/dev/null; then
  fail "Stripe live secret detected"
fi
if printf "%s\n" "$files" | xargs -r rg -n 'xox[baprs]-[0-9a-zA-Z-]{10,48}' >/dev/null; then
  fail "Slack token detected"
fi

# 3) Suspicious assignments (avoid tests)
# Only flag if key looks sensitive and value is non-empty literal.
if printf "%s\n" "$files" | xargs -r rg -n '(^|[^A-Z0-9_])(PASSWORD|SECRET|TOKEN|API_KEY|PRIVATE_KEY)\s*=\s*["'"'"'][^"'"'"']+["'"'"']' \
  --glob '!**/*test*' --glob '!**/*spec*' --glob '!**/__tests__/**' >/dev/null; then
  fail "literal secret assignment detected"
fi

echo "PASS"
