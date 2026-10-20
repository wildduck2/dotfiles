#!/bin/sh
# Dual-monitor layout when an external monitor is plugged in, laptop panel
# only otherwise. Detects the external output by connection state rather
# than a fixed name (DP-1/DP-3/HDMI-0 etc. shift depending on which port
# or dock the monitor is plugged into). Also turns off any previously
# active output that's no longer connected, since xrandr's atomic apply
# fails if a stale enabled output is left out of the command entirely.
INTERNAL=eDP-1-1
EXTERNAL=$(xrandr --query | awk -v i="$INTERNAL" '$1!=i && $2=="connected"{print $1; exit}')
ACTIVE=$(xrandr --listactivemonitors | awk 'NR>1{print $4}')

if [ -n "$EXTERNAL" ]; then
    xrandr --output "$INTERNAL" --primary --mode 2560x1600 --rate 240 --rotate normal \
           --output "$EXTERNAL" --auto --left-of "$INTERNAL"
else
    xrandr --output "$INTERNAL" --primary --mode 2560x1600 --rate 240 --rotate normal
    for out in $ACTIVE; do
        [ "$out" = "$INTERNAL" ] || xrandr --output "$out" --off
    done
fi

# A new output starts black, so repaint the wallpaper across the new layout
feh --no-fehbg --bg-fill "$HOME/.config/i3/bgs/bg.jpg"
