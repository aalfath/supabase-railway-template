# Supabase Postgres with the init scripts of Supabase's self-hosting kit (supabase/supabase, docker/volumes/db).
FROM supabase/postgres:17.6.1.136@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00

COPY realtime.sql /docker-entrypoint-initdb.d/migrations/99-realtime.sql
COPY webhooks.sql /docker-entrypoint-initdb.d/init-scripts/98-webhooks.sql
COPY roles.sql /docker-entrypoint-initdb.d/init-scripts/99-roles.sql
COPY jwt.sql /docker-entrypoint-initdb.d/init-scripts/99-jwt.sql
COPY _supabase.sql /docker-entrypoint-initdb.d/migrations/97-_supabase.sql
COPY logs.sql /docker-entrypoint-initdb.d/migrations/99-logs.sql
COPY pooler.sql /docker-entrypoint-initdb.d/migrations/99-pooler.sql
COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

ENV POSTGRES_DB=postgres \
    POSTGRES_PORT=5432 \
    PGPORT=5432 \
    JWT_EXP=3600 \
    PGDATA=/var/lib/postgresql/data/pgdata

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "log_min_messages=fatal"]
