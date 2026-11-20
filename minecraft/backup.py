#!/usr/bin/env python3
# Snapshots the Minecraft world on every run (minecraft-backup.timer, every 10 minutes). Unchanged files are
# hard links to the previous snapshot, so each one only costs the region files the game rewrote.
import shutil
import subprocess
import time
from datetime import datetime, timedelta
from pathlib import Path

WORLD = Path('/run/media/wildduck/New Volume/minecraft-wildduck/game/versions/gentleduck/saves/gentleduck')
DEST = Path.home() / '.local/share/minecraft-backups/gentleduck'
NAME = '%Y-%m-%d_%H%M'


def snapshots():
    return sorted(p for p in DEST.iterdir() if p.is_dir() and not p.name.startswith('.'))


def expired(names, now):
    # Every snapshot from the last 2 hours, then the newest of each hour for a day, of each day for a week.
    keep, buckets = set(), set()
    for name in sorted(names, reverse=True):
        taken = datetime.strptime(name, NAME)
        age = now - taken
        if age <= timedelta(hours=2):
            keep.add(name)
            continue
        if age <= timedelta(days=1):
            bucket = taken.strftime('h%Y%m%d%H')
        elif age <= timedelta(days=7):
            bucket = taken.strftime('d%Y%m%d')
        else:
            continue
        if bucket not in buckets:
            buckets.add(bucket)
            keep.add(name)
    return [n for n in names if n not in keep]


def main():
    level = WORLD / 'level.dat'
    if not level.exists():
        return  # New Volume is not mounted
    # An autosave rewrites the world over a few seconds; copy only once it has settled.
    while time.time() - level.stat().st_mtime < 20:
        time.sleep(5)
    DEST.mkdir(parents=True, exist_ok=True)
    existing = snapshots()
    last = existing[-1] if existing else None
    # rsync keeps mtimes, so an equal level.dat means the game has not saved since the last snapshot.
    if last and (last / 'level.dat').exists() and (last / 'level.dat').stat().st_mtime == level.stat().st_mtime:
        return
    name = datetime.now().strftime(NAME)
    partial = DEST / f'.{name}'
    cmd = ['rsync', '-a', '--delete', '--exclude', 'session.lock', f'{WORLD}/', f'{partial}/']
    if last:
        cmd.insert(2, f'--link-dest={last}')
    # 24 means a file vanished mid-copy, which the next run picks up.
    if subprocess.run(cmd).returncode not in (0, 24):
        shutil.rmtree(partial, ignore_errors=True)
        raise SystemExit('rsync failed')
    if (DEST / name).exists():
        # The timer and a manual run landed in the same minute; the first one already has this state.
        shutil.rmtree(partial)
        return
    partial.rename(DEST / name)
    for old in expired([p.name for p in snapshots()], datetime.now()):
        shutil.rmtree(DEST / old)


if __name__ == '__main__':
    main()
