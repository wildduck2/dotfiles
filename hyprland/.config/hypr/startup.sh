#!/usr/bin/env bash
#
# Hyprland startup layout — run on login to open apps on specific workspaces/monitors
#
# Layout (mirrors i3 startup):
#   Workspace 1 → external monitor → Google Chrome
#   Workspace 2 → external monitor → Kitty
#   Workspace 5 → primary monitor  → Discord
#
# Monitor detection uses hyprctl instead of xrandr

sleep 2

# Set wallpaper via swww (replaces hyprpaper)
WALLPAPER="/home/wildduck/.config/hypr/bgs/bg.jpg"
if [[ -f "$WALLPAPER" ]] && command -v swww &>/dev/null; then
  swww img "$WALLPAPER" --transition-type fade --transition-duration 1
fi

# Get monitors from hyprctl
MONITORS=$(hyprctl monitors -j)
MONITOR_COUNT=$(echo "$MONITORS" | jq 'length')

if [[ "$MONITOR_COUNT" -gt 1 ]]; then
  # Find the non-focused (external) monitor name
  PRIMARY=$(echo "$MONITORS" | jq -r '.[] | select(.focused == true) | .name')
  EXTERNAL=$(echo "$MONITORS" | jq -r '.[] | select(.focused == false) | .name' | head -1)

  # Bind workspaces to monitors
  hyprctl dispatch moveworkspacetomonitor "1 $EXTERNAL"
  hyprctl dispatch moveworkspacetomonitor "2 $EXTERNAL"
  hyprctl dispatch moveworkspacetomonitor "5 $PRIMARY"
else
  PRIMARY=$(echo "$MONITORS" | jq -r '.[0].name')
fi

# Launch app on a specific workspace if not already running
# Usage: launch_on_workspace <workspace> <class> <command...>
launch_on_workspace() {
  local ws="$1" class="$2"
  shift 2

  # Skip if already running
  if hyprctl clients -j | jq -e ".[] | select(.class == \"$class\")" &>/dev/null; then
    return 0
  fi

  hyprctl dispatch workspace "$ws"
  "$@" &>/dev/null &
  disown

  # Wait for window to appear (max 30s)
  for ((i = 0; i < 60; i++)); do
    if hyprctl clients -j | jq -e ".[] | select(.class == \"$class\")" &>/dev/null; then
      break
    fi
    sleep 0.5
  done
}

# Launch apps on their assigned workspaces
launch_on_workspace 1 "google-chrome" google-chrome-stable
launch_on_workspace 2 "kitty" kitty

# Focus workspace 1
hyprctl dispatch workspace 1

# Discord: launch last on workspace 5
if ! hyprctl clients -j | jq -e '.[] | select(.class == "discord")' &>/dev/null; then
  hyprctl dispatch workspace 5
  discord &>/dev/null &
  disown

  # Keep pushing Discord windows to workspace 5 for 60s
  for ((i = 0; i < 120; i++)); do
    hyprctl dispatch movetoworkspacesilent "5,class:discord" &>/dev/null
    sleep 0.5
  done
fi
