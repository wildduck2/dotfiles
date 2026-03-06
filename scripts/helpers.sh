#!/usr/bin/env bash
#
# Shared helper functions for setup scripts.
# Source this file, do not execute it directly.
#

# -- Colors ----------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Disable colors when not interactive (piped output, CI, etc.)
if [[ ! -t 1 ]]; then
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' DIM='' NC=''
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# -- Logging ---------------------------------------------------------------
info()   { printf "🦆 ${BLUE}[INFO]${NC}  %s\n" "$*"; }
ok()     { printf "🦆 ${GREEN}[ OK ]${NC}  %s\n" "$*"; }
warn()   { printf "🦆 ${YELLOW}[WARN]${NC}  %s\n" "$*"; }
err()    { printf "🦆 ${RED}[ERR]${NC}   %s\n" "$*"; }
header() { printf "\n🦆 ${BOLD}-- %s --${NC}\n" "$*"; }
step()   { printf "   ${DIM} ->  %s${NC}\n" "$*"; }

# -- Entertainment (shown during long waits) -------------------------------
_DUCK_QUOTES=(
  "A wise duck once said: 'Quack first, debug later.'"
  "Roses are red, violets are blue, your dotfiles are stowed, and configs are too."
  "Fun fact: the average duck can fly at 50 mph. This install is almost that fast."
  "While you wait... did you know ducks have three eyelids?"
  "Compiling patience... ████████░░ 80%"
  "Pro tip: stretch your legs. Ducks never skip leg day."
  "Why do ducks make great detectives? They always quack the case."
  "Installing bits and bytes... quack by quack."
  "Ducks sleep with one eye open. So should your monitoring."
  "A duck walked into a bar and said, 'Put it on my bill.'"
  "Your future self will thank you for setting this up."
  "Did you know? Ducks can surf. Seriously, they ride waves."
  "Patience is a virtue. Also, this is literally installing software."
  "In the time you're waiting, a duck has already migrated 3 miles."
  "What's a duck's favorite snack? Quackers, obviously."
)

