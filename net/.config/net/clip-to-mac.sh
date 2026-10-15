#!/usr/bin/env bash
# Push this machine's clipboard (image or text) into the Mac's clipboard.
# Terminal paste over ssh is text-only, so images have to go through osascript on the Mac.
#   clip-to-mac.sh                    image or text to $CLIP_TO_MAC_HOST (default: mac)
#   clip-to-mac.sh --image-only HOST  only an image (kitty's Ctrl+V), every time, so the newest copy wins
#   clip-to-mac.sh --kind             print image or text: what kitty's Ctrl+V should do with the clipboard
set -euo pipefail

ONLY_IMAGE=0
KIND=0
if [ "${1:-}" = --image-only ]; then
  ONLY_IMAGE=1
  shift
elif [ "${1:-}" = --kind ]; then
  KIND=1
  shift
fi
HOST="${1:-${CLIP_TO_MAC_HOST:-mac}}"

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
  types=$(wl-paste --list-types 2>/dev/null || true)
  get() { wl-paste --type "$1"; }
else
  export DISPLAY="${DISPLAY:-:0}"
  types=$(xclip -selection clipboard -t TARGETS -o 2>/dev/null || true)
  get() { xclip -selection clipboard -t "$1" -o; }
fi

if [ "$KIND" = 1 ]; then
  if grep -qx 'image/png' <<<"$types"; then echo image; else echo text; fi
  exit 0
fi

notify() { notify-send -t 2000 "clip-to-mac" "$1" 2>/dev/null || echo "$1"; }

if grep -qx 'image/png' <<<"$types"; then
  image=$(mktemp)
  trap 'rm -f "$image"' EXIT
  get image/png >"$image"
  ssh -o BatchMode=yes -o ConnectTimeout=5 "$HOST" 'f=$(mktemp -t clip) && cat > "$f" &&
    osascript -e "set the clipboard to (read (POSIX file \"$f\") as «class PNGf»)" >/dev/null; rm -f "$f"' <"$image"
  [ "$ONLY_IMAGE" = 1 ] || notify "Image sent to the Mac clipboard"
elif [ "$ONLY_IMAGE" = 0 ]; then
  get UTF8_STRING | ssh -o BatchMode=yes "$HOST" pbcopy
  notify "Text sent to the Mac clipboard"
fi
