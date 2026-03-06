# Duck-Bash Utility Scripts

Collection of shell utility scripts for system maintenance, git workflows, media, and screenshots.

## Quick Start

```bash
cd ~/dotfiles
./duck-bash/setup.sh
```

Scripts are stowed to `~/.config/duck-bash/`.

## Scripts

| Script | Purpose | Key Dependencies |
|--------|---------|------------------|
| `commit-message.sh` | Generate commit messages via API | curl, jq, git |
| `docker-clean.sh` | Clean Docker images/containers/volumes | docker |
| `fzf-tmux.sh` | fzf-powered tmux session picker | fzf, tmux |
| `fzf-tmux-wild-duck.sh` | Custom tmux sessionizer | fzf, tmux |
| `git-push-code.sh` | Git push workflow helper | git |
| `i3-block.sh` | i3 lock screen trigger | i3lock |
| `install-nvim.sh` | Install/update Neovim from release | wget, tar, ripgrep, fd |
| `python-clean.sh` | Remove orphaned pip packages | pip, pacman |
| `qr-with-image.sh` | Generate QR code with embedded image | qrencode, imagemagick |
| `screenshot.sh` | Screenshot with annotation | grimblast, swappy, notify-send |
| `sys-package-manager-clean.sh` | Clean pacman/yay caches | pacman, paccache, yay |
| `system-clean.sh` | Full system cleanup | pacman, journalctl, npm, pip |
| `yt-download.sh` | Download YouTube videos | yt-dlp |

## Dependencies

**Installed by setup.sh:**
- git, curl, jq, fzf, tmux
- qrencode, imagemagick
- pacman-contrib (paccache)
- yt-dlp
- libnotify (notify-send)

**Optional (not auto-installed):**
- docker (only for docker-clean.sh)
- grimblast, swappy, hyprshade (Hyprland screenshot tools -- screenshot.sh)
