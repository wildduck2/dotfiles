#!/usr/bin/env bash
# The other half of clip-from-mac.sh: whatever is copied here, image or text, lands on the Mac's clipboard a
# moment later. Claude Code on the Mac reads its own clipboard on Ctrl+V, so an image pastes into an ssh session
# from any terminal, not only through kitty's Ctrl+V. The clip-to-mac user service keeps this running.
#   clip-to-mac-watch.sh [HOST]   HOST defaults to $CLIP_TO_MAC_HOST, then mac
set -euo pipefail

HOST="${1:-${CLIP_TO_MAC_HOST:-mac}}"
SEND="$(dirname "$(readlink -f "$0")")/clip-to-mac.sh"
# What clip-from-mac.sh put here last, by sha256: it came from the Mac, so it is not sent back.
FROM_MAC="${XDG_RUNTIME_DIR:-/tmp}/clip-from-mac.last"

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
  changes() { wl-paste --watch echo; }
  types() { wl-paste --list-types 2>/dev/null || true; }
  get() { wl-paste --type "$1"; }
else
  export DISPLAY="${DISPLAY:-:0}"
  changes() { while clipnotify -s clipboard; do echo; done; }
  types() { xclip -selection clipboard -t TARGETS -o 2>/dev/null || true; }
  get() { xclip -selection clipboard -t "$1" -o; }
fi

# What clip-to-mac.sh would send, so the two hash the same bytes.
held() {
  local offered
  offered=$(types)
  if grep -qx image/png <<<"$offered"; then
    get image/png
  elif grep -qxE 'UTF8_STRING|text/plain;charset=utf-8' <<<"$offered"; then
    get UTF8_STRING 2>/dev/null || get text/plain
  fi
}

changes | while read -r _; do
  sum=$(held 2>/dev/null | sha256sum | cut -d' ' -f1)
  [ -f "$FROM_MAC" ] && [ "$sum" = "$(cat "$FROM_MAC")" ] && continue
  "$SEND" --quiet "$HOST" || true
done
