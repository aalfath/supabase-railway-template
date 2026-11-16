#!/bin/sh
# Builds Auth's settings from the template's variables, then starts Supabase Auth.
set -eu

: "${POSTGRES_HOST:?POSTGRES_HOST is required}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"
: "${JWT_SECRET:?JWT_SECRET is required}"
: "${API_EXTERNAL_URL:?API_EXTERNAL_URL is required}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"

export GOTRUE_DB_DATABASE_URL="${GOTRUE_DB_DATABASE_URL:-postgres://supabase_auth_admin:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}}"
export GOTRUE_JWT_SECRET="${GOTRUE_JWT_SECRET:-$JWT_SECRET}"
export GOTRUE_JWT_ISSUER="${GOTRUE_JWT_ISSUER:-$API_EXTERNAL_URL}"
export GOTRUE_SITE_URL="${GOTRUE_SITE_URL:-${SITE_URL:-$API_EXTERNAL_URL}}"
[ -z "${ADDITIONAL_REDIRECT_URLS:-}" ] || export GOTRUE_URI_ALLOW_LIST="${GOTRUE_URI_ALLOW_LIST:-$ADDITIONAL_REDIRECT_URLS}"
[ -z "${DISABLE_SIGNUP:-}" ] || export GOTRUE_DISABLE_SIGNUP="$DISABLE_SIGNUP"

# E-mail. Without SMTP, confirmation e-mails can't be sent, so new e-mail sign-ups are
# confirmed automatically unless ENABLE_EMAIL_AUTOCONFIRM says otherwise.
if [ -n "${SMTP_HOST:-}" ]; then
  export GOTRUE_SMTP_HOST="$SMTP_HOST"
  export GOTRUE_SMTP_PORT="${SMTP_PORT:-587}"
  export GOTRUE_SMTP_USER="${SMTP_USER:-}"
  export GOTRUE_SMTP_PASS="${SMTP_PASS:-}"
  export GOTRUE_SMTP_ADMIN_EMAIL="${SMTP_ADMIN_EMAIL:-}"
  export GOTRUE_SMTP_SENDER_NAME="${SMTP_SENDER_NAME:-Supabase}"
  export GOTRUE_MAILER_AUTOCONFIRM="${ENABLE_EMAIL_AUTOCONFIRM:-false}"
else
  export GOTRUE_MAILER_AUTOCONFIRM="${ENABLE_EMAIL_AUTOCONFIRM:-true}"
fi

# Wait for the database (Railway starts all services at once; the first boot of
# Postgres runs Supabase's init scripts before it accepts TCP connections).
i=0
until nc -z -w 2 "$POSTGRES_HOST" "$POSTGRES_PORT" 2>/dev/null; do
  i=$((i + 1))
  [ "$i" -lt 90 ] || { echo "database not reachable at $POSTGRES_HOST:$POSTGRES_PORT" >&2; exit 1; }
  echo "waiting for the database at $POSTGRES_HOST:$POSTGRES_PORT ..."
  sleep 2
done

exec "$@"
