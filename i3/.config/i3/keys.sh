#!/usr/bin/env bash
# What the laptop's and the Redragon's special keys do, each followed by a popup that replaces the last one:
#   keys.sh volume +5|-5, mute, mic, brightness, kbd, profile, airplane, touchpad
# The firmware itself steps brightness, the keyboard light and the power profile, so those only report.
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
  local dev="" candidate before now percent icon=notification-display-brightness-full
  for candidate in /sys/class/backlight/*; do [[ -e $candidate ]] && dev=$candidate && break; done
  [[ -n $dev ]] || return
  # The key reaches here about when the firmware changes the level, so wait for it to land.
  before=$(<"$dev/actual_brightness")
  for _ in 1 2 3 4 5 6; do
    now=$(<"$dev/actual_brightness")
    [[ $now != "$before" ]] && break
    sleep 0.05
  done
  percent=$((now * 100 / $(<"$dev/max_brightness")))
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
brightness) brightness ;;
kbd)
  # brightness_hw_changed holds the level the keyboard's own key last set, 0 to 3.
  level=$(</sys/class/leds/asus::kbd_backlight/brightness_hw_changed)
  names=(off low medium high)
  show notification-keyboard-brightness "Keyboard light ${names[level]:-$level}" "" $((level * 100 / 3))
  ;;
profile)
  case $(</sys/firmware/acpi/platform_profile) in
  quiet) show notification-power "Quiet" "Fans low, slower" ;;
  balanced) show notification-power "Balanced" ;;
  performance) show notification-power "Performance" "Fans high, fastest" ;;
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
  echo "usage: keys.sh volume +5|-5, mute, mic, brightness, kbd, profile, airplane, touchpad" >&2
  exit 2
  ;;
esac
