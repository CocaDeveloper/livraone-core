#!/usr/bin/env bash
set -euo pipefail

fail(){ echo "FAIL: $*"; exit 1; }

RELEASE_TAG="${RELEASE_TAG:-}"
PREV_TAG="${PREV_TAG:-}"

test -n "$RELEASE_TAG" || fail "RELEASE_TAG is required"

HEAD_REF="${RELEASE_HEAD:-HEAD}"

# Determine base ref
if [ -z "$PREV_TAG" ]; then
  # Deterministic default: base equals HEAD_REF (no history required).
  BASE="${HEAD_REF}"
else
  BASE="$PREV_TAG"
fi

HEAD_SHA="$(git rev-parse "${HEAD_REF}")"
# Deterministic: use commit time in UTC (avoids drift across runs)
HEAD_EPOCH="$(git show -s --format=%ct "${HEAD_REF}")"
DATE_UTC="$(date -u -d "@${HEAD_EPOCH}" +%Y-%m-%dT%H:%M:%SZ)"

OUT="docs/releases/${RELEASE_TAG}.md"
mkdir -p docs/releases

{
  echo "# Release ${RELEASE_TAG}"
  echo
  echo "- Date (UTC): ${DATE_UTC}"
  echo "- Head SHA: ${HEAD_SHA}"
  echo "- Base: ${BASE}"
  echo
  echo "## Merged changes"
  echo
  # Deterministic ordering: by commit topo order in log output
  # Format: shortsha subject
  git log --no-decorate --pretty=format:'- %h %s' "${BASE}..${HEAD_REF}" || true
  echo
} > "${OUT}"

echo "${OUT}"
