#!/usr/bin/env bash
# The built-in mic is a digital mic on the AMD audio coprocessor. Its driver (snd-soc-acp6x-mach) only starts on
# laptops in its model list, and the G614FR is not in it, so this adds it and keeps the driver built with DKMS.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Built-in microphone"
check_arch
pkg_install dkms linux-headers curl

NAME=acp6x-mic
VERSION=1
kernel=$(uname -r)
tag=v${kernel%%-*}
tag=${tag%.0}
url=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/sound/soc/amd/yc

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
step "Fetching the driver source for $tag"
for f in acp6x-mach.c acp6x.h acp6x_chip_offset_byte.h; do
  curl -fsSL --connect-timeout 15 --retry 3 -o "$work/$f" "$url/$f?h=$tag"
done

c="$work/acp6x-mach.c"
entry=$'\t{\n\t\t.driver_data = &acp6x_card,\n\t\t.matches = {\n\t\t\tDMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK COMPUTER INC."),\n\t\t\tDMI_MATCH(DMI_PRODUCT_NAME, "G614FR"),\n\t\t}\n\t},'
if ! grep -q '"G614FR"' "$c"; then
  awk -v entry="$entry" '{ print } /^static const struct dmi_system_id yc_acp_quirk_table\[\] = \{$/ { print entry }' "$c" >"$c.new"
  mv "$c.new" "$c"
fi
# A firmware that answers "no wake-on-voice" would stop the driver before the model list is read.
sed -i 's/^\t\tif (!wov_en)$/\t\tif (!wov_en \&\& !dmi_first_match(yc_acp_quirk_table))/' "$c"
if ! grep -q '"G614FR"' "$c" || ! grep -q 'wov_en && !dmi_first_match' "$c"; then
  err "The driver source for $tag has changed shape; nothing was installed"
  exit 1
fi
printf 'obj-m := snd-soc-acp6x-mach.o\nsnd-soc-acp6x-mach-y := acp6x-mach.o\n' >"$work/Makefile"
cat >"$work/dkms.conf" <<EOF
PACKAGE_NAME="$NAME"
PACKAGE_VERSION="$VERSION"
BUILT_MODULE_NAME[0]="snd-soc-acp6x-mach"
DEST_MODULE_LOCATION[0]="/updates/dkms"
AUTOINSTALL="yes"
EOF

step "Building the driver with DKMS"
sudo dkms remove "$NAME/$VERSION" --all &>/dev/null || true
sudo rm -rf "/usr/src/$NAME-$VERSION"
sudo install -d "/usr/src/$NAME-$VERSION"
sudo install -m644 "$work"/acp6x-mach.c "$work"/acp6x.h "$work"/acp6x_chip_offset_byte.h "$work"/Makefile \
  "$work"/dkms.conf "/usr/src/$NAME-$VERSION/"
sudo dkms add "$NAME/$VERSION"
sudo dkms install "$NAME/$VERSION" -k "$kernel"

step "Loading it"
sudo modprobe -r snd_soc_acp6x_mach || true
sudo modprobe snd_soc_acp6x_mach
sleep 2
if ! arecord -l | grep -q acp6x; then
  err "The driver loaded but no mic appeared; its messages:"
  sudo dmesg | grep -iE 'acp_yc|acp6x' | tail -5
  exit 1
fi

# The analog input it replaces as the default is the headset jack, silent with nothing plugged in.
source=$(pactl list short sources 2>/dev/null | awk '$2 ~ /acp_yc_mach|acp6x/ { print $2; exit }')
if [ -n "$source" ]; then
  pactl set-default-source "$source"
  ok "The built-in mic works and is the default input"
else
  ok "The built-in mic works; pick it as the input in pavucontrol"
fi
