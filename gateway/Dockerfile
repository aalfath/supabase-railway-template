# API gateway (Envoy, Supabase's default gateway): the public entry point. It routes
# /auth/v1, /rest/v1, /realtime/v1, /storage/v1, /functions/v1 and /pg, checks API keys,
# and puts Studio behind a login (DASHBOARD_USERNAME / DASHBOARD_PASSWORD).
# Config files: Supabase's docker/volumes/api/envoy, with the changes noted in README.md.
FROM envoyproxy/envoy:v1.39.6@sha256:1fde8efee875e4e4f6a39a90fe49d9338e1caacce5762034ef9fb4bbb9ad6aed

COPY envoy.yaml /etc/envoy/envoy.yaml
COPY cds.template.yaml /etc/envoy/cds.template.yaml
COPY lds.template.yaml /etc/envoy/lds.template.yaml
COPY --chmod=755 supabase-keys.sh /usr/local/bin/supabase-keys.sh
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh

ENV DASHBOARD_USERNAME=supabase

EXPOSE 8000
ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]
