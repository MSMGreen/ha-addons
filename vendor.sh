#!/bin/sh
# Copy the patched Jellyfin provider from the fork, at a named commit, into the add-on.
# Usage: ./vendor.sh <commit> [path-to-fork]
set -eu
commit="$1"
fork="${2:-../music-assistant-server}"
dest="music_assistant_jf_books"
rm -rf "$dest/jellyfin"
git -C "$fork" archive "$commit" music_assistant/providers/jellyfin | tar -x --strip-components=2 -C "$dest"
git -C "$fork" rev-parse "$commit" > "$dest/jellyfin/VENDORED_FROM"
echo "vendored $(cat "$dest/jellyfin/VENDORED_FROM")"
