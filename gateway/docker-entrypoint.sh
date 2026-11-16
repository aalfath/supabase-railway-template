#!/bin/sh
# Based on Supabase's docker/volumes/api/envoy/docker-entrypoint.sh, adapted for Railway:
# the API keys are derived from JWT_SECRET, and the upstream hosts come from variables.
set -e
. /usr/local/bin/supabase-keys.sh

: "${DASHBOARD_USERNAME:?DASHBOARD_USERNAME is required}"
: "${DASHBOARD_PASSWORD:?DASHBOARD_PASSWORD is required}"
: "${SUPABASE_PUBLIC_URL:?SUPABASE_PUBLIC_URL is required}"

# Generate SHA1 base64 hash for Envoy basic auth user list
PASSWORD_HASH=$(printf '%s' "${DASHBOARD_PASSWORD}" | openssl sha1 -binary | openssl base64)
DASHBOARD_BASIC_AUTH="${DASHBOARD_USERNAME}:{SHA}${PASSWORD_HASH}"

echo "Generating Envoy configuration..."

# Using | as delimiter since JWT tokens contain /
sed -e "s|\${ANON_KEY}|${ANON_KEY}|g" \
    -e "s|\${ANON_KEY_ASYMMETRIC}|${ANON_KEY_ASYMMETRIC:-}|g" \
    -e "s|\${SERVICE_ROLE_KEY}|${SERVICE_ROLE_KEY}|g" \
    -e "s|\${SERVICE_ROLE_KEY_ASYMMETRIC}|${SERVICE_ROLE_KEY_ASYMMETRIC:-}|g" \
    -e "s|\${SUPABASE_PUBLISHABLE_KEY}|${SUPABASE_PUBLISHABLE_KEY:-}|g" \
    -e "s|\${SUPABASE_SECRET_KEY}|${SUPABASE_SECRET_KEY:-}|g" \
    -e "s|\${SUPABASE_PUBLIC_URL}|${SUPABASE_PUBLIC_URL}|g" \
    -e "s|\${DASHBOARD_BASIC_AUTH}|${DASHBOARD_BASIC_AUTH}|g" \
    /etc/envoy/lds.template.yaml > /etc/envoy/lds.yaml

sed -e "s|\${AUTH_HOST}|${AUTH_HOST:-auth}|g" \
    -e "s|\${REST_HOST}|${REST_HOST:-rest}|g" \
    -e "s|\${REALTIME_HOST}|${REALTIME_HOST:-realtime}|g" \
    -e "s|\${STORAGE_HOST}|${STORAGE_HOST:-storage}|g" \
    -e "s|\${FUNCTIONS_HOST}|${FUNCTIONS_HOST:-functions}|g" \
    -e "s|\${META_HOST}|${META_HOST:-meta}|g" \
    -e "s|\${STUDIO_HOST}|${STUDIO_HOST:-studio}|g" \
    /etc/envoy/cds.template.yaml > /etc/envoy/cds.yaml

echo "Envoy running in legacy API key mode"
echo "Project URL: ${SUPABASE_PUBLIC_URL}"
echo "Your API keys are in Studio: Project Settings > API Keys (log in as ${DASHBOARD_USERNAME})."
echo "Starting Envoy..."

exec envoy -c /etc/envoy/envoy.yaml "$@"
