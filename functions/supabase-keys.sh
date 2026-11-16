#!/bin/sh
# Derives Supabase's API keys (HS256-signed JWTs for the "anon" and "service_role"
# roles) from JWT_SECRET. The claims are fixed, so every service that runs this
# gets exactly the same keys from the same secret: no key has to be copied by hand.
# Keys you set yourself (ANON_KEY / SERVICE_ROLE_KEY) are kept as they are.
# Source this file; it exports ANON_KEY and SERVICE_ROLE_KEY.

SUPABASE_KEY_IAT=1763251200   # 2025-11-16T00:00:00Z
SUPABASE_KEY_EXP=2078611200   # 2035-11-14T00:00:00Z

if [ -z "${JWT_SECRET:-}" ]; then
  echo "supabase-keys: JWT_SECRET is not set" >&2
  exit 1
fi

_sb_b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }

_sb_jwt() {
  _h='{"alg":"HS256","typ":"JWT"}'
  _p="{\"role\":\"$1\",\"iss\":\"supabase\",\"iat\":${SUPABASE_KEY_IAT},\"exp\":${SUPABASE_KEY_EXP}}"
  if command -v openssl >/dev/null 2>&1; then
    _hp="$(printf '%s' "$_h" | _sb_b64url).$(printf '%s' "$_p" | _sb_b64url)"
    _sig="$(printf '%s' "$_hp" | openssl dgst -sha256 -hmac "$JWT_SECRET" -binary | _sb_b64url)"
    printf '%s.%s' "$_hp" "$_sig"
  else
    SB_H="$_h" SB_P="$_p" node -e '
      const c = require("crypto");
      const u = (s) => Buffer.from(s).toString("base64url");
      const hp = u(process.env.SB_H) + "." + u(process.env.SB_P);
      const sig = c.createHmac("sha256", process.env.JWT_SECRET).update(hp).digest("base64url");
      process.stdout.write(hp + "." + sig);'
  fi
}

[ -n "${ANON_KEY:-}" ] || ANON_KEY="$(_sb_jwt anon)"
[ -n "${SERVICE_ROLE_KEY:-}" ] || SERVICE_ROLE_KEY="$(_sb_jwt service_role)"
export ANON_KEY SERVICE_ROLE_KEY
