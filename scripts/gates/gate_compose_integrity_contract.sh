#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

files=$(git ls-files '*docker-compose*.yml' '*docker-compose*.yaml' 2>/dev/null || true)

for f in $files; do
  grep -q 'image:' "$f" || continue

  if grep -q ':latest' "$f"; then
    fail "$f uses :latest"
  fi

  if grep -q 'privileged: true' "$f"; then
    fail "$f uses privileged: true"
  fi

  if grep -q '0\.0\.0\.0:' "$f"; then
    fail "$f exposes 0.0.0.0 binding"
  fi
done

echo "PASS"
