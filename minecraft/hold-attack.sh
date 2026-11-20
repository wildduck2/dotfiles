#!/bin/sh
# Toggles holding left click in Minecraft, so mining keeps going without holding the button down.
# A real click releases it early; the next toggle then just resets the state.
state="${XDG_RUNTIME_DIR:-/tmp}/mc-hold-attack"
if [ -e "$state" ]; then
    rm -f "$state"
    xdotool mouseup 1
    exit 0
fi
case "$(xdotool getactivewindow getwindowname 2>/dev/null)" in
    Minecraft*) ;;
    *) exit 0 ;;
esac
touch "$state"
xdotool mousedown 1
