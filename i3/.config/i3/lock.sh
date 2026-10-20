#!/usr/bin/env bash
# A GNOME-style lock on i3lock-color: the date and a large clock over the blurred, dimmed wallpaper, then the
# account picture (~/.face, else the initial), the name and the password feedback in GNOME's wording.
pgrep -x i3lock >/dev/null && exit 0

wallpaper=$HOME/.config/i3/bgs/bg.jpg
face=$HOME/.face
cache=${XDG_CACHE_HOME:-$HOME/.cache}/i3lock
font="Adwaita Sans"
font_file=/usr/share/fonts/Adwaita/AdwaitaSans-Regular.ttf
name=$(getent passwd "$USER" | cut -d: -f5 | cut -d, -f1)
name=${name:-$USER}
initial=${name:0:1}
initial=${initial^}

# "2560/344x1600/215+0+0" for each screen, the first one sizing the text.
mapfile -t screens < <(xrandr --listactivemonitors | awk 'NR > 1 { print $3 }' |
  sed -E 's|^([0-9]+)/[0-9]+x([0-9]+)/[0-9]+\+([0-9]+)\+([0-9]+)$|\1 \2 \3 \4|')
read -r root_w root_h < <(xrandr --current | sed -n '1s/.*current \([0-9]*\) x \([0-9]*\).*/\1 \2/p')
read -r _ first_h _ _ <<<"${screens[0]:-0 1080 0 0}"
unit=$((first_h / 100))
face_size=$((unit * 12))
ring=$((face_size / 2 + unit))
# i3lock scales sizes and offsets by the screen's dpi over 96, and X reports this panel at 75, so they are passed
# pre-divided to land on real pixels.
dpi=$(xdpyinfo | awk '/resolution:/ { split($2, r, "x"); print r[1]; exit }')
px() { echo $(($1 * 96 / ${dpi:-96})); }

# Blurring a full screen takes a moment, so each layout's background is drawn once and kept.
key=$(printf '%s|' "${screens[@]}" "$root_w" "$root_h" "$(stat -c %Y "$wallpaper" "$face" "$0" 2>/dev/null)" |
  md5sum | cut -c1-12)
image=$cache/lock-$key.png
if [[ ! -f $image ]]; then
  mkdir -p "$cache" && rm -f "$cache"/lock-*.png
  picture=$cache/face.png
  if [[ -f $face ]]; then
    magick "$face" -resize "${face_size}x${face_size}^" -gravity center -extent "${face_size}x${face_size}" \
      \( -size "${face_size}x${face_size}" xc:none -fill white -draw "circle $((face_size / 2)),$((face_size / 2)) $((face_size / 2)),0" \) \
      -compose DstIn -composite "$picture"
  else
    magick -size "${face_size}x${face_size}" xc:none -fill "#89b4fa" \
      -draw "circle $((face_size / 2)),$((face_size / 2)) $((face_size / 2)),0" \
      -font "$font_file" -pointsize $((face_size * 45 / 100)) -fill "#1e1e2e" -gravity center \
      -annotate +0+0 "$initial" "$picture"
  fi
  layers=()
  for screen in "${screens[@]}"; do
    read -r w h x y <<<"$screen"
    # Blurred at an eighth of the size and scaled back up: the same soft look as GNOME's, in a fraction of the time.
    layers+=(\( "$wallpaper" -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" -resize 12.5% -blur 0x5
      -filter Gaussian -resize "${w}x${h}!" -modulate 62,92 \) -gravity northwest -geometry "+$x+$y" -composite
      "$picture" -geometry "+$((x + (w - face_size) / 2))+$((y + h * 55 / 100 - face_size / 2))" -composite)
  done
  magick -size "${root_w}x${root_h}" xc:"#1e1e2e" "${layers[@]}" -define png:compression-level=1 "$image" || image=""
fi

# Notifications would draw over the lock screen, so they wait until it is unlocked.
paused=$(dunstctl is-paused 2>/dev/null)
dunstctl set-paused true 2>/dev/null

white=ffffffff
dim=ffffffb3
blue=89b4faff
red=f38ba8ff
clear=00000000

i3lock ${image:+--image "$image"} --color 1e1e2eff \
  --ignore-empty-password --pass-media-keys --pass-volume-keys --pass-screen-keys \
  --force-clock --indicator --radius "$(px $ring)" --ring-width "$(px $((unit / 2)))" \
  --ind-pos "x+w/2:y+h*0.55" \
  --inside-color "$clear" --insidever-color "$clear" --insidewrong-color "$clear" \
  --ring-color ffffff26 --ringver-color "$blue" --ringwrong-color "$red" \
  --line-color "$clear" --separator-color "$clear" --keyhl-color "$blue" --bshl-color "$red" \
  --date-str "%A %-d %B" --date-font "$font" --date-size "$(px $((unit * 22 / 10)))" --date-color "$dim" \
  --date-pos "x+w/2:y+h*0.17" \
  --time-str "%H:%M" --time-font "$font" --time-size "$(px $((unit * 10)))" --time-color "$white" \
  --time-pos "x+w/2:y+h*0.17+$(px $((unit * 11)))" \
  --greeter-text "$name" --greeter-font "$font" --greeter-size "$(px $((unit * 24 / 10)))" --greeter-color "$white" \
  --greeter-pos "ix:iy+$(px $((ring + unit * 5)))" \
  --verif-text "Unlocking…" --verif-font "$font" --verif-size "$(px $((unit * 16 / 10)))" --verif-color "$dim" \
  --verif-pos "ix:iy+$(px $((ring + unit * 9)))" \
  --wrong-text "Sorry, that didn’t work. Please try again." --wrong-font "$font" \
  --wrong-size "$(px $((unit * 16 / 10)))" --wrong-color "$red" --wrong-pos "ix:iy+$(px $((ring + unit * 9)))" \
  --modif-color "$dim" --modif-pos "ix:iy+$(px $((ring + unit * 12)))" \
  --noinput-text "" --lock-text "" \
  --nofork "$@" &
locker=$!
# xss-lock holds sleep until its lock fd closes; i3lock closes its copy once the screen is locked, so this
# script lets go of its own or sleep would wait for the unlock.
[[ -n ${XSS_SLEEP_LOCK_FD:-} ]] && eval "exec ${XSS_SLEEP_LOCK_FD}<&-"
wait "$locker"

[[ $paused == true ]] || dunstctl set-paused false 2>/dev/null
