#!/usr/bin/env bash
set -euo pipefail

: "${RELEASE_HEAD:=HEAD}"

fail(){ echo "FAIL: $*"; exit 1; }
pass(){ echo "PASS"; }

RELEASE_TAG="${RELEASE_TAG:-}"
ENFORCE_RELEASE_TAG="${ENFORCE_RELEASE_TAG:-0}"
RELEASE_HEAD="${RELEASE_HEAD:-HEAD}"

test -n "$RELEASE_TAG" || fail "RELEASE_TAG is required for release snapshot gate"

SNAP="docs/releases/${RELEASE_TAG}.md"
test -f "$SNAP" || fail "missing snapshot file: $SNAP"

# Optional: enforce git tag exists and points to HEAD
if [ "$ENFORCE_RELEASE_TAG" = "1" ] || [ "$ENFORCE_RELEASE_TAG" = "true" ] || [ "$ENFORCE_RELEASE_TAG" = "TRUE" ]; then
  git rev-parse -q --verify "refs/tags/${RELEASE_TAG}" >/dev/null 2>&1 || fail "missing git tag: ${RELEASE_TAG}"
  TAG_SHA="$(git rev-parse "${RELEASE_TAG}")"
  HEAD_SHA="$(git rev-parse HEAD)"
  test "$TAG_SHA" = "$HEAD_SHA" || fail "tag ${RELEASE_TAG} does not point to HEAD"
fi

# Deterministic regeneration + compare
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cp -a "$SNAP" "$TMP_DIR/existing.md"
rm -f "$SNAP"

# Generate into repo path deterministically (ignore external PREV_TAG)
RELEASE_TAG="$RELEASE_TAG" RELEASE_HEAD="$RELEASE_HEAD" PREV_TAG="" ./scripts/release/generate_changelog_snapshot.sh >/dev/null

diff -u "$TMP_DIR/existing.md" "$SNAP" >/dev/null || fail "snapshot mismatch vs generator (regenerate and commit docs/releases/${RELEASE_TAG}.md)"

pass
