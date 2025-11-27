#!/usr/bin/env bash

# Default layout values are applied in partition.sh and can be overridden
# by CLI flags. All sizes accept IEC suffixes (e.g., 512MiB, 4GiB).

reset_layout_defaults() {
  BOOT_MODE="auto"
  EFI_SIZE="512MiB"
  SWAP_SIZE="0"
  ROOT_SIZE=""
  MAKE_HOME=false
  HOME_SIZE=""
  ROOT_FS="ext4"
  HOME_FS="ext4"
}

apply_layout() {
  local layout="${1:-minimal}"
  reset_layout_defaults

  case "$layout" in
    minimal)
      # Root-only layout (UEFI/BIOS autodetected), no swap/home partitions.
      ;;
    workstation)
      # Separate /home, generous swap, fixed root size.
      SWAP_SIZE="8GiB"
      ROOT_SIZE="40GiB"
      MAKE_HOME=true
      HOME_SIZE=""
      ;;
    server)
      # Small swap, root consumes the remainder.
      SWAP_SIZE="2GiB"
      ;;
    *)
      echo "error: unknown layout '$layout'" >&2
      return 1
      ;;
  esac
}

list_layouts() {
  echo "minimal workstation server"
}
