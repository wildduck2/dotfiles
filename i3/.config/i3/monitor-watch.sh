#!/bin/sh
# i3 runs exec lines once at login, so a screen plugged in later stays off.
# Rerun monitor-setup.sh whenever the set of connected outputs changes.
# --current reads the X server's state without re-probing (~3ms), so polling is cheap.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/monitor-watch.lock"
flock -n 9 || exit 0

last=""
size=""
while :; do
    state=$(xrandr --current)
    now=$(echo "$state" | awk '$2=="connected"{print $1}' | sort | tr '\n' ' ')
    if [ "$now" != "$last" ]; then
        "$HOME/.config/i3/monitor-setup.sh"
        last=$now
    fi
    # X starts at 640x480 until the panel comes up and tiles a wallpaper painted then across the full screen,
    # so it is painted again whenever the screen changes size.
    current=$(echo "$state" | sed -n '1s/.*current \([0-9]* x [0-9]*\).*/\1/p')
    if [ "$current" != "$size" ]; then
        feh --no-fehbg --bg-fill "$HOME/.config/i3/bgs/bg.jpg"
        size=$current
    fi
    sleep 2
done
