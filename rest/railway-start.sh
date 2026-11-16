#!/bin/sh
# Runs PostgREST under a small watchdog. After a database restart PostgREST can stay
# stuck on "Could not query the database for the schema cache" until it is restarted.
# Once PostgREST has been ready, if its admin /ready check then fails for
# PGRST_WATCHDOG_SECONDS (default 60) in a row, PostgREST is restarted in place.
set -u

# Fail fast on connection attempts to a database container that is gone.
case "${PGRST_DB_URI:-}" in
  *connect_timeout=*) ;;
  *\?*) export PGRST_DB_URI="${PGRST_DB_URI}&connect_timeout=10" ;;
  ?*) export PGRST_DB_URI="${PGRST_DB_URI}?connect_timeout=10" ;;
esac

LIMIT="${PGRST_WATCHDOG_SECONDS:-60}"
READY_URL="http://localhost:${PGRST_ADMIN_SERVER_PORT:-3001}/ready"
child=0
trap 'kill -TERM "$child" 2>/dev/null; wait "$child"; exit 0' TERM INT

while :; do
  "$@" &
  child=$!
  ready=0; bad=0
  while kill -0 "$child" 2>/dev/null; do
    sleep 5
    if wget -q -T 4 -O /dev/null "$READY_URL" 2>/dev/null; then
      ready=1; bad=0
    elif [ "$ready" = 1 ]; then
      bad=$((bad + 5))
      if [ "$bad" -ge "$LIMIT" ]; then
        echo "watchdog: PostgREST not ready for ${bad}s, restarting it"
        kill -TERM "$child" 2>/dev/null; wait "$child"
        continue 2
      fi
    fi
  done
  wait "$child"; code=$?
  echo "watchdog: PostgREST exited with code $code"
  exit "$code"
done
