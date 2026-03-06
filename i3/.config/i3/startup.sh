#!/usr/bin/env bash
#
# i3 startup layout — run on login to open apps on specific workspaces/monitors
#
# Layout:
#   Workspace 1 → external monitor → Google Chrome
#   Workspace 2 → external monitor → Kitty
#   Workspace 5 → primary monitor  → Discord
#
# Monitor names are auto-detected. The primary monitor gets Discord,
# the first non-primary monitor gets Chrome and Kitty.

# Wait for a window with the given class to appear (max 10s)
wait_for_window() {
  local class="$1"
  local max=20
  for ((i=0; i<max; i++)); do
    if xdotool search --class "$class" &>/dev/null; then
      return 0
    fi
    sleep 0.5
  done
  return 1
}

# Auto-detect monitors
PRIMARY=$(xrandr --query | grep ' connected primary' | awk '{print $1}')
EXTERNAL=$(xrandr --query | grep ' connected' | grep -v 'primary' | head -1 | awk '{print $1}')

# Fallback: if no external monitor, use primary for everything
if [[ -z "$EXTERNAL" ]]; then
  EXTERNAL="$PRIMARY"
fi

sleep 1

# --- Workspace 1: Chrome on external monitor ---
if command -v google-chrome-stable &>/dev/null; then
  i3-msg "workspace 1, move workspace to output $EXTERNAL"
  google-chrome-stable &
  wait_for_window "Google-chrome"
  i3-msg '[class="Google-chrome"] move to workspace 1'
fi

# --- Workspace 2: Kitty on external monitor ---
if command -v kitty &>/dev/null; then
  i3-msg "workspace 2, move workspace to output $EXTERNAL"
  kitty &
  wait_for_window "kitty"
  i3-msg '[class="kitty"] move to workspace 2'
fi

# --- Workspace 5: Discord on primary monitor ---
if command -v discord &>/dev/null; then
  i3-msg "workspace 5, move workspace to output $PRIMARY"
  discord &
  wait_for_window "discord"
  i3-msg '[class="discord"] move to workspace 5'
fi

# Focus workspace 1
i3-msg 'workspace 1'
