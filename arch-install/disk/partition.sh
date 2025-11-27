#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=disk/layouts.sh
. "$SCRIPT_DIR/layouts.sh"

APPLY=false
WIPE=false
YES=false
SKIP_FORMAT=false
LAYOUT="minimal"
LAYOUT_WAS_PROVIDED=false
DEVICE=""
BIOS_BOOT_SIZE_MIB=2
TTY_INPUT="/dev/tty"

# Defaults (can be overridden by layout or CLI)
EFI_LABEL="EFI"
ROOT_LABEL="arch-root"
HOME_LABEL="home"
SWAP_LABEL="swap"

# Track user overrides to apply after layout selection
USER_BOOT_MODE=""
USER_EFI_SIZE=""
USER_SWAP_SIZE=""
USER_ROOT_SIZE=""
USER_HOME_SIZE=""
USER_ROOT_FS=""
USER_HOME_FS=""
USER_MAKE_HOME=""
USER_EFI_LABEL=""
USER_ROOT_LABEL=""
USER_HOME_LABEL=""
USER_SWAP_LABEL=""

log() {
  printf "[%s] %s\n" "$1" "$2"
}

info() { log INFO "$1"; }
warn() { log WARN "$1"; }
fail() { log ERROR "$1" >&2; exit 1; }

has_tty() {
  [[ -t 0 || -r "$TTY_INPUT" ]]
}

prompt_read() {
  local __outvar="$1"; shift
  local prompt="${1:-}"
  local input=""
  if [[ -t 0 ]]; then
    read -r -p "$prompt" input
  elif [[ -r "$TTY_INPUT" ]]; then
    read -r -p "$prompt" input < "$TTY_INPUT"
  else
    fail "No interactive input available; supply required flags."
  fi
  printf -v "$__outvar" "%s" "$input"
}

usage() {
  cat <<'EOF'
Usage: partition.sh [options]

Safely plan (default) or apply a dynamic Arch Linux disk layout.
By default the script shows the plan only; pass --apply --wipe to make changes.

Options:
  -d, --device PATH       Target disk (e.g., /dev/sda, /dev/nvme0n1)
      --layout NAME       Layout preset: minimal (default), workstation, server
      --boot-mode MODE    auto (default), uefi, bios
      --efi-size SIZE     EFI system partition size (default depends on layout)
      --swap-size SIZE    Swap size (0 disables)
      --root-size SIZE    Root size; if omitted root uses remaining space
      --home              Create a /home partition (uses remaining space)
      --home-size SIZE    Create /home with a fixed size
      --root-fs TYPE      Filesystem for root (default ext4)
      --home-fs TYPE      Filesystem for /home (default ext4)
      --efi-label NAME    Label for EFI partition
      --root-label NAME   Label for root partition
      --home-label NAME   Label for /home partition
      --swap-label NAME   Label for swap partition
      --apply             Execute destructive actions (requires --wipe)
      --wipe              Zap existing partition table before creating a new one
      --no-format         Skip mkfs/mkswap after partitioning
  -y, --yes               Do not prompt for confirmation
  -h, --help              Show this help

Examples:
  # Show the default minimal plan for a disk
  sudo ./disk/partition.sh --device /dev/nvme0n1

  # Apply workstation layout with swap/home and fixed root size
  sudo ./disk/partition.sh --device /dev/nvme0n1 --layout workstation --apply --wipe

  # BIOS install, no home partition, 2GiB swap
  sudo ./disk/partition.sh --device /dev/sda --boot-mode bios --swap-size 2GiB --apply --wipe
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command '$1' not found in PATH"
}

list_disks() {
  lsblk -dpno NAME,SIZE,TYPE,MODEL | awk '
    $3 == "disk" {
      extra = ($4 ? substr($0, index($0, $4)) : "")
      printf "  %-20s %6s  %s\n", $1, $2, extra
    }
  '
}

detect_boot_mode() {
  if [[ -d /sys/firmware/efi ]]; then
    echo "uefi"
  else
    echo "bios"
  fi
}

system_overview() {
  local boot mem cpu
  boot=$(detect_boot_mode)
  mem=$(awk '/MemTotal/ {printf "%.1f GiB", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "unknown")
  cpu=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ //')
  [[ -z "$cpu" ]] && cpu=$(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^ +| +$/,"",$2); print $2; exit}')
  [[ -z "$cpu" ]] && cpu="unknown"
  printf "\nSystem overview:\n"
  printf "  Boot mode    : %s\n" "$boot"
  printf "  CPU          : %s\n" "$cpu"
  printf "  Memory       : %s\n" "$mem"
}

