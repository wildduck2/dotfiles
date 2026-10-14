#!/bin/sh
# i3 runs exec lines once at login, so a screen plugged in later stays off.
# Rerun monitor-setup.sh whenever the set of connected outputs changes.
# --current reads the X server's state without re-probing (~3ms), so polling is cheap.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/monitor-watch.lock"
flock -n 9 || exit 0

last=""
while :; do
    now=$(xrandr --current | awk '$2=="connected"{print $1}' | sort | tr '\n' ' ')
    if [ "$now" != "$last" ]; then
        "$HOME/.config/i3/monitor-setup.sh"
        last=$now
    fi
    sleep 2
done
