# Arch install bootstrap

`setup.sh` is a curlable entrypoint that bootstraps required files, runs the partition planner/applicator, and optionally chains into workstation/server installers if they exist.

Usage
- Preview or apply partitions: `curl -fsSL https://raw.githubusercontent.com/wildduck2/dotfiles/main/arch-install/setup.sh | bash -s -- --device /dev/nvme0n1 --layout workstation`
- Apply destructive changes: append `--apply --wipe` (the partition script still prompts unless `-y` is passed).
- Run from a checkout instead: `./setup.sh --device /dev/sda --layout minimal`

Behavior
- Ensures `disk/partition.sh` and `disk/layouts.sh` are present by copying from the current directory, the script location, or downloading from `ARCH_INSTALL_RAW_BASE` (default: GitHub raw).
- Uses `ARCH_INSTALL_DIR` for the working directory (default: `/tmp/wildduck-arch-install` when not already in a checkout).
- Partitioning auto-detects BIOS vs UEFI and supports swap/home layouts; see `disk/README.md` for details.

Optional installers
- If `install-workstation.sh` or `install-server.sh` are executable in the working directory, a menu is shown after partitioning to run them; otherwise the script exits after partitioning.