partition_path() {
  local base="$1"
  local number="$2"
  if [[ "$base" =~ [0-9]$ ]]; then
    echo "${base}p${number}"
  else
    echo "${base}${number}"
  fi
}

size_to_mib() {
  local size="$1"
  [[ -z "$size" ]] && fail "Size cannot be empty"
  if [[ "$size" == "0" ]]; then
    echo 0
    return
  fi
  local bytes
  bytes=$(numfmt --from=iec "$size") || fail "Invalid size '$size'"
  echo $(( (bytes + 1048575) / 1048576 ))
}

maybe_size_to_mib() {
  local size="$1"
  [[ -z "$size" ]] && { echo ""; return; }
  size_to_mib "$size"
}

confirm() {
  local prompt="$1"
  if [[ "$YES" == true ]]; then
    return
  fi
  local reply=""
  prompt_read reply "$prompt [y/N]: "
  [[ "$reply" == "y" || "$reply" == "Y" ]] || fail "Aborted by user"
}

collect_block_entries() {
  BLOCKS=()
  while IFS= read -r line; do
    local NAME="" TYPE="" SIZE="" MODEL="" TRAN="" FSTYPE="" MOUNTPOINT=""
    # shellcheck disable=SC2086
    eval "$line"
    BLOCKS+=("$NAME|$TYPE|${SIZE:-?}|${MODEL:-?}|${TRAN:-?}|${FSTYPE:-}|${MOUNTPOINT:-}")
  done < <(lsblk -rpno NAME,TYPE,SIZE,MODEL,TRAN,FSTYPE,MOUNTPOINT -P)
}

print_block_table() {
  printf "\nDetected block devices (disks + partitions):\n"
  printf "  %-3s %-20s %-6s %-10s %-7s %-18s %s\n" "#" "Path" "Type" "Size" "Bus" "Model" "Mount/FSType"
  printf "  %-3s %-20s %-6s %-10s %-7s %-18s %s\n" "---" "--------------------" "------" "----------" "-------" "------------------" "-------------------------"
  local idx=0
  for entry in "${BLOCKS[@]}"; do
    idx=$((idx + 1))
    IFS="|" read -r path type size model tran fstype mount <<< "$entry"
    local mountinfo="$mount"
    [[ -n "$fstype" ]] && mountinfo="${mountinfo:+$mountinfo }(${fstype})"
    printf "  %-3s %-20s %-6s %-10s %-7s %-18s %s\n" "$idx" "$path" "$type" "$size" "${tran:-?}" "${model:-?}" "${mountinfo:--}"
  done
  printf "  Note: choose TYPE=disk for full partitioning. Mounted devices will be wiped if you apply.\n"
}

