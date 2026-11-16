#!/bin/sh
# Builds Storage's settings from the template's variables, then starts Supabase Storage.
# With a Railway Bucket (S3_BUCKET + S3_ENDPOINT set) files go to the bucket; otherwise
# they go to the local folder FILE_STORAGE_BACKEND_PATH.
set -eu
. /usr/local/bin/supabase-keys.sh

: "${POSTGRES_HOST:?POSTGRES_HOST is required}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"

export ANON_KEY
export SERVICE_KEY="${SERVICE_KEY:-$SERVICE_ROLE_KEY}"
export AUTH_JWT_SECRET="${AUTH_JWT_SECRET:-$JWT_SECRET}"
export DATABASE_URL="${DATABASE_URL:-postgres://supabase_storage_admin:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}}"
[ -z "${REST_HOST:-}" ] || export POSTGREST_URL="${POSTGREST_URL:-http://${REST_HOST}:3000}"
[ -z "${IMGPROXY_HOST:-}" ] || export IMGPROXY_URL="${IMGPROXY_URL:-http://${IMGPROXY_HOST}:5001}"
[ -z "${UPLOAD_FILE_SIZE_LIMIT:-}" ] || export FILE_SIZE_LIMIT="$UPLOAD_FILE_SIZE_LIMIT"

if [ -n "${S3_BUCKET:-}" ] && [ -n "${S3_ENDPOINT:-}" ]; then
  export STORAGE_BACKEND=s3
  export GLOBAL_S3_BUCKET="$S3_BUCKET"
  export GLOBAL_S3_ENDPOINT="$S3_ENDPOINT"
  export GLOBAL_S3_FORCE_PATH_STYLE="${GLOBAL_S3_FORCE_PATH_STYLE:-true}"
  export AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID:-}"
  export AWS_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY:-}"
  export AWS_DEFAULT_REGION="${S3_REGION:-auto}"
  export REGION="${S3_REGION:-auto}"
fi

i=0
until node -e 'const s=require("net").connect(+process.argv[2],process.argv[1]);s.on("connect",()=>process.exit(0));s.on("error",()=>process.exit(1));setTimeout(()=>process.exit(1),2000)' "$POSTGRES_HOST" "$POSTGRES_PORT"; do
  i=$((i + 1))
  [ "$i" -lt 90 ] || { echo "database not reachable at $POSTGRES_HOST:$POSTGRES_PORT" >&2; exit 1; }
  echo "waiting for the database at $POSTGRES_HOST:$POSTGRES_PORT ..."
  sleep 2
done

exec docker-entrypoint.sh "$@"
