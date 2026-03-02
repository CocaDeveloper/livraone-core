#!/usr/bin/env bash
set -euo pipefail

die(){ echo "FAIL: $*" >&2; exit 1; }
need(){ command -v "$1" >/dev/null 2>&1 || die "missing: $1"; }

need docker
# Prefer DATABASE_URL if provided; otherwise derive connection params from SSOT.
dump_env=()
dump_args=()
if [[ -n "${DATABASE_URL:-}" ]]; then
  dump_args=("$DATABASE_URL")
else
  DB_HOST="${LIVRAONE_DB_HOST:-hub-db}"
  DB_PORT="${LIVRAONE_DB_PORT:-5432}"
  DB_USER="${LIVRAONE_DB_USER:-livraone}"
  DB_NAME="${LIVRAONE_DB_NAME:-livraone}"
  DB_PASSWORD="${LIVRAONE_DB_PASSWORD:-${NEXTAUTH_SECRET:-}}"
  [[ -n "${DB_PASSWORD:-}" ]] || die "DATABASE_URL missing and no DB password in SSOT"
  dump_env=(-e "PGPASSWORD=${DB_PASSWORD}")
  dump_args=(-h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME")
fi

work="/tmp/livraone-restore-sim.$(date +%Y%m%d-%H%M%S)"
mkdir -p "$work"

dump="$work/schema.sql"

# IMPORTANT: do not print DATABASE_URL.
# Acquire schema-only dump from the real DB using a disposable postgres client container.
# Try host network first; fall back to the livraone network for service-name resolution.
dump_ok=0
if docker run --rm --network host -e PGOPTIONS='--client-min-messages=warning' "${dump_env[@]}" postgres:16-alpine \
  pg_dump --schema-only --no-owner --no-privileges "${dump_args[@]}" > "$dump" 2>/dev/null; then
  dump_ok=1
else
  if docker run --rm --network livraone -e PGOPTIONS='--client-min-messages=warning' "${dump_env[@]}" postgres:16-alpine \
    pg_dump --schema-only --no-owner --no-privileges "${dump_args[@]}" > "$dump" 2>/dev/null; then
    dump_ok=1
  fi
fi

[[ "$dump_ok" -eq 1 ]] || die "pg_dump failed (db not reachable?)"

# Bring up isolated postgres container for restore test.
name="livraone-restore-sim-$$"
pw="restore_sim_pw"
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

# Wait for postgres ready
for i in $(seq 1 60); do
  if docker exec "$name" pg_isready -U postgres >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

docker exec "$name" pg_isready -U postgres >/dev/null 2>&1 || die "restore postgres not ready"

# Restore schema into isolated DB
docker exec -i "$name" env PGPASSWORD="$pw" psql -U postgres -d restore_sim -v ON_ERROR_STOP=1 < "$dump" >/dev/null

# Basic verification: ensure at least one table exists after restore.
cnt="$(docker exec "$name" env PGPASSWORD="$pw" psql -U postgres -d restore_sim -tAc \
  "select count(*) from information_schema.tables where table_schema not in ('pg_catalog','information_schema');")"
[[ "${cnt:-0}" -gt 0 ]] || die "restore produced zero tables"

echo "PASS"