select_device_interactive() {
  system_overview
  collect_block_entries
  [[ "${#BLOCKS[@]}" -gt 0 ]] || fail "No block devices found."
  print_block_table
  local choice
  prompt_read choice $'\nSelect target (number or path), or leave empty to abort: '
  [[ -n "$choice" ]] || fail "No device selected."

  local target_path="" target_type="" mountinfo=""
  if [[ "$choice" =~ ^[0-9]+$ ]]; then
    local idx="$choice"
    if (( idx < 1 || idx > ${#BLOCKS[@]} )); then
      fail "Selection out of range."
    fi
    IFS="|" read -r target_path target_type _ _ _ _ mountinfo <<< "${BLOCKS[$((idx-1))]}"
  else
    target_path="$choice"
    target_type=$(lsblk -ndo TYPE "$target_path" 2>/dev/null || true)
    mountinfo=$(lsblk -ndo MOUNTPOINT "$target_path" 2>/dev/null || true)
  fi

  [[ -n "$target_path" ]] || fail "Could not resolve device."
  if [[ "$target_type" != "disk" ]]; then
    fail "Selected target '$target_path' is TYPE='$target_type'. Full partitioning requires a whole disk."
  fi

  if [[ -n "$mountinfo" ]]; then
    warn "Target has mounted partitions: $mountinfo"
  fi

  DEVICE="$target_path"
  info "Selected disk: $DEVICE"
}

select_layout_interactive() {
  printf "\nPartition layout presets:\n"
  local layouts
  layouts=$(list_layouts)
  local idx=0
  for name in $layouts; do
    idx=$((idx + 1))
    printf "  %d) %-12s - %s\n" "$idx" "$name" "$(layout_description "$name")"
  done
  local choice
  prompt_read choice "Select layout [${LAYOUT}]: "
  if [[ -z "$choice" ]]; then
    info "Using default layout: $LAYOUT"
    return
  fi
  if [[ "$choice" =~ ^[0-9]+$ ]]; then
    local idx_choice="$choice"
    local sel=""
    local i=0
    for name in $layouts; do
      i=$((i + 1))
      if [[ "$i" -eq "$idx_choice" ]]; then
        sel="$name"; break
      fi
    done
    [[ -n "$sel" ]] || fail "Invalid layout selection."
    LAYOUT="$sel"
  else
    LAYOUT="$choice"
  fi
  info "Selected layout: $LAYOUT"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--device)
        DEVICE="${2:-}"; shift 2;;
      --layout)
        LAYOUT="${2:-}"; LAYOUT_WAS_PROVIDED=true; shift 2;;
      --boot-mode)
        USER_BOOT_MODE="${2:-}"; shift 2;;
      --efi-size)
        USER_EFI_SIZE="${2:-}"; shift 2;;
      --swap-size)
        USER_SWAP_SIZE="${2:-}"; shift 2;;
      --root-size)
        USER_ROOT_SIZE="${2:-}"; shift 2;;
      --home)
        USER_MAKE_HOME=true; shift;;
      --home-size)
        USER_MAKE_HOME=true
        USER_HOME_SIZE="${2:-}"; shift 2;;
      --root-fs)
        USER_ROOT_FS="${2:-}"; shift 2;;
      --home-fs)
        USER_HOME_FS="${2:-}"; shift 2;;
      --efi-label)
        USER_EFI_LABEL="${2:-}"; shift 2;;
      --root-label)
        USER_ROOT_LABEL="${2:-}"; shift 2;;
      --home-label)
        USER_HOME_LABEL="${2:-}"; shift 2;;
      --swap-label)
        USER_SWAP_LABEL="${2:-}"; shift 2;;
      --no-home)
        USER_MAKE_HOME=false; USER_HOME_SIZE=""; shift;;
      --apply)
        APPLY=true; shift;;
      --wipe)
        WIPE=true; shift;;
      --no-format)
        SKIP_FORMAT=true; shift;;
      -y|--yes)
        YES=true; shift;;
      -h|--help)
        usage; exit 0;;
      --)
        shift; break;;
      *)
        fail "Unknown argument: $1"
        ;;
    esac
  done
}

apply_overrides() {
  apply_layout "$LAYOUT"
  [[ -n "$USER_BOOT_MODE" ]] && BOOT_MODE="$USER_BOOT_MODE"
  [[ -n "$USER_EFI_SIZE" ]] && EFI_SIZE="$USER_EFI_SIZE"
  [[ -n "$USER_SWAP_SIZE" ]] && SWAP_SIZE="$USER_SWAP_SIZE"
  [[ -n "$USER_ROOT_SIZE" ]] && ROOT_SIZE="$USER_ROOT_SIZE"
  [[ -n "$USER_HOME_SIZE" ]] && HOME_SIZE="$USER_HOME_SIZE"
  [[ -n "$USER_ROOT_FS" ]] && ROOT_FS="$USER_ROOT_FS"
  [[ -n "$USER_HOME_FS" ]] && HOME_FS="$USER_HOME_FS"
  [[ -n "$USER_EFI_LABEL" ]] && EFI_LABEL="$USER_EFI_LABEL"
  [[ -n "$USER_ROOT_LABEL" ]] && ROOT_LABEL="$USER_ROOT_LABEL"
  [[ -n "$USER_HOME_LABEL" ]] && HOME_LABEL="$USER_HOME_LABEL"
  [[ -n "$USER_SWAP_LABEL" ]] && SWAP_LABEL="$USER_SWAP_LABEL"
  [[ -n "$USER_MAKE_HOME" ]] && MAKE_HOME="$USER_MAKE_HOME"
}

