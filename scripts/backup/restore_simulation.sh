#!/usr/bin/env bash
set -euo pipefail

die(){ echo "FAIL: $*" >&2; exit 1; }
need(){ command -v "$1" >/dev/null 2>&1 || die "missing: $1"; }

need docker

[[ -n "${DATABASE_URL:-}" ]] || die "DATABASE_URL missing"

work="/tmp/livraone-restore-sim.$(date +%Y%m%d-%H%M%S)"
mkdir -p "$work"
dump="$work/schema.sql"

# Use postgres image to run pg_dump (no local dependency)
docker run --rm \
  --network host \
  -e DATABASE_URL="$DATABASE_URL" \
  postgres:16-alpine \
  sh -c 'pg_dump --schema-only --no-owner --no-privileges "$DATABASE_URL"' \
  > "$dump"

name="livraone-restore-sim-$$"
pw="restore_pw"
port="55432"

cleanup(){
  docker rm -f "$name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run -d --name "$name" \
  -e POSTGRES_PASSWORD="$pw" \
  -e POSTGRES_USER="postgres" \
  -e POSTGRES_DB="restore_sim" \
  -p "127.0.0.1:${port}:5432" \
  postgres:16-alpine >/dev/null

for i in $(seq 1 60); do
  if docker exec "$name" pg_isready -U postgres >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

docker exec "$name" pg_isready -U postgres >/dev/null 2>&1 || die "postgres not ready"

docker exec -i "$name" psql -U postgres -d restore_sim < "$dump"

cnt="$(docker exec "$name" psql -U postgres -d restore_sim -tAc \
  "select count(*) from information_schema.tables where table_schema not in ('pg_catalog','information_schema');")"

[[ "${cnt:-0}" -gt 0 ]] || die "restore produced zero tables"

echo "PASS"
