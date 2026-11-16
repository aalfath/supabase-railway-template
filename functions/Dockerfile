# Supabase Edge Runtime: runs the Deno edge functions in ./functions (Supabase /functions/v1).
FROM supabase/edge-runtime:v1.77.9@sha256:6b850a2ccf0bf50ecac9accff8098095cd191c389c2a53c59b857aa0f53a8343

COPY --chmod=755 supabase-keys.sh /usr/local/bin/supabase-keys.sh
COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh
COPY functions /home/deno/functions

ENV VERIFY_JWT=false

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["start", "--ip", "::", "--port", "9000", "--user-worker-request-idle-timeout", "150000", "--main-service", "/home/deno/functions/main"]
