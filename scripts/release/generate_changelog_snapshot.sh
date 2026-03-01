#!/usr/bin/env bash
set -euo pipefail

fail(){ echo "FAIL: $*"; exit 1; }

RELEASE_TAG="${RELEASE_TAG:-}"
PREV_TAG="${PREV_TAG:-}"

test -n "$RELEASE_TAG" || fail "RELEASE_TAG is required"

HEAD_REF="${RELEASE_HEAD:-HEAD}"

# Determine base ref + display label
if [ -z "$PREV_TAG" ]; then
  # Deterministic default: base equals HEAD_REF (no history required).
  # Display label stays stable to avoid CI merge-commit drift.
  BASE="${HEAD_REF}"
  BASE_LABEL="HEAD"
else
  BASE="$PREV_TAG"
  BASE_LABEL="$PREV_TAG"
fi

OUT="docs/releases/${RELEASE_TAG}.md"
mkdir -p docs/releases

{
  echo "# Release ${RELEASE_TAG}"
  echo
  echo "- Base: ${BASE_LABEL}"
  echo
  echo "## Merged changes"
  echo
  # Deterministic ordering: by commit topo order in log output
  # Format: shortsha subject
  git log --no-decorate --pretty=format:'- %h %s' "${BASE}..${HEAD_REF}" || true
  echo
} > "${OUT}"

echo "${OUT}"
