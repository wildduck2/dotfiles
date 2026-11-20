# minecraft

Snapshots of the `gentleduck` world every 10 minutes, so a broken build or emptied chests can be put back.

`./setup.sh minecraft` stows `minecraft-backup.timer` and enables it. Each run of `backup.py` copies the world
from `New Volume` into `~/.local/share/minecraft-backups/gentleduck/<date>_<time>` with
`rsync --link-dest`, so files the game did not rewrite are hard links to the previous snapshot and a snapshot
costs only the changed region files. It waits until an autosave has settled, skips the run when the game has
not saved since the last snapshot, and does nothing while `New Volume` is unmounted.

It keeps every snapshot from the last 2 hours, then the newest of each hour for a day and of each day for a
week. The backups live on the Linux drive because `New Volume` is exFAT (no hard links) and nearly full.

Minecraft's own autosave overwrites the world every 5 minutes and keeps no history, which is why this exists.

## Restoring

Quit the world to the title screen first (the game holds the world open and would overwrite the restore),
then copy a snapshot back over it:

```sh
rsync -a --delete --exclude session.lock \
  ~/.local/share/minecraft-backups/gentleduck/2026-10-31_0720/ \
  "/run/media/wildduck/New Volume/minecraft-wildduck/game/versions/gentleduck/saves/gentleduck/"
```

`--delete` makes the world exactly the snapshot, so copy the current world somewhere first if any of it is
worth keeping. To bring back a few chests instead of the whole world, read them out of a snapshot's region
files and place them with `/setblock`.

## Discord

`discord-presence.py` (`minecraft-presence.service`) shows "Playing Minecraft" with the game's icon on
Discord while Minecraft runs, counting from when the game started. Discord cannot recognise the game on
Linux by itself (its list of games only has the Windows and Mac programs), so the script tells it over
Discord's local socket, using Discord's own Minecraft entry for the name and icon. It looks for the game
every 5 seconds and takes the status off again when the game closes.

TLauncher sends its own "TLauncher" status, which Discord shows ahead of the game's, unless its Discord box
is unticked (`gui.discord.checkbox` in `~/.tlauncher/tlauncher-2.0.properties`). TLauncher writes that file
back whenever it saves, so the script turns the box off again each time it reappears; TLauncher reads it when it
starts, so a TLauncher that is already open keeps its status until it is restarted. `journalctl --user -u
minecraft-presence` shows what the script did.

## Hold to mine

`F9` (bound in the i3 config) toggles holding left click while Minecraft is focused, so long tunnels and the
stone farm mine without holding the mouse button. Press `F9` again, or click, to stop.
