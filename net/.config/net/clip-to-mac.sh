#!/usr/bin/env bash
# Push this machine's clipboard (image or text) into the Mac's clipboard.
# Terminal paste over ssh is text-only, so images have to go through osascript on the Mac.
#   clip-to-mac.sh                    image or text to $CLIP_TO_MAC_HOST (default: mac)
#   clip-to-mac.sh --image-only HOST  only an image (kitty's Ctrl+V), every time, so the newest copy wins
#   clip-to-mac.sh --kind             print image or text: what kitty's Ctrl+V should do with the clipboard
#   clip-to-mac.sh --quiet [HOST]     image or text, saying nothing on success (clip-to-mac-watch.sh, on every copy)
set -euo pipefail

ONLY_IMAGE=0
KIND=0
QUIET=0
if [ "${1:-}" = --image-only ]; then
  ONLY_IMAGE=1
  shift
elif [ "${1:-}" = --kind ]; then
  KIND=1
  shift
elif [ "${1:-}" = --quiet ]; then
  QUIET=1
  shift
fi
HOST="${1:-${CLIP_TO_MAC_HOST:-mac}}"
# Read by clip-from-mac.sh, which would otherwise hand what was just sent straight back. Written before the
# send, since the Mac can report the change before the send returns.
LAST="${XDG_RUNTIME_DIR:-/tmp}/clip-to-mac.last"

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

notify() { [ "$QUIET" = 1 ] || notify-send -t 2000 "clip-to-mac" "$1" 2>/dev/null || echo "$1"; }
# A send that fails says so (Ctrl+V would otherwise paste nothing, with no reason given) and exits non-zero.
# Quiet, it goes to the journal only: a Mac asleep would otherwise raise an alert on every copy.
fail() {
  if [ "$QUIET" = 0 ] && notify-send -u critical -t 5000 "clip-to-mac" "Could not send to $HOST: $1" 2>/dev/null; then exit 1; fi
  echo "Could not send to $HOST: $1" >&2
  exit 1
}

if grep -qx 'image/png' <<<"$types"; then
  image=$(mktemp)
  trap 'rm -f "$image"' EXIT
  get image/png >"$image"
  sha256sum <"$image" | cut -d' ' -f1 >"$LAST"
  err=$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$HOST" 'f=$(mktemp -t clip) && cat > "$f" &&
    osascript -e "set the clipboard to (read (POSIX file \"$f\") as «class PNGf»)" >/dev/null; rm -f "$f"' \
    <"$image" 2>&1 >/dev/null) || fail "${err##*: }"
  [ "$ONLY_IMAGE" = 1 ] || notify "Image sent to the Mac clipboard"
elif [ "$ONLY_IMAGE" = 0 ]; then
  text=$(mktemp)
  trap 'rm -f "$text"' EXIT
  get UTF8_STRING >"$text"
  sha256sum <"$text" | cut -d' ' -f1 >"$LAST"
  # pbcopy reads bytes in the session's locale, which an ssh command does not set.
  err=$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$HOST" 'LANG=en_US.UTF-8 pbcopy' <"$text" 2>&1 >/dev/null) ||
    fail "${err##*: }"
  notify "Text sent to the Mac clipboard"
fi
