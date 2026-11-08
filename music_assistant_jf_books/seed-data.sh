#!/bin/sh
# Take over another Music Assistant's data if asked to, then start the server as usual.
set -e
/app/venv/bin/python /addon-seed/seed_data.py
exec /usr/local/bin/entrypoint.sh --data-dir /data --cache-dir /data/.cache "$@"
