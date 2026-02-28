# Arch install bootstrap

`setup.sh` is a curlable entrypoint that bootstraps required files, runs the partition planner/applicator, and optionally chains into workstation/server installers if they exist.

Usage
- Preview or apply partitions: `curl -fsSL https://raw.githubusercontent.com/wildduck2/dotfiles/main/arch-install/setup.sh | bash -s --` (interactive picker) or pass flags, e.g. `--device /dev/nvme0n1 --layout workstation`
- Apply destructive changes: append `--apply --wipe` (the partition script still prompts unless `-y` is passed).
- Run from a checkout instead: `./setup.sh --device /dev/sda --layout minimal`
- Refresh cached scripts when piping: `ARCH_INSTALL_FORCE_REFRESH=1 curl -fsSL ... | bash -s -- ...`
- Debug trace if something fails: set `ARCH_INSTALL_DEBUG=1` when running.

Behavior
- Ensures `disk/partition.sh` and `disk/layouts.sh` are present by copying from the current directory, the script location, or downloading from `ARCH_INSTALL_RAW_BASE` (default: GitHub raw).
- Uses `ARCH_INSTALL_DIR` for the working directory (default: `/tmp/wildduck-arch-install` when not already in a checkout).
- Partitioning auto-detects BIOS vs UEFI and supports swap/home layouts; see `disk/README.md` for details.
- If `--device` is omitted and a TTY is available, a menu shows disks/partitions (with size/model/mount info) and lets you choose; only TYPE=disk is accepted. If `--layout` is omitted, a preset picker is shown. Prompts use `/dev/tty` when available, so `curl ... | bash -s --` stays interactive on a console.

Optional installers
- If `install-workstation.sh` or `install-server.sh` are executable in the working directory, a menu is shown after partitioning to run them; otherwise the script exits after partitioning.