validate_inputs() {
  [[ -b "$DEVICE" ]] || fail "Device '$DEVICE' not found or not a block device"
  local dtype
  dtype=$(lsblk -ndo TYPE "$DEVICE" 2>/dev/null || true)
  [[ "$dtype" == "disk" ]] || fail "Target must be a whole disk (TYPE=disk); got '$dtype'"
  if [[ "$APPLY" == true && "$WIPE" == false ]]; then
    fail "--apply is destructive; re-run with --wipe to acknowledge the wipe"
  fi
  if [[ "$APPLY" == true ]]; then
    [[ "$(id -u)" -eq 0 ]] || fail "Run with sudo/root to partition disks"
  fi

  if [[ "$MAKE_HOME" == true && -z "$ROOT_SIZE" && -z "$HOME_SIZE" ]]; then
    fail "When enabling --home, set --root-size or --home-size to reserve space for /home"
  fi
  if [[ -n "$ROOT_SIZE" && "$ROOT_SIZE" == "0" ]]; then
    fail "--root-size cannot be zero"
  fi
  if [[ "$MAKE_HOME" == true && -n "$HOME_SIZE" && "$HOME_SIZE" == "0" ]]; then
    fail "--home-size cannot be zero"
  fi
}

collect_device_if_needed() {
  if [[ -n "$DEVICE" ]]; then
    return
  fi
  if has_tty; then
    select_device_interactive
  else
    fail "No --device provided and stdin is not interactive."
  fi
}

print_plan() {
  local boot="$1"
  local total="$2"
  echo
  info "Target device: $DEVICE"
  info "Boot mode: $boot"
  info "Disk size (MiB): $total"
  info "Layout: $LAYOUT"
  if [[ "$MAKE_HOME" == true ]]; then
    info "Home partition: enabled"
  else
    info "Home partition: disabled"
  fi
  if [[ "$SKIP_FORMAT" == true ]]; then
    info "Formatting: skipped"
  else
    info "Formatting: mkfs/mkswap enabled"
  fi
  echo
  printf "%-4s %-12s %-10s %-12s %-18s %s\n" "#" "Role" "FS" "Label" "Start-End" "Flags/Notes"
  printf "%-4s %-12s %-10s %-12s %-18s %s\n" "--" "------------" "--------" "------------" "------------------" "-------------------------"
  for entry in "${PARTITIONS[@]}"; do
    IFS="|" read -r num role fs label start end flags <<< "$entry"
    printf "%-4s %-12s %-10s %-12s %-18s %s\n" "$num" "$role" "$fs" "$label" "$start-$end" "$flags"
  done
  echo
  if [[ "$APPLY" == false ]]; then
    info "Dry-run only. Re-run with --apply --wipe to make these changes."
  else
    warn "This will ERASE data on $DEVICE"
  fi
}