# Print a random duck quote (for long operations)
duck_quote() {
  local idx=$((RANDOM % ${#_DUCK_QUOTES[@]}))
  printf "   ${DIM}💬 %s${NC}\n" "${_DUCK_QUOTES[$idx]}"
}

# Show a time estimate with entertainment
# Usage: duck_wait "Installing packages" "~30s"
duck_wait() {
  local task="$1"
  local estimate="${2:-a moment}"
  info "$task (estimated: $estimate)"
  duck_quote
}

command_exists() { command -v "$1" &>/dev/null; }

# -- Pre-flight checks ----------------------------------------------------

# Verify Arch Linux (only once per session)
check_arch() {
  if [[ "${_ARCH_CHECKED:-}" == "1" ]]; then return 0; fi
  if ! command_exists pacman; then
    err "This script is designed for Arch Linux (pacman required)"
    exit 1
  fi
  ok "Running on Arch Linux"
  export _ARCH_CHECKED=1
}

# Cache sudo credentials early so user only types password once
cache_sudo() {
  if [[ "${_SUDO_CACHED:-}" == "1" ]]; then return 0; fi
  info "Caching sudo credentials (you may be prompted for your password)"
  if sudo -v; then
    # Keep sudo alive in background for long installs
    (while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done) &
    export _SUDO_PID=$!
    export _SUDO_CACHED=1
    ok "Sudo credentials cached"
  else
    err "Failed to obtain sudo -- some operations will fail"
    return 1
  fi
}

# Check internet connectivity
check_internet() {
  if [[ "${_INET_CHECKED:-}" == "1" ]]; then return 0; fi
  step "Checking internet connectivity"
  if curl -sfL --connect-timeout 5 --max-time 10 https://archlinux.org >/dev/null 2>&1; then
    ok "Internet connection available"
    export _INET_CHECKED=1
  else
    warn "No internet connection detected"
    warn "Network-dependent operations (AUR, git clone, curl installs) may fail"
    return 1
  fi
}

# Verify a required command exists, exit if not
require_cmd() {
  local cmd="$1"
  local hint="${2:-}"
  if ! command_exists "$cmd"; then
    err "'$cmd' is required but not found"
    [[ -n "$hint" ]] && err "  $hint"
    exit 1
  fi
}

# -- Yay (AUR helper) installation ----------------------------------------
install_yay() {
  if command_exists yay; then
    ok "yay already installed"
    return 0
  fi
  duck_wait "Installing yay (AUR helper)" "~30-60s"
  pkg_install git base-devel
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  if git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay" && \
     cd "$tmp_dir/yay" && makepkg -si --noconfirm; then
    ok "yay installed"
    cd "$DOTFILES_DIR"
    rm -rf "$tmp_dir"
  else
    err "Failed to install yay"
    cd "$DOTFILES_DIR"
    rm -rf "$tmp_dir"
    return 1
  fi
}

# -- Safe curl wrapper ----------------------------------------------------
# Usage: safe_curl <url> [description]
# Outputs to stdout. Exits on failure.
safe_curl() {
  local url="$1"
  local desc="${2:-$url}"
  step "Downloading: $desc"
  if ! curl -fsSL --connect-timeout 15 --retry 3 --retry-delay 2 "$url"; then
    err "Failed to download: $desc"
    err "  URL: $url"
    return 1
  fi
}

# -- Package installation -------------------------------------------------

pkg_install() {
  local missing=()
  for pkg in "$@"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    return 0
  fi
  duck_wait "Installing packages: ${missing[*]}" "~10-30s"
  if ! sudo pacman -S --needed --noconfirm "${missing[@]}"; then
    err "Failed to install packages: ${missing[*]}"
    err "  Check your internet connection and pacman mirrors"
    return 1
  fi
  # Verify each package actually installed
  local failed=()
  for pkg in "${missing[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
      failed+=("$pkg")
    fi
  done
  if [[ ${#failed[@]} -gt 0 ]]; then
    err "These packages failed to install: ${failed[*]}"
    return 1
  fi
  ok "Installed: ${missing[*]}"
}

aur_install() {
  local missing=()
  for pkg in "$@"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    return 0
  fi
  if ! command_exists yay; then
    warn "yay not found -- skipping AUR packages: ${missing[*]}"
    warn "  Install yay: git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si"
    return 1
  fi
  duck_wait "Installing from AUR: ${missing[*]}" "~30-60s"
  if ! yay -S --needed --noconfirm "${missing[@]}"; then
    err "Failed to install AUR packages: ${missing[*]}"
    return 1
  fi
  ok "Installed (AUR): ${missing[*]}"
}

npm_install_global() {
  if ! command_exists npm; then
    warn "npm not found -- skipping: $*"
    return 1
  fi
  local missing=()
  for pkg in "$@"; do
    if ! npm list -g "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    return 0
  fi
  info "Installing npm packages: ${missing[*]}"
  if ! npm i -g "${missing[@]}"; then
    err "Failed to install npm packages: ${missing[*]}"
    return 1
  fi
  ok "Installed (npm): ${missing[*]}"
}

go_install() {
  local bin_name="$1"
  local pkg_path="$2"
  if ! command_exists go; then
    warn "go not found -- skipping: $bin_name"
    return 1
  fi
  if command_exists "$bin_name"; then
    ok "Go tool already installed: $bin_name"
    return 0
  fi
  info "Installing Go tool: $bin_name"
  if ! go install "$pkg_path"; then
    err "Failed to install Go tool: $bin_name"
    return 1
  fi
  ok "Installed (go): $bin_name"
}

pip_install() {
  if ! command_exists python && ! command_exists python3; then
    warn "python not found -- skipping: $*"
    return 1
  fi
  local py_cmd="python"
  command_exists python || py_cmd="python3"

  local missing=()
  for pkg in "$@"; do
    if ! $py_cmd -m pip show "$pkg" &>/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    return 0
  fi
  info "Installing pip packages: ${missing[*]}"
  if ! $py_cmd -m pip install --user --break-system-packages "${missing[@]}" 2>/dev/null; then
    if ! $py_cmd -m pip install --user "${missing[@]}"; then
      err "Failed to install pip packages: ${missing[*]}"
      return 1
    fi
  fi
  ok "Installed (pip): ${missing[*]}"
}

# -- Stow ------------------------------------------------------------------
# Stow a package. Handles both .config-based and home-level dotfiles.
# Backs up existing non-symlink targets before stowing.
stow_package() {
  local pkg="$1"
  cd "$DOTFILES_DIR"

  require_cmd stow "Install with: sudo pacman -S stow"

  # Back up any conflicting files/dirs that stow would overwrite.
  local conflicts
  conflicts=$(stow -n -R "$pkg" 2>&1 | grep "existing target" | sed 's/.*: //' || true)

  local backup_count=0
  for target in $conflicts; do
    local full="$HOME/$target"
    if [[ -e "$full" ]] && [[ ! -L "$full" ]]; then
      warn "Backing up $full -> ${full}.bak"
      mv "$full" "${full}.bak"
      backup_count=$((backup_count + 1))
    fi
  done
  [[ $backup_count -gt 0 ]] && info "$backup_count file(s) backed up (check *.bak files in \$HOME)"

  step "Stowing $pkg"
  if stow -R "$pkg"; then
    ok "Stowed $pkg"
  else
    err "Failed to stow $pkg -- check for conflicts with: stow -n -v $pkg"
    return 1
  fi
}

# -- Font check ------------------------------------------------------------
check_font() {
  local font_name="$1"
  if ! command_exists fc-list; then
    warn "fc-list not found (fontconfig) -- cannot verify font: $font_name"
    return 1
  fi
  if fc-list 2>/dev/null | grep -qi "$font_name"; then
    ok "Font found: $font_name"
    return 0
  else
    warn "Font not found: $font_name"
    return 1
  fi
}

# Check for Berkeley Mono with JetBrainsMono fallback.
# Sets PREFERRED_FONT to whichever is available.
# Usage: check_preferred_font && echo "$PREFERRED_FONT"
check_preferred_font() {
  if check_font "Berkeley Mono" 2>/dev/null; then
    PREFERRED_FONT="Berkeley Mono Trial"
    return 0
  elif check_font "JetBrainsMono Nerd Font" 2>/dev/null; then
    PREFERRED_FONT="JetBrainsMono Nerd Font"
    warn "Berkeley Mono not found -- using JetBrainsMono Nerd Font as fallback"
    warn "Place Berkeley Mono .ttf files in dotfiles/fonts/ and re-run setup"
    return 0
  else
    PREFERRED_FONT=""
    warn "No preferred font found (Berkeley Mono or JetBrainsMono)"
    warn "Install: sudo pacman -S ttf-jetbrains-mono-nerd"
    return 1
  fi
}

# -- Install bundled fonts -------------------------------------------------
install_bundled_fonts() {
  local font_dir="$DOTFILES_DIR/fonts"
  local dest="$HOME/.local/share/fonts"
  if [[ ! -d "$font_dir" ]] || [[ -z "$(ls -A "$font_dir" 2>/dev/null)" ]]; then
    return 0
  fi
  mkdir -p "$dest"
  local count=0
  for font in "$font_dir"/*.ttf "$font_dir"/*.otf; do
    [[ -f "$font" ]] || continue
    local basename
    basename="$(basename "$font")"
    if [[ ! -f "$dest/$basename" ]]; then
      cp "$font" "$dest/"
      step "Installed font: $basename"
      count=$((count + 1))
    fi
  done
  if [[ $count -gt 0 ]]; then
    fc-cache -f 2>/dev/null || true
    ok "Installed $count bundled font(s)"
  fi
}

# -- Cleanup ---------------------------------------------------------------
# Kill the sudo keepalive background process on exit
cleanup_sudo() {
  if [[ -n "${_SUDO_PID:-}" ]]; then
    kill "$_SUDO_PID" 2>/dev/null || true
  fi
}
trap cleanup_sudo EXIT
