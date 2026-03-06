#!/usr/bin/env bash
#
# i3 startup layout — run on login to open apps on specific workspaces/monitors
#
# Monitors:
#   DP-1-3  = external 1920x1080
#   eDP-1   = main 2.5K laptop (primary)
#
# Layout:
#   Workspace 1 → DP-1-3  → Google Chrome
#   Workspace 2 → DP-1-3  → Kitty
#   Workspace 5 → eDP-1   → Discord
#

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

sleep 1

# --- Workspace 1: Chrome on external monitor ---
i3-msg 'workspace 1, move workspace to output DP-1-3'
google-chrome-stable &
wait_for_window "Google-chrome"
i3-msg '[class="Google-chrome"] move to workspace 1'

# --- Workspace 2: Kitty on external monitor ---
i3-msg 'workspace 2, move workspace to output DP-1-3'
kitty &
wait_for_window "kitty"
i3-msg '[class="kitty"] move to workspace 2'

# --- Workspace 5: Discord on main laptop monitor ---
i3-msg 'workspace 5, move workspace to output eDP-1'
discord &
wait_for_window "discord"
i3-msg '[class="discord"] move to workspace 5'

# Focus workspace 1
i3-msg 'workspace 1'
