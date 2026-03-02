#!/usr/bin/env bash
set -euo pipefail

die(){ echo "FAIL: $*" >&2; exit 1; }
need(){ command -v "$1" >/dev/null 2>&1 || die "missing: $1"; }

need docker

work="/tmp/livraone-restore-sim.$(date +%Y%m%d-%H%M%S)"
mkdir -p "$work"

src="livraone-src-$$"
dst="livraone-dst-$$"
pw="pw"

cleanup(){
  docker rm -f "$src" "$dst" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Create source postgres
docker run -d --name "$src" \
  -e POSTGRES_PASSWORD="$pw" \
  -e POSTGRES_DB="srcdb" \
  postgres:16-alpine >/dev/null

# Wait
for i in $(seq 1 30); do
  docker exec "$src" pg_isready -U postgres >/dev/null 2>&1 && break
  sleep 1
done

# Create sample schema (simulate production)
docker exec "$src" psql -U postgres -d srcdb <<'SQL'
CREATE TABLE users(id SERIAL PRIMARY KEY, email TEXT);
INSERT INTO users(email) VALUES('test@livraone.com');
SQL

# Dump schema+data
docker exec "$src" pg_dump -U postgres -d srcdb > "$work/dump.sql"

# Create destination postgres
docker run -d --name "$dst" \
  -e POSTGRES_PASSWORD="$pw" \
  -e POSTGRES_DB="dstdb" \
  postgres:16-alpine >/dev/null

for i in $(seq 1 30); do
  docker exec "$dst" pg_isready -U postgres >/dev/null 2>&1 && break
  sleep 1
done

# Restore
docker exec -i "$dst" psql -U postgres -d dstdb < "$work/dump.sql"

# Verify restore worked
cnt="$(docker exec "$dst" psql -U postgres -d dstdb -tAc "select count(*) from users;")"
[[ "$cnt" == "1" ]] || die "restore integrity check failed"

echo "PASS"
