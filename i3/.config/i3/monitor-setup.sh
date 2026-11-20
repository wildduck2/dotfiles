#!/bin/sh
# Dual-monitor layout when an external monitor is plugged in, laptop panel
# only otherwise. Detects the external output by connection state rather
# than a fixed name (DP-1/DP-3/HDMI-0 etc. shift depending on which port
# or dock the monitor is plugged into). Also turns off any previously
# active output that's no longer connected, since xrandr's atomic apply
# fails if a stale enabled output is left out of the command entirely.
# The panel's name depends on which GPU drives it (eDP-1-1 through the AMD chip, another name once
# the GPU switch wires it to NVIDIA), so find it: an eDP output, else the one offering the panel's mode.
INTERNAL=$(xrandr --query | awk '$2=="connected" && $1 ~ /^eDP/ {print $1; exit}')
[ -n "$INTERNAL" ] || INTERNAL=$(xrandr --query | awk '/^[^ ]/{o=($2=="connected")?$1:""} /^ +2560x1600/ && o {print o; exit}')
EXTERNAL=$(xrandr --query | awk -v i="$INTERNAL" '$1!=i && $2=="connected"{print $1; exit}')
ACTIVE=$(xrandr --listactivemonitors | awk 'NR>1{print $4}')

if [ -n "$EXTERNAL" ]; then
    # --auto takes the preferred mode, usually 60 Hz, so use the largest mode at its fastest rate.
    MODES=$(xrandr --query | awk -v o="$EXTERNAL" '$1==o{f=1;next} f&&!/^ /{exit} f{print}' | head -1)
    MODE=$(echo "$MODES" | awk '{print $1}')
    RATE=$(echo "$MODES" | awk '{m=0; for(i=2;i<=NF;i++){r=$i; gsub(/[*+]/,"",r); if(r+0>m)m=r+0} print m}')
    xrandr --output "$INTERNAL" --primary --mode 2560x1600 --rate 240 --rotate normal \
           --output "$EXTERNAL" --mode "$MODE" --rate "$RATE" --rotate normal --left-of "$INTERNAL"
else
    xrandr --output "$INTERNAL" --primary --mode 2560x1600 --rate 240 --rotate normal
    for out in $ACTIVE; do
        [ "$out" = "$INTERNAL" ] || xrandr --output "$out" --off
    done
fi

# A new output starts black, so repaint the wallpaper across the new layout
feh --no-fehbg --bg-fill "$HOME/.config/i3/bgs/bg.jpg"
