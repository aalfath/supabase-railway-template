# PostgREST: the REST API over the database (Supabase /rest/v1).
FROM postgrest/postgrest:v14.18@sha256:c7cd7e265a85b05248abf53f4473fcec7e327c282d0bd0cf60f1551996d09fcf

ENV PGRST_SERVER_HOST="*" \
    PGRST_SERVER_PORT=3000 \
    PGRST_DB_SCHEMAS=public,graphql_public \
    PGRST_DB_MAX_ROWS=1000 \
    PGRST_DB_EXTRA_SEARCH_PATH=public \
    PGRST_DB_ANON_ROLE=anon \
    PGRST_ADMIN_SERVER_PORT=3001 \
    PGRST_ADMIN_SERVER_HOST=localhost \
    PGRST_DB_USE_LEGACY_GUCS=false \
    PGRST_APP_SETTINGS_JWT_EXP=3600

CMD ["postgrest"]
