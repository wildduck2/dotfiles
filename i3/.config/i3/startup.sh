#!/usr/bin/env bash
#
# i3 startup layout — run on login to open apps on specific workspaces/monitors
#
# Layout:
#   Workspace 1 → external monitor → Google Chrome
#   Workspace 2 → external monitor → Kitty
#   Workspace 5 → primary monitor  → Discord
#
# Monitor detection:
#   - External on the left  → use it for Chrome/Kitty
#   - External on the right → rotate it left, then use it
#   - No external monitor   → keep everything on primary

# Auto-detect monitors
PRIMARY=$(xrandr --query | grep ' connected primary' | awk '{print $1}')
PRIMARY_X=$(xrandr --query | grep ' connected primary' | grep -oP '\d+x\d+\+\K\d+')
EXTERNAL=$(xrandr --query | grep ' connected' | grep -v 'primary' | head -1 | awk '{print $1}')
EXTERNAL_X=$(xrandr --query | grep ' connected' | grep -v 'primary' | head -1 | grep -oP '\d+x\d+\+\K\d+')

if [[ -n "$EXTERNAL" ]]; then
  if [[ "$EXTERNAL_X" -lt "$PRIMARY_X" ]]; then
    # External monitor is on the left — use it for Chrome
    CHROME_OUTPUT="$EXTERNAL"
  else
    # External monitor is on the right — rotate it
    xrandr --output "$EXTERNAL" --rotate left
    CHROME_OUTPUT="$EXTERNAL"
  fi
else
  # No external monitor — everything on primary
  CHROME_OUTPUT="$PRIMARY"
fi

# Assign workspaces to monitors
i3-msg "workspace 1, move workspace to output $CHROME_OUTPUT"
i3-msg "workspace 2, move workspace to output $CHROME_OUTPUT"
i3-msg "workspace 5, move workspace to output $PRIMARY"

sleep 1

# Launch app on a specific workspace/output if not already running
# Usage: launch_on_workspace <workspace> <output> <class> <command...>
launch_on_workspace() {
  local ws="$1" output="$2" class="$3"
  shift 3

  # Skip if already running
  if xdotool search --class "$class" &>/dev/null; then
    return 0
  fi

  # Focus workspace and ensure it's on the correct monitor
  i3-msg "workspace $ws, move workspace to output $output"
  "$@" &>/dev/null &
  disown

  # Wait for window to appear (max 30s)
  for ((i=0; i<60; i++)); do
    if xdotool search --class "$class" &>/dev/null; then
      break
    fi
    sleep 0.5
  done
}

# Launch apps on their assigned workspaces
launch_on_workspace 1 "$CHROME_OUTPUT" "Google-chrome" google-chrome-stable
launch_on_workspace 2 "$CHROME_OUTPUT" "kitty" kitty

# Focus workspace 1
i3-msg 'workspace 1'

# Discord: launch last on workspace 5
# Discord has a splash then main window — stay on ws 5 until it's fully loaded
if ! xdotool search --class "Discord" &>/dev/null; then
  i3-msg "workspace 5, move workspace to output $PRIMARY"
  discord &>/dev/null &
  disown

  # Keep focus on workspace 5 and push Discord windows there for 60s
  for ((i=0; i<120; i++)); do
    i3-msg '[class="Discord"] move to workspace 5' &>/dev/null
    sleep 0.5
  done
fi
