# Supabase Realtime: database changes, broadcast and presence over WebSockets (Supabase /realtime/v1).
FROM supabase/realtime:v2.148.3@sha256:25cf375b9b7cb71d90cdf6e04a1a30996e39a8df866ebd0525bba1d959edc8d6

COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

ENV PORT=4000 \
    DB_PORT=5432 \
    DB_USER=supabase_admin \
    DB_NAME=postgres \
    DB_AFTER_CONNECT_QUERY="SET search_path TO _realtime" \
    ERL_AFLAGS="-proto_dist inet_tcp" \
    DNS_NODES="''" \
    RLIMIT_NOFILE=10000 \
    APP_NAME=realtime \
    SEED_SELF_HOST=true \
    RUN_JANITOR=true \
    DISABLE_HEALTHCHECK_LOGGING=true

ENTRYPOINT ["/usr/bin/tini", "-s", "-g", "--", "/usr/local/bin/railway-start.sh"]
CMD ["/app/bin/server"]
