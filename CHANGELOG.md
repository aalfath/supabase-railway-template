# Changelog

## 2026-11-16: Deploy on Railway button

- README: Deploy on Railway button for the published template (`supabase-2`) and a note on enabling `pg_graphql`. No change to any service.

## 2026-11-16: first release

Supabase self-hosting kit of 2026-11-16 (`supabase/supabase` commit `000320e`):

- Studio `2026.11.02-sha-a05e7ec`, Auth `v2.197.0`, PostgREST `v14.18`, Realtime `v2.148.3`, Storage `v1.89.12`, imgproxy `v4.0.21`, postgres-meta `v0.100.0`, Edge Runtime `v1.77.9`, Envoy `v1.39.6`, Postgres `17.6.1.136`.
- Every service builds from this repo; files go to a Railway Bucket; API keys are derived from `JWT_SECRET`.
