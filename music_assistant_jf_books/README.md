# Music Assistant (Jellyfin books)

The official Music Assistant server with one change: its Jellyfin provider also
handles audiobooks. Books in a Jellyfin `books` library appear in Music Assistant
and share one resume point with other Jellyfin clients.

**Experimental and personal.** The patch lives on branch `jellyfin-audiobooks` of
[MSMGreen/music-assistant-server](https://github.com/MSMGreen/music-assistant-server).
Upstream request: [support#4281](https://github.com/orgs/music-assistant/discussions/4281).
Music Assistant is Apache-2.0; `jellyfin/` is a modified copy of its provider.

Only one Music Assistant add-on can run at a time, because both use port 8095.

## Taking over an existing Music Assistant

This add-on has its own `/data`. To start from another Music Assistant's data, keep
its logins, playlists and players, stop that add-on, take a partial HA backup of it,
and set this add-on's `seed_backup` option to the backup's slug before first start.
If `/data` has no `settings.json`, it takes the data from that backup. If anything is
wrong with the backup, the add-on stops and logs why, rather than starting empty.
Clear the option afterwards.

## Moving to a new Music Assistant version

1. Rebase the fork's branch onto the new tag and run its tests.
2. `./vendor.sh <commit>` from the repo root.
3. Update the version in `build.yaml`, and `version` in `config.yaml`
   (`<version>-jfbooks.<n>`). Check the Python version in the `Dockerfile` path.
4. Compare `config.yaml` with the official add-on's for that version.
5. Push, then update the add-on in Home Assistant.

## Going back

Stop this add-on, start the official one. It kept its own data, as it was at
cut-over. If the patch is merged upstream, go back to the official add-on for good.
