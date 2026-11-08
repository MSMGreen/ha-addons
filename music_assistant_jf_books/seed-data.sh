#!/bin/sh
# First boot only: take over the data of another Music Assistant, if one was left in
# /media/ma-seed. A failed copy stops the add-on, because starting with empty data
# would write a new settings.json and the seed would never be used.
set -e
if [ ! -e /data/settings.json ] && [ -e /media/ma-seed/settings.json ]; then
    echo "[seed-data] Taking over the data in /media/ma-seed"
    cp -a /media/ma-seed/. /data/
    echo "[seed-data] Done. Delete /media/ma-seed: it contains logins and tokens"
fi
exec /usr/local/bin/entrypoint.sh --data-dir /data --cache-dir /data/.cache "$@"
