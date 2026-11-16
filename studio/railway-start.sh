#!/bin/sh
# Builds Studio's settings from the template's variables, then starts Supabase Studio.
set -eu
. /usr/local/bin/supabase-keys.sh

: "${SUPABASE_PUBLIC_URL:?SUPABASE_PUBLIC_URL is required}"
export PORT=3000
export SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-$ANON_KEY}"
export SUPABASE_SERVICE_KEY="${SUPABASE_SERVICE_KEY:-$SERVICE_ROLE_KEY}"
export AUTH_JWT_SECRET="${AUTH_JWT_SECRET:-$JWT_SECRET}"
[ -z "${GATEWAY_HOST:-}" ] || export SUPABASE_URL="${SUPABASE_URL:-http://${GATEWAY_HOST}:8000}"
[ -z "${META_HOST:-}" ] || export STUDIO_PG_META_URL="${STUDIO_PG_META_URL:-http://${META_HOST}:8080}"

# Saved SQL snippets live on the volume mounted at /app/data.
mkdir -p "$SNIPPETS_MANAGEMENT_FOLDER" "$EDGE_FUNCTIONS_MANAGEMENT_FOLDER"

exec docker-entrypoint.sh "$@"
