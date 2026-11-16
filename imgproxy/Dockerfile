# imgproxy: resizes and converts images for Supabase Storage's transformation API.
FROM darthsim/imgproxy:v4.0.21@sha256:69ae09dbc3349944564cb2f66cf35f80a4a9a78fda73d06061a337849520ab1f

ENV IMGPROXY_BIND=":5001" \
    IMGPROXY_LOCAL_FILESYSTEM_ROOT=/ \
    IMGPROXY_USE_ETAG=true \
    IMGPROXY_AUTO_WEBP=true \
    IMGPROXY_MAX_SRC_RESOLUTION=16.8
