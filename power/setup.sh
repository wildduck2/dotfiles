#!/usr/bin/env bash
#
# Hibernation that survives days in Windows: a swapfile big enough for all of RAM, and the kernel told where
# it is. Can be run standalone or called from the main setup.sh; safe to run again.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

SWAPFILE=/swapfile
# Every page of RAM, plus room for what the kernel needs while it writes them.
SIZE_GIB=$(( $(awk '/MemTotal/ { print int($2 / 1048576) + 2 }' /proc/meminfo) ))

header "Hibernation"
check_arch

# -- Swapfile --------------------------------------------------------------
# The image is written to swap; a partition smaller than RAM fails with "No space left on device".
if [[ ! -f $SWAPFILE ]]; then
  sudo fallocate -l "${SIZE_GIB}G" "$SWAPFILE"
  sudo chmod 600 "$SWAPFILE"
  sudo mkswap "$SWAPFILE" >/dev/null
  ok "Created ${SIZE_GIB} GiB $SWAPFILE"
fi
# A higher priority than the partition, so it is the swap systemd hibernates into.
if ! grep -q "^$SWAPFILE " /etc/fstab; then
  echo "$SWAPFILE none swap defaults,pri=10 0 0" | sudo tee -a /etc/fstab >/dev/null
  ok "Added $SWAPFILE to /etc/fstab"
fi
swapon --show=NAME --noheadings | grep -qx "$SWAPFILE" || sudo swapon -p 10 "$SWAPFILE"

# -- Where to resume from ----------------------------------------------------
# A swapfile is named by its filesystem and its first block, which a reboot never moves.
ROOT_UUID=$(findmnt -no UUID -T "$SWAPFILE")
# The physical start of the first extent: the third colon-separated field of filefrag's row 0.
OFFSET=$(sudo filefrag -v "$SWAPFILE" | awk -F: '$1 ~ /^ *0$/ { split($3, at, "[.][.]"); gsub(/ /, "", at[1]); print at[1]; exit }')
RESUME="resume=UUID=$ROOT_UUID resume_offset=$OFFSET"
CURRENT=$(sed -n 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"$/\1/p' /etc/default/grub)
WANTED=$(echo "$CURRENT" | sed -E 's/ ?resume(_offset)?=[^ ]*//g; s/^ //')
WANTED="${WANTED:+$WANTED }$RESUME"
if [[ $CURRENT != "$WANTED" ]]; then
  sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$WANTED\"|" /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1
  ok "GRUB resumes from $SWAPFILE (offset $OFFSET)"
fi

# The systemd initramfs hook reads resume= itself; a busybox one needs the resume hook.
if ! grep -qE '^HOOKS=.*\b(systemd|resume)\b' /etc/mkinitcpio.conf; then
  warn "mkinitcpio has neither the systemd nor the resume hook: add resume after filesystems, then mkinitcpio -P"
fi

ok "Hibernation ready: reboot once, then Mod+Ctrl+Shift+. hibernates"
