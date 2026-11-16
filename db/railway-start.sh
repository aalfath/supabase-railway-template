#!/bin/sh
# Railway gives a service one volume. It is mounted at /var/lib/postgresql/data, so:
#  - the database lives in a subfolder (PGDATA), because the volume root holds lost+found;
#  - the pgsodium/Vault root key, which Supabase keeps in /etc/postgresql-custom, is kept
#    on the same volume, so encrypted Vault secrets survive redeploys.
set -eu
VOL=/var/lib/postgresql/data
mkdir -p "$VOL/postgresql-custom"
chown postgres:postgres "$VOL" "$VOL/postgresql-custom" 2>/dev/null || true
ln -sf "$VOL/postgresql-custom/pgsodium_root.key" /etc/postgresql-custom/pgsodium_root.key

# Variables the init scripts read.
export POSTGRES_HOST=/var/run/postgresql
export PGPASSWORD="${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"
export PGDATABASE="${POSTGRES_DB}"

if [ "${1:-}" = "postgres" ]; then
  shift
  set -- postgres -c "data_directory=${PGDATA}" "$@"
fi
exec docker-entrypoint.sh "$@"
