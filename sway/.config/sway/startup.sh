#!/usr/bin/env bash
#
# Sway startup layout — open apps on specific workspaces/monitors
#
# Layout:
#   Workspace 1 → external monitor → Google Chrome
#   Workspace 2 → external monitor → Kitty
#   Workspace 5 → primary monitor  → Discord

sleep 2

# Auto-detect monitors via swaymsg
PRIMARY=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.focused == true) | .name')
EXTERNAL=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.focused == false) | .name' | head -1)

if [[ -z "$EXTERNAL" ]]; then
  EXTERNAL="$PRIMARY"
fi

# Assign workspaces to monitors
swaymsg "workspace 1, move workspace to output $EXTERNAL"
swaymsg "workspace 2, move workspace to output $EXTERNAL"
swaymsg "workspace 5, move workspace to output $PRIMARY"

sleep 1

# Launch app on a specific workspace if not already running
launch_on_workspace() {
  local ws="$1" class="$2"
  shift 2

  # Skip if already running
  if swaymsg -t get_tree | jq -e ".. | select(.app_id? == \"$class\" or .window_properties?.class? == \"$class\")" &>/dev/null; then
    return 0
  fi

  swaymsg "workspace $ws"
  "$@" &>/dev/null &
  disown

  # Wait for window to appear (max 30s)
  for ((i=0; i<60; i++)); do
    if swaymsg -t get_tree | jq -e ".. | select(.app_id? == \"$class\" or .window_properties?.class? == \"$class\")" &>/dev/null; then
      break
    fi
    sleep 0.5
  done
}

# Launch apps on their assigned workspaces
launch_on_workspace 1 "Google-chrome" google-chrome-stable
launch_on_workspace 2 "kitty" kitty

# Focus workspace 1
swaymsg 'workspace 1'

# Discord: launch last on workspace 5
if ! swaymsg -t get_tree | jq -e '.. | select(.window_properties?.class? == "discord" or .app_id? == "discord")' &>/dev/null; then
  swaymsg "workspace 5"
  discord &>/dev/null &
  disown

  for ((i=0; i<120; i++)); do
    swaymsg '[class="discord"] move to workspace 5' &>/dev/null
    swaymsg '[app_id="discord"] move to workspace 5' &>/dev/null
    sleep 0.5
  done
fi
