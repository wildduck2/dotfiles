#!/usr/bin/env bash
set -euo pipefail

# Bootstrapper for disk partitioning and (optionally) post-partition installs.
# Designed to be curlable: curl -fsSL https://.../arch-install/setup.sh | bash -s -- [partition args]

RAW_BASE="${ARCH_INSTALL_RAW_BASE:-https://raw.githubusercontent.com/wildduck2/dotfiles/main/arch-install}"
DEFAULT_WORK_DIR="/tmp/wildduck-arch-install"
WORK_DIR="${ARCH_INSTALL_DIR:-}"
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
SCRIPT_DIR=""
[[ -f "$SCRIPT_PATH" ]] && SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

info() { printf "[INFO] %s\n" "$*"; }
warn() { printf "[WARN] %s\n" "$*" >&2; }
fail() { printf "[ERROR] %s\n" "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

resolve_workdir() {
  if [[ -z "$WORK_DIR" ]]; then
    if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/disk" ]]; then
      WORK_DIR="$SCRIPT_DIR"
    elif [[ -d "$(pwd)/disk" ]]; then
      WORK_DIR="$(pwd)"
    else
      WORK_DIR="$DEFAULT_WORK_DIR"
    fi
  fi
  mkdir -p "$WORK_DIR"
  info "Using working directory: $WORK_DIR"
}

fetch_or_copy() {
  local rel="$1"
  local dest="$WORK_DIR/$rel"
  local dest_dir
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"

  if [[ -n "${ARCH_INSTALL_FORCE_REFRESH:-}" && -f "$dest" ]]; then
    info "Refreshing $rel (ARCH_INSTALL_FORCE_REFRESH set)"
    rm -f "$dest"
  fi

  if [[ -f "$dest" ]]; then
    return
  fi

  if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/$rel" ]]; then
    cp "$SCRIPT_DIR/$rel" "$dest"
    return
  fi

  if [[ -f "$(pwd)/$rel" ]]; then
    cp "$(pwd)/$rel" "$dest"
    return
  fi

  require_cmd curl
  local url="${RAW_BASE%/}/$rel"
  info "Downloading $rel from $url"
  curl -fsSL "$url" -o "$dest" || fail "Failed to download $rel from $url"
}

ensure_disk_scripts() {
  fetch_or_copy "disk/layouts.sh"
  fetch_or_copy "disk/partition.sh"
  chmod +x "$WORK_DIR/disk/partition.sh" "$WORK_DIR/disk/layouts.sh"
}

run_partition() {
  info "Starting partitioning workflow (BIOS/UEFI auto-detected)."
  bash "$WORK_DIR/disk/partition.sh" "$@"
}

run_install_menu_if_present() {
  local workstation="$WORK_DIR/install-workstation.sh"
  local server="$WORK_DIR/install-server.sh"

  if [[ ! -x "$workstation" && ! -x "$server" ]]; then
    info "No install scripts found; partitioning only."
    return
  fi

  printf "\n"
  printf "===============================================\n"
  printf "           WildDuck Installation Menu\n"
  printf "===============================================\n\n"

  if [[ -x "$workstation" ]]; then
    printf "  1. Full Workstation Setup\n"
  fi
  if [[ -x "$server" ]]; then
    printf "  2. Server Setup\n"
  fi
  printf "  0. Exit\n\n"
  printf "Enter your choice: "

  read -r choice
  case "$choice" in
    1)
      [[ -x "$workstation" ]] || fail "Workstation installer missing."
      bash "$workstation"
      ;;
    2)
      [[ -x "$server" ]] || fail "Server installer missing."
      bash "$server"
      ;;
    0)
      info "Finished after partitioning."
      ;;
    *)
      fail "Invalid selection."
      ;;
  esac
}

main() {
  resolve_workdir
  ensure_disk_scripts
  run_partition "$@"
  run_install_menu_if_present
}

main "$@"
