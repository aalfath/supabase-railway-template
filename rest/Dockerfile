# PostgREST: the REST API over the database (Supabase /rest/v1).
# The official image has no shell, so its static binary is copied onto Alpine to run
# under a small supervisor (railway-start.sh) that restarts PostgREST in place if it
# loses the database for good (seen after a Postgres redeploy on Railway).
FROM postgrest/postgrest:v14.18@sha256:c7cd7e265a85b05248abf53f4473fcec7e327c282d0bd0cf60f1551996d09fcf AS postgrest

FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

COPY --from=postgrest /bin/postgrest /bin/postgrest
COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

ENV PGRST_SERVER_HOST="*6" \
    PGRST_SERVER_PORT=3000 \
    PGRST_DB_SCHEMAS=public,graphql_public \
    PGRST_DB_MAX_ROWS=1000 \
    PGRST_DB_EXTRA_SEARCH_PATH=public \
    PGRST_DB_ANON_ROLE=anon \
    PGRST_ADMIN_SERVER_PORT=3001 \
    PGRST_ADMIN_SERVER_HOST=localhost \
    PGRST_DB_USE_LEGACY_GUCS=false \
    PGRST_APP_SETTINGS_JWT_EXP=3600

USER 1000
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["postgrest"]
