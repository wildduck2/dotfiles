#!/usr/bin/env bash
# Bound to Ctrl+Shift+V via `launch --type=background`, so the blocking clipboard
# read happens off kitty's UI thread and can never freeze the terminal. If the
# clipboard holds an image, save it and type the file path; otherwise fall back to
# kitty's native (bracketed, SSH-safe) text paste. All reads have timeouts.

set -u

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
  targets() { timeout 2 wl-paste --list-types 2>/dev/null; }
  image()   { timeout 3 wl-paste -t image/png 2>/dev/null; }
else
  targets() { timeout 2 xclip -selection clipboard -t TARGETS -o 2>/dev/null; }
  image()   { timeout 3 xclip -selection clipboard -t image/png -o 2>/dev/null; }
fi

if targets | grep -q '^image/'; then
  dir="$HOME/Pictures/pasted"
  mkdir -p "$dir"
  f="$dir/$(date +%Y%m%d-%H%M%S).png"
  if image >"$f" && [ -s "$f" ]; then
    kitten @ send-text --match recent:0 -- "$f"
    exit 0
  fi
  rm -f "$f"
fi

kitten @ action --match recent:0 paste_from_clipboard
