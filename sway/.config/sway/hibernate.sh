#!/usr/bin/env bash
# Windows plays Minecraft from New Volume while Linux is hibernated, so the drive is unmounted first: a
# hibernated system still holding it would write its stale view over what Windows changed.
uuid=5EDD-DEB2
if findmnt -rn -S "UUID=$uuid" >/dev/null && ! udisksctl unmount -b "/dev/disk/by-uuid/$uuid" >/dev/null 2>&1; then
  notify-send -a osd -u critical -i drive-harddisk "Not hibernating" "New Volume is still in use: close Minecraft and anything open on it"
  exit 1
fi
exec systemctl hibernate
