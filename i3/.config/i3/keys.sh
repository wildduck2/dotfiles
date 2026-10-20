#!/usr/bin/env bash
# What the laptop's and the Redragon's special keys do, each followed by a popup that replaces the last one:
#   keys.sh volume +5|-5, mute, mic, brightness +5|-5, kbd, profile, airplane, touchpad
# The firmware itself steps the keyboard light and the power profile, so those only report.
set -uo pipefail

show() {
  local args=(-a osd -u low -t 1500 -i "$1" -h string:x-dunst-stack-tag:osd)
  [[ -n ${4:-} ]] && args+=(-h "int:value:$4")
  notify-send "${args[@]}" "$2" "${3:-}"
}

# The port in use ("Speakers", "Headphones") reads better than the card's long name; a Bluetooth headset has
# no ports and keeps its own name.
described() {
  pactl -f json list "$1" | jq -r --arg name "$(pactl "get-default-${1%s}")" '.[] | select(.name == $name)
    | (.active_port as $port | .ports[]? | select(.name == $port) | .description) // .description' | head -1
}

# wpctl prints "Volume: 0.45", with " [MUTED]" after it while muted.
level() { awk '{ printf "%d", $2 * 100 + 0.5 }' <<<"$1"; }

speaker() {
  local state percent icon=notification-audio-volume-high
  state=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
  percent=$(level "$state")
  ((percent < 66)) && icon=notification-audio-volume-medium
  ((percent < 33)) && icon=notification-audio-volume-low
  if [[ $state == *MUTED* ]]; then
    show notification-audio-volume-muted "Muted" "$(described sinks)" "$percent"
  else
    show "$icon" "Volume $percent%" "$(described sinks)" "$percent"
  fi
}

brightness() {
  local dev="" candidate max next percent icon=notification-display-brightness-full
  for candidate in /sys/class/backlight/*; do [[ -e $candidate ]] && dev=$candidate && break; done
  [[ -n $dev ]] || return
  max=$(<"$dev/max_brightness")
  next=$(($(<"$dev/actual_brightness") + max * $1 / 100))
  # Never fully dark: a black screen leaves nothing to find the key by.
  ((next < 1)) && next=1
  ((next > max)) && next=$max
  # logind lets the session's own user write it. This panel applies the level and still answers with an
  # error, so the popup shows the level read back rather than trusting the answer.
  busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session \
    SetBrightness ssu backlight "$(basename "$dev")" "$next" >/dev/null 2>&1
  percent=$(($(<"$dev/actual_brightness") * 100 / max))
  ((percent < 75)) && icon=notification-display-brightness-high
  ((percent < 50)) && icon=notification-display-brightness-medium
  ((percent < 25)) && icon=notification-display-brightness-low
  show "$icon" "Brightness $percent%" "" "$percent"
}

case ${1:-} in
volume)
  if [[ ${2:-+5} == -* ]]; then wpctl set-volume @DEFAULT_AUDIO_SINK@ "${2#-}%-"
  else wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${2#+}%+"; fi
  speaker
  ;;
mute)
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  speaker
  ;;
mic)
  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
  if [[ $(wpctl get-volume @DEFAULT_AUDIO_SOURCE@) == *MUTED* ]]; then
    show notification-microphone-sensitivity-muted "Microphone off" "$(described sources)"
  else
    show notification-microphone-sensitivity-high "Microphone on" "$(described sources)"
  fi
  ;;
brightness) brightness "${2:-+5}" ;;
kbd)
  # brightness_hw_changed holds the level the keyboard's own key last set, 0 to 3.
  level=$(</sys/class/leds/asus::kbd_backlight/brightness_hw_changed)
  names=(off low medium high)
  show notification-keyboard-brightness "Keyboard light ${names[level]:-$level}" "" $((level * 100 / 3))
  ;;
profile)
  case $(</sys/firmware/acpi/platform_profile) in
  quiet) show "$HOME/.config/i3/icons/profile-quiet.svg" "Quiet" "Fans low, slower" ;;
  balanced) show "$HOME/.config/i3/icons/profile-balanced.svg" "Balanced" "Fans and speed in between" ;;
  performance) show "$HOME/.config/i3/icons/profile-performance.svg" "Performance" "Fans high, fastest" ;;
  *) show notification-power "$(</sys/firmware/acpi/platform_profile)" ;;
  esac
  ;;
airplane)
  if rfkill -n -o SOFT | grep -qx unblocked; then
    rfkill block all && show notification-network-wireless-disconnected "Airplane mode on" "Wi-Fi and Bluetooth off"
  else
    rfkill unblock all && show notification-network-wireless "Airplane mode off" "Wi-Fi and Bluetooth on"
  fi
  ;;
touchpad)
  # By id: a disabled device is listed as "∼ <name>", which no longer matches its name.
  pad=$(xinput list | grep -i -m1 touchpad | sed -n 's/.*id=\([0-9]*\).*/\1/p')
  if [[ $(xinput list-props "$pad" | awk -F: '/Device Enabled/ { gsub(/[ \t]/, "", $2); print $2 }') == 1 ]]; then
    xinput disable "$pad" && show input-touchpad-off "Touchpad off"
  else
    xinput enable "$pad" && show input-touchpad-on "Touchpad on"
  fi
  ;;
*)
  echo "usage: keys.sh volume +5|-5, mute, mic, brightness +5|-5, kbd, profile, airplane, touchpad" >&2
  exit 2
  ;;
esac