build_plan() {
  PARTITIONS=()
  PARTED_CMDLINE=("$DEVICE" "--script" "--align" "optimal")
  FORMAT_ACTIONS=()

  local total_bytes
  total_bytes=$(blockdev --getsize64 "$DEVICE") || fail "Unable to read size for $DEVICE"
  local total_mib=$(( (total_bytes + 1048575) / 1048576 ))

  local boot_mode="$BOOT_MODE"
  if [[ "$boot_mode" == "auto" ]]; then
    boot_mode=$(detect_boot_mode)
  fi

  local efi_size_mib swap_size_mib root_size_mib home_size_mib
  efi_size_mib=$(size_to_mib "$EFI_SIZE")
  swap_size_mib=$(size_to_mib "$SWAP_SIZE")
  root_size_mib=$(maybe_size_to_mib "$ROOT_SIZE")
  home_size_mib=$(maybe_size_to_mib "$HOME_SIZE")
  if [[ "$boot_mode" == "uefi" && "$efi_size_mib" -le 0 ]]; then
    fail "EFI size must be greater than zero for UEFI installs"
  fi

  local start_mib=1
  local partnum=0
  PARTED_CMDLINE+=("mklabel" "gpt")

  add_partition() {
    local role="$1" fs="$2" label="$3" start="$4" end="$5" flags="$6" mkfs_allowed="$7"
    local part_type="primary"
    partnum=$((partnum + 1))
    PARTITIONS+=("$partnum|$role|$fs|$label|$start|$end|$flags")
    if [[ -n "$fs" && "$fs" != "-" ]]; then
      FORMAT_ACTIONS+=("$partnum|$fs|$label|$mkfs_allowed")
    fi
    if [[ -n "$fs" && "$fs" != "-" ]]; then
      PARTED_CMDLINE+=("mkpart" "$part_type" "$fs" "$start" "$end")
    else
      PARTED_CMDLINE+=("mkpart" "$part_type" "$start" "$end")
    fi
    PARTED_CMDLINE+=("name" "$partnum" "$label")
    if [[ -n "$flags" ]]; then
      IFS="," read -r -a parts <<< "$flags"
      for flag in "${parts[@]}"; do
        PARTED_CMDLINE+=("set" "$partnum" "$flag" "on")
      done
    fi
  }

  if [[ "$boot_mode" == "bios" ]]; then
    local bios_end=$((start_mib + BIOS_BOOT_SIZE_MIB))
    add_partition "bios-boot" "" "bios-boot" "${start_mib}MiB" "${bios_end}MiB" "bios_grub" "false"
    start_mib=$bios_end
  else
    local efi_end=$((start_mib + efi_size_mib))
    add_partition "efi" "fat32" "$EFI_LABEL" "${start_mib}MiB" "${efi_end}MiB" "esp,boot" "true"
    start_mib=$efi_end
  fi

  if (( swap_size_mib > 0 )); then
    local swap_end=$((start_mib + swap_size_mib))
    add_partition "swap" "linux-swap" "$SWAP_LABEL" "${start_mib}MiB" "${swap_end}MiB" "" "true"
    start_mib=$swap_end
  fi

  if [[ "$MAKE_HOME" == true ]]; then
    local root_end_mib
    if [[ -n "$root_size_mib" ]]; then
      root_end_mib=$((start_mib + root_size_mib))
    else
      local reserve=${home_size_mib:-0}
      root_end_mib=$((total_mib - reserve))
    fi
    (( root_end_mib > start_mib )) || fail "Calculated root partition is too small"
    local root_end="${root_end_mib}MiB"
    add_partition "root" "$ROOT_FS" "$ROOT_LABEL" "${start_mib}MiB" "$root_end" "" "true"
    start_mib=$root_end_mib

    local home_end
    if [[ -n "$home_size_mib" ]]; then
      local home_end_mib=$((start_mib + home_size_mib))
      (( home_end_mib <= total_mib )) || fail "Home size exceeds disk capacity"
      home_end="${home_end_mib}MiB"
    else
      home_end="100%"
    fi
    add_partition "home" "$HOME_FS" "$HOME_LABEL" "${start_mib}MiB" "$home_end" "" "true"
  else
    local root_end
    if [[ -n "$root_size_mib" ]]; then
      root_end="$((start_mib + root_size_mib))MiB"
    else
      root_end="100%"
    fi
    add_partition "root" "$ROOT_FS" "$ROOT_LABEL" "${start_mib}MiB" "$root_end" "" "true"
  fi

  print_plan "$boot_mode" "$total_mib"
}

apply_changes() {
  if [[ "$APPLY" == false ]]; then
    return
  fi

  confirm "Proceed with partitioning $DEVICE? THIS WILL WIPE DATA"

  if [[ "$WIPE" == true ]]; then
    info "Wiping existing signatures on $DEVICE"
    wipefs -a "$DEVICE"
  fi

  info "Running parted to apply layout..."
  parted "${PARTED_CMDLINE[@]}"

  if [[ "$SKIP_FORMAT" == true ]]; then
    info "Skipping filesystem creation as requested"
    return
  fi

  require_cmd mkfs.ext4
  require_cmd mkfs.vfat
  require_cmd mkswap

  for entry in "${FORMAT_ACTIONS[@]}"; do
    IFS="|" read -r num fs label allowed <<< "$entry"
    [[ "$allowed" == "true" ]] || continue
    local part_path
    part_path=$(partition_path "$DEVICE" "$num")
    case "$fs" in
      fat32)
        info "Formatting $part_path as FAT32 (label: $label)"
        mkfs.vfat -F32 -n "$label" "$part_path"
        ;;
      linux-swap)
        info "Creating swap on $part_path (label: $label)"
        mkswap -L "$label" "$part_path"
        ;;
      ext4)
        info "Formatting $part_path as ext4 (label: $label)"
        mkfs.ext4 -F -L "$label" "$part_path"
        ;;
      *)
        warn "Skipping format for $part_path (unsupported fs '$fs')"
        ;;
    esac
  done
}

main() {
  require_cmd lsblk
  require_cmd numfmt
  require_cmd blockdev
  require_cmd parted

  parse_args "$@"
  if [[ "$LAYOUT_WAS_PROVIDED" == false ]] && has_tty; then
    select_layout_interactive
  fi
  collect_device_if_needed
  apply_overrides
  validate_inputs
  build_plan
  apply_changes
}

main "$@"
