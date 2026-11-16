#!/bin/bash
# Maps the template's variables to Realtime's, waits for the database, then runs
# Realtime's own start script (migrations, self-host tenant seed, server).
set -euo pipefail

: "${JWT_SECRET:?JWT_SECRET is required}"
: "${DB_HOST:?DB_HOST is required}"
export API_JWT_SECRET="${API_JWT_SECRET:-$JWT_SECRET}"
export METRICS_JWT_SECRET="${METRICS_JWT_SECRET:-$JWT_SECRET}"
export PORT=4000

for i in $(seq 1 90); do
  if (exec 3<>"/dev/tcp/${DB_HOST}/${DB_PORT}") 2>/dev/null; then break; fi
  [ "$i" -lt 90 ] || { echo "database not reachable at ${DB_HOST}:${DB_PORT}" >&2; exit 1; }
  echo "waiting for the database at ${DB_HOST}:${DB_PORT} ..."
  sleep 2
done

exec /app/run.sh "$@"
