"""
First boot only: take over the data of another Music Assistant add-on from an HA backup.

Set the add-on option `seed_backup` to the slug of a backup of that add-on. Any problem
stops the add-on: starting without the data would write a new settings.json, and the
takeover would then never happen.
"""

import json
import shutil
import sys
import tarfile
from pathlib import Path

DATA = Path("/data")
WORK = DATA / ".seed-in-progress"
BACKUPS = Path("/backup")
ADDON_MARKER = "music_assistant"


def fail(message: str) -> None:
    print(f"[seed-data] ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def option() -> str:
    try:
        return str(json.loads((DATA / "options.json").read_text()).get("seed_backup") or "")
    except FileNotFoundError:
        return ""


def extract(backup: Path) -> None:
    with tarfile.open(backup) as outer:
        found = [
            m
            for m in outer.getmembers()
            if ADDON_MARKER in m.name and m.name.endswith((".tar", ".tar.gz"))
        ]
        if len(found) != 1:
            fail(f"{backup.name} does not hold one Music Assistant add-on: {found}")
        with tarfile.open(fileobj=outer.extractfile(found[0]), mode="r:*") as inner:
            for member in inner.getmembers():
                name = member.name.removeprefix("./")
                if not name.startswith("data/") or name == "data/":
                    continue
                member.name = name.removeprefix("data/")
                inner.extract(member, WORK, filter="data")


def main() -> None:
    slug = option()
    if (DATA / "settings.json").exists():
        if slug:
            print("[seed-data] Data already present. The seed_backup option can be cleared")
        return
    if not slug:
        return
    backup = BACKUPS / f"{slug}.tar"
    if not backup.exists():
        fail(f"seed_backup is set to {slug}, but there is no {backup}")
    print(f"[seed-data] Taking over the data in backup {slug}")
    shutil.rmtree(WORK, ignore_errors=True)
    WORK.mkdir()
    try:
        extract(backup)
    except (tarfile.TarError, OSError, EOFError) as err:
        fail(f"could not read {backup}: {err}")
    if not (WORK / "settings.json").exists():
        fail(f"{backup.name} has no settings.json in its data")
    # settings.json goes last: it is what marks the takeover as complete
    for item in WORK.iterdir():
        if item.name in ("settings.json", "options.json"):
            continue
        target = DATA / item.name
        if target.is_dir():
            shutil.rmtree(target)
        shutil.move(item, target)
    (WORK / "settings.json").replace(DATA / "settings.json")
    shutil.rmtree(WORK)
    print("[seed-data] Done. The seed_backup option can be cleared")


if __name__ == "__main__":
    main()
