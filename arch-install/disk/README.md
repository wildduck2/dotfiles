# Arch disk partitioning

Scripts in this folder plan and apply a GPT layout for Arch installs without hardcoding device names or sizes.

Files
- `disk/partition.sh`: entrypoint that prints a plan by default; add `--apply --wipe` to make changes.
- `disk/layouts.sh`: presets for minimal, workstation, and server defaults.

Safety
- Runs in dry-run mode unless `--apply` is supplied; `--wipe` is required to avoid accidental execution.
- Prompts before destructive steps unless `-y/--yes` is used.
- Requires root when applying changes; intended for installer/Live USB environments.
- Uses `parted`, `wipefs`, `mkfs.ext4`, `mkfs.vfat`, `mkswap`, `lsblk`, `numfmt`, and `blockdev`.

Layouts
- `minimal` (default): UEFI/BIOS autodetect, 512MiB EFI (UEFI) or bios_grub (BIOS), no swap/home, root consumes the remainder.
- `workstation`: 512MiB EFI, 8GiB swap, 40GiB root, remainder to `/home`.
- `server`: 512MiB EFI, 2GiB swap, root consumes the remainder.

Quick start
- Preview a plan: `sudo ./disk/partition.sh --device /dev/nvme0n1`
- Apply a preset: `sudo ./disk/partition.sh --device /dev/nvme0n1 --layout workstation --apply --wipe`
- BIOS-only install: `sudo ./disk/partition.sh --device /dev/sda --boot-mode bios --swap-size 2GiB --apply --wipe`
- Skip formatting (only partition table creation): add `--no-format`

Interactive mode
- If `--device` is omitted and stdin is a TTY, a menu lists disks/partitions with size/model/mount info and prompts for selection; only TYPE=disk is accepted.
- If `--layout` is not supplied, a preset picker is shown with descriptions (minimal/workstation/server).
- Prompts read from `/dev/tty` when possible so `curl ... | bash -s --` can still be interactive on a real console.
