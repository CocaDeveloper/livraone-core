#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

DOC="docs/PROJECTS_CONTRACT.md"
API_LIST="apps/hub/app/api/projects/route.ts"
API_GET="apps/hub/app/api/projects/[id]/route.ts"
MIG="apps/hub/prisma/migrations/20260215000000_init_projects/migration.sql"
MW="apps/hub/middleware.ts"

[ -f "$DOC" ] || { echo "missing $DOC" >&2; exit 1; }
[ -f "$API_LIST" ] || { echo "missing $API_LIST" >&2; exit 1; }
[ -f "$API_GET" ] || { echo "missing $API_GET" >&2; exit 1; }
[ -f "$MIG" ] || { echo "missing $MIG" >&2; exit 1; }
[ -f "$MW" ] || { echo "missing $MW" >&2; exit 1; }

# API response key contract
rg -n 'NextResponse\.json\(\{ items:' "$API_LIST" >/dev/null || { echo "list endpoint must return { items: ... }" >&2; exit 1; }
rg -n 'NextResponse\.json\(\{ item:' "$API_LIST" >/dev/null || { echo "post endpoint must return { item: ... }" >&2; exit 1; }
rg -n 'NextResponse\.json\(\{ item:' "$API_GET" >/dev/null || { echo "get-by-id endpoint must return { item: ... }" >&2; exit 1; }

# Migration contains required tables/columns (best-effort)
rg -n 'CREATE TABLE IF NOT EXISTS projects' "$MIG" >/dev/null || { echo "migration missing projects table" >&2; exit 1; }
for col in org_id name status address created_at updated_at; do
  rg -n "\\b${col}\\b" "$MIG" >/dev/null || { echo "projects missing column ${col}" >&2; exit 1; }
done

rg -n 'CREATE TABLE IF NOT EXISTS project_members' "$MIG" >/dev/null || { echo "migration missing project_members table" >&2; exit 1; }
for col in project_id user_id role created_at; do
  rg -n "\\b${col}\\b" "$MIG" >/dev/null || { echo "project_members missing column ${col}" >&2; exit 1; }
done

# Auth enforcement: /api/projects must not be added to PUBLIC_PATHS allowlist.
if rg -n '"/api/projects"' "$MW" >/dev/null 2>&1; then
  echo "middleware PUBLIC_PATHS must not include /api/projects" >&2
  exit 1
fi

echo "projects contract: OK"
