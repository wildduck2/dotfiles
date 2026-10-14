#!/usr/bin/env bash
# Push this machine's clipboard (image or text) into the Mac's clipboard.
# Terminal paste over ssh is text-only, so images have to go through osascript on the Mac.
set -euo pipefail

HOST="${CLIP_TO_MAC_HOST:-mac}"

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
  types=$(wl-paste --list-types)
  get() { wl-paste --type "$1"; }
else
  export DISPLAY="${DISPLAY:-:0}"
  types=$(xclip -selection clipboard -t TARGETS -o)
  get() { xclip -selection clipboard -t "$1" -o; }
fi

notify() { notify-send -t 2000 "clip-to-mac" "$1" 2>/dev/null || echo "$1"; }

if grep -qx 'image/png' <<<"$types"; then
  get image/png | ssh "$HOST" 'f=$(mktemp -t clip) && cat > "$f" &&
    osascript -e "set the clipboard to (read (POSIX file \"$f\") as «class PNGf»)" >/dev/null && rm -f "$f"'
  notify "Image sent to the Mac clipboard"
else
  get UTF8_STRING | ssh "$HOST" pbcopy
  notify "Text sent to the Mac clipboard"
fi
