#!/usr/bin/env bash
# The other way from clip-to-mac.sh: whatever is copied on the Mac (Cmd+C in any app, a screenshot to the
# clipboard, a copy in its terminal) lands on this machine's clipboard, image or text.
# mac-clipboard-watch.js is sent over ssh each time this starts, so nothing is installed on the Mac; the
# clip-from-mac user service keeps this running and starts it again when the Mac sleeps or leaves.
#   clip-from-mac.sh [HOST]   HOST defaults to $CLIP_TO_MAC_HOST, then mac
set -euo pipefail

HOST="${1:-${CLIP_TO_MAC_HOST:-mac}}"
WATCH="$(dirname "$(readlink -f "$0")")/mac-clipboard-watch.js"
# What clip-to-mac.sh sent last, by sha256; it comes straight back as a change on the Mac and is skipped.
LAST="${XDG_RUNTIME_DIR:-/tmp}/clip-to-mac.last"
# What this put on the clipboard last, by sha256, for clip-to-mac-watch.sh: it came from the Mac, so it is not sent back.
FROM_MAC="${XDG_RUNTIME_DIR:-/tmp}/clip-from-mac.last"

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
  put_image() { wl-copy --type image/png; }
  put_text() { wl-copy; }
  current() { wl-paste --no-newline --type text/plain 2>/dev/null || true; }
else
  export DISPLAY="${DISPLAY:-:0}"
  put_image() { xclip -selection clipboard -t image/png -i; }
  put_text() { xclip -selection clipboard -i; }
  # Only when it holds text: xclip serving an image hands it out whatever type is asked for.
  current() {
    if xclip -selection clipboard -t TARGETS -o 2>/dev/null | grep -qx UTF8_STRING; then
      xclip -selection clipboard -t UTF8_STRING -o 2>/dev/null || true
    fi
  }
fi

payload=$(mktemp)
trap 'rm -f "$payload"' EXIT

ssh -o BatchMode=yes -o ConnectTimeout=5 -o ServerAliveInterval=15 -o ServerAliveCountMax=2 "$HOST" \
  'osascript -l JavaScript -' <"$WATCH" |
  while read -r kind data; do
    base64 -d <<<"$data" >"$payload" || continue
    sum=$(sha256sum <"$payload" | cut -d' ' -f1)
    [ -f "$LAST" ] && [ "$sum" = "$(cat "$LAST")" ] && continue
    echo "$sum" >"$FROM_MAC"
    case "$kind" in
      image) put_image <"$payload" ;;
      # A copy in the Mac's terminal already arrived through the terminal itself (OSC 52).
      text) [ "$(current)" = "$(cat "$payload")" ] || put_text <"$payload" ;;
    esac
  done
