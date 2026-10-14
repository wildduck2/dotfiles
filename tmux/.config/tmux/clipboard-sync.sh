#!/usr/bin/env bash
# Terminator (VTE) ignores OSC 52, so mirror every new tmux buffer (ssh/nvim copies included)
# into the system clipboard. A read-only control client is the only place tmux reports buffer changes.

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/tmux-clipboard-sync.lock"
flock -n 9 || exit 0

copy() {
  if [ -n "$WAYLAND_DISPLAY" ]; then wl-copy; else DISPLAY="${DISPLAY:-:0}" xclip -in -selection clipboard; fi
}

while tmux has-session 2>/dev/null; do
  sleep infinity | tmux -C attach -f ignore-size,no-output,read-only 2>/dev/null |
    while IFS= read -r line; do
      case "$line" in
        %paste-buffer-changed*) tmux save-buffer - 2>/dev/null | copy ;;
      esac
    done
  sleep 1
done
