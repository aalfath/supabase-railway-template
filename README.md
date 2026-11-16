# Supabase on Railway

Self-hosted [Supabase](https://supabase.com) (Postgres, Auth, REST, Realtime, Storage, Edge Functions and the Studio dashboard) as a Railway template. Every service builds from this repository, so when this repo's `main` branch moves to a newer Supabase release, Railway offers the update to everyone who deployed the template.

Based on Supabase's official self-hosting kit ([`supabase/supabase/docker`](https://github.com/supabase/supabase/tree/master/docker), November 2026), with the official images pinned by version and digest.

## What it deploys

| Railway service | Folder | Image (pinned by digest) | Role |
|---|---|---|---|
| `Supabase` | `gateway/` | `envoyproxy/envoy:v1.39.6` | Public entry point. Routes `/auth/v1`, `/rest/v1`, `/realtime/v1`, `/storage/v1`, `/functions/v1`, `/graphql/v1` and `/pg`, checks API keys, and puts Studio behind a login |
| `Studio` | `studio/` | `supabase/studio:2026.11.02-sha-a05e7ec` | Dashboard (saved SQL snippets on a volume) |
| `Auth` | `auth/` | `supabase/gotrue:v2.197.0` | Users, sign-in, JWTs |
| `REST` | `rest/` | `postgrest/postgrest:v14.18` | REST and GraphQL API over the database |
| `Realtime` | `realtime/` | `supabase/realtime:v2.148.3` | Database changes, broadcast and presence over WebSockets |
| `Storage` | `storage/` | `supabase/storage-api:v1.89.12` | File API; files are kept in a Railway Bucket |
| `imgproxy` | `imgproxy/` | `darthsim/imgproxy:v4.0.21` | Image resizing for Storage |
| `Meta` | `meta/` | `supabase/postgres-meta:v0.100.0` | Database management API for Studio |
| `Functions` | `functions/` | `supabase/edge-runtime:v1.77.9` | Deno Edge Functions from `functions/functions/` |
| `Postgres` | `db/` | `supabase/postgres:17.6.1.136` | Supabase's Postgres 17 with its extensions and init scripts (volume, TCP proxy) |
| `Bucket` | (Railway Bucket) | | S3-compatible object storage for Storage |

Not included: Supavisor (connection pooler) and the Logflare/Vector log stack (Studio's log pages stay off, as in Supabase's default kit).

## Variables

Nothing has to be filled in to deploy. The template generates every secret:

| Service | Variable | Value |
|---|---|---|
| `Supabase` | `JWT_SECRET` | Generated. Signs every token. The API keys are derived from it (below) |
| `Supabase` | `DASHBOARD_USERNAME` / `DASHBOARD_PASSWORD` | `supabase` / generated. Login for Studio |
| `Supabase` | `SUPABASE_PUBLIC_URL` | `https://` + the service's Railway domain |
| `Postgres` | `POSTGRES_PASSWORD` | Generated. Password of the `postgres` and `supabase_admin` users and the internal service roles |
| `Postgres` | `DATABASE_URL` | Connection string through Railway's TCP proxy, for tools outside Railway |
| `Auth` | `SITE_URL` | Your app's URL (redirect target of auth e-mails). Defaults to the Supabase URL |
| `Realtime` | `SECRET_KEY_BASE`, `DB_ENC_KEY` | Generated |
| `Storage` | `S3_PROTOCOL_ACCESS_KEY_ID` / `_SECRET` | Generated keys for Storage's S3-compatible endpoint |
| `Studio` | `PG_META_CRYPTO_KEY` | Generated |

The other variables are references between services (private hostnames, the shared secrets above) and the ports.

**API keys.** `ANON_KEY` and `SERVICE_ROLE_KEY` are JWTs signed with `JWT_SECRET`. Each service that needs them derives them at start with `supabase-keys.sh` (fixed claims, so every service gets the same keys). Find them in Studio under **Project Settings > API Keys**. Changing `JWT_SECRET` changes both keys and signs out every user.

**Optional settings** (add them as variables on the service named):

- `Auth`: `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_ADMIN_EMAIL`, `SMTP_SENDER_NAME` to send auth e-mails. Without SMTP, new e-mail sign-ups are confirmed automatically; with SMTP, users must confirm their address (override with `ENABLE_EMAIL_AUTOCONFIRM`). `DISABLE_SIGNUP=true` closes sign-up, `ADDITIONAL_REDIRECT_URLS` adds redirect URLs, and any `GOTRUE_*` setting (OAuth providers, MFA, SAML) is passed through as is.
- `Studio`: `OPENAI_API_KEY` for the SQL assistant.
- `Functions`: `FUNCTIONS_VERIFY_JWT=true` to require a valid JWT on every function call.
- `Storage`: `UPLOAD_FILE_SIZE_LIMIT` in bytes (default 50 MB).

## Edge Functions

Functions are files in `functions/functions/<name>/index.ts`; `main` is the router and `hello` is an example (`/functions/v1/hello`). To add your own, fork this repo, add a folder, and point the `Functions` service at your fork. Studio can't edit functions in a self-hosted setup.

## Updates

This repo pins each image by version and digest. A new Supabase release lands here as a commit on `main` with a `CHANGELOG.md` entry, and Railway shows deployers an "update available" notice. Read the changelog before applying an update: Postgres major upgrades are never applied automatically.

## Local test

`docker compose up -d --build`, then open `http://localhost:8000` (user `supabase`, password from `docker-compose.yml`). Edge Functions download their Deno dependencies from jsr.io at start, so they need internet access.

## Changes to Supabase's files

- `gateway/`: Envoy listens on IPv4 and IPv6 (Railway's private network), gets a `/health` route that needs no login, reads the upstream hostnames from variables, and derives the API keys from `JWT_SECRET`.
- `db/`: the database lives in `pgdata/` on the volume, and the pgsodium/Vault root key is kept on the same volume, so Vault secrets survive redeploys.
- Each other folder: a start script that maps the template's variables to the service's own, binds to `::`, and waits for the database on first boot.

Supabase is licensed under Apache-2.0; the files copied from `supabase/supabase` keep that license.
