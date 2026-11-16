#!/bin/sh
# Builds the Edge Runtime's settings from the template's variables, then starts it.
set -eu
. /usr/local/bin/supabase-keys.sh

export SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-$ANON_KEY}"
export SUPABASE_SERVICE_ROLE_KEY="${SUPABASE_SERVICE_ROLE_KEY:-$SERVICE_ROLE_KEY}"
[ -z "${GATEWAY_HOST:-}" ] || export SUPABASE_URL="${SUPABASE_URL:-http://${GATEWAY_HOST}:8000}"
if [ -n "${POSTGRES_HOST:-}" ] && [ -n "${POSTGRES_PASSWORD:-}" ]; then
  export SUPABASE_DB_URL="${SUPABASE_DB_URL:-postgresql://postgres:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT:-5432}/${POSTGRES_DB:-postgres}}"
fi
[ -z "${FUNCTIONS_VERIFY_JWT:-}" ] || export VERIFY_JWT="$FUNCTIONS_VERIFY_JWT"

exec edge-runtime "$@"
