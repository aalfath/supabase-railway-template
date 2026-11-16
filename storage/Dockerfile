# Supabase Storage: file storage API with policies and image transformations (Supabase /storage/v1).
FROM supabase/storage-api:v1.89.12@sha256:8526956cb462e9f7d392e9848ec77133b2769982ed614e9753cc687e8e4339a6

COPY --chmod=755 supabase-keys.sh /usr/local/bin/supabase-keys.sh
COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

ENV SERVER_HOST="::" \
    SERVER_PORT=5000 \
    REQUEST_ALLOW_X_FORWARDED_PATH=true \
    FILE_SIZE_LIMIT=52428800 \
    STORAGE_BACKEND=file \
    FILE_STORAGE_BACKEND_PATH=/var/lib/storage \
    GLOBAL_S3_BUCKET=stub \
    TENANT_ID=stub \
    REGION=stub \
    ENABLE_IMAGE_TRANSFORMATION=true

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["node", "dist/start/server.js"]
