# Supabase Studio: the dashboard (served behind the gateway's login).
FROM supabase/studio:2026.11.02-sha-a05e7ec@sha256:727a7f37b15f4c76c44e0d765e6be231d8d71c67f2933b2df8c6cbcc9b04c5d0

COPY --chmod=755 supabase-keys.sh /usr/local/bin/supabase-keys.sh
COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

ENV HOSTNAME="::" \
    PORT=3000 \
    POSTGRES_PORT=5432 \
    POSTGRES_DB=postgres \
    POSTGRES_USER_READ_WRITE=postgres \
    PGRST_DB_SCHEMAS=public,graphql_public \
    PGRST_DB_MAX_ROWS=1000 \
    PGRST_DB_EXTRA_SEARCH_PATH=public \
    DEFAULT_ORGANIZATION_NAME="Default Organization" \
    DEFAULT_PROJECT_NAME="Default Project" \
    ENABLED_FEATURES_LOGS_ALL=false \
    NEXT_PUBLIC_ENABLE_LOGS=false \
    SNIPPETS_MANAGEMENT_FOLDER=/app/data/snippets \
    EDGE_FUNCTIONS_MANAGEMENT_FOLDER=/app/data/edge-functions

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["node", "apps/studio/server.js"]
