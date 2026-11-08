#!/bin/sh
# First boot only: take over the data of another Music Assistant, if one was left in
# /media/ma-seed. Any problem stops the add-on, because starting without the seed would
# write a new settings.json and the seed would never be used.
set -e
seed=/media/ma-seed
work=/data/.seed-in-progress
if [ ! -e /data/settings.json ] && [ -d "$seed" ]; then
    if [ ! -e "$seed/settings.json" ]; then
        echo "[seed-data] ERROR: $seed has no settings.json. Is the data one level too deep?" >&2
        exit 1
    fi
    echo "[seed-data] Taking over the data in $seed"
    rm -rf "$work"
    cp -a "$seed/." "$work/"
    # settings.json goes last: it is what marks the takeover as complete
    for item in "$work"/* "$work"/.[!.]*; do
        [ -e "$item" ] || continue
        [ "$(basename "$item")" = settings.json ] && continue
        rm -rf "/data/$(basename "$item")"
        mv "$item" /data/
    done
    mv "$work/settings.json" /data/settings.json
    rmdir "$work"
    echo "[seed-data] Done. Delete $seed: it contains logins and tokens"
fi
exec /usr/local/bin/entrypoint.sh --data-dir /data --cache-dir /data/.cache "$@"
