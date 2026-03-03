#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

DOCKERFILE="apps/hub/Dockerfile"
CONTEXT_DIR="apps/hub"

[ -f "$DOCKERFILE" ] || fail "missing $DOCKERFILE"

DEFAULT_SCHEMA="$CONTEXT_DIR/prisma/schema.prisma"
[ -f "$DEFAULT_SCHEMA" ] || fail "missing $DEFAULT_SCHEMA"

DOCKERIGNORE="$CONTEXT_DIR/.dockerignore"
ignore_prisma=0
if [ -f "$DOCKERIGNORE" ]; then
  if grep -Eq '(^|/|[[:space:]])prisma(/|$)' "$DOCKERIGNORE"; then
    ignore_prisma=1
  fi
fi

extract_schema_path() {
  local line="$1"
  local path=""

  if [[ "$line" =~ --schema=([^[:space:]]+) ]]; then
    path="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ --schema[[:space:]]+([^[:space:]]+) ]]; then
    path="${BASH_REMATCH[1]}"
  fi

  path="${path#\"}"
  path="${path%\"}"
  path="${path#\'}"
  path="${path%\'}"

  printf '%s' "$path"
}

resolve_schema_path() {
  local schema="$1"
  local rel="$schema"

  rel="${rel#./}"
  if [[ "$rel" == /* ]]; then
    if [[ "$rel" == /app/* ]]; then
      rel="${rel#/app/}"
    else
      return 1
    fi
  fi

  if [ -f "$CONTEXT_DIR/$rel" ]; then
    printf '%s' "$CONTEXT_DIR/$rel"
    return 0
  fi

  if [ -f "$rel" ]; then
    printf '%s' "$rel"
    return 0
  fi

  return 1
}

has_generate=0
stage=0
prisma_copied=0

while IFS= read -r raw; do
  line="${raw%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  [ -z "$line" ] && continue

  if [[ "$line" =~ ^FROM[[:space:]] ]]; then
    stage=$((stage + 1))
    prisma_copied=0
    continue
  fi

  if [[ "$line" =~ ^(COPY|ADD)[[:space:]] ]]; then
    if echo "$line" | grep -Eq '^(COPY|ADD)[[:space:]]+(\.|\./)[[:space:]]+'; then
      if [ "$ignore_prisma" -eq 0 ]; then
        prisma_copied=1
      fi
    fi
    if echo "$line" | grep -Eq '^(COPY|ADD)[[:space:]].*\bprisma\b'; then
      prisma_copied=1
    fi
  fi

  if [[ "$line" =~ ^RUN[[:space:]]+npx[[:space:]]+prisma[[:space:]]+generate ]]; then
    has_generate=1
    schema_path="$(extract_schema_path "$line")"

    if [ -n "$schema_path" ]; then
      if ! resolved="$(resolve_schema_path "$schema_path")"; then
        fail "schema path $schema_path not found in repo (context $CONTEXT_DIR)"
      fi
    else
      if [ "$prisma_copied" -ne 1 ]; then
        fail "prisma schema not copied before generate in stage $stage"
      fi
      [ -f "$DEFAULT_SCHEMA" ] || fail "missing $DEFAULT_SCHEMA"
    fi
  fi

done < "$DOCKERFILE"

[ "$has_generate" -eq 1 ] || fail "no prisma generate command found"

echo "PASS"
