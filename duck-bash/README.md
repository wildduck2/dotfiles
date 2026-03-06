# Duck-Bash Utility Scripts

Collection of shell utility scripts for system maintenance, git workflows, media, and screenshots.

## Quick Start

```bash
cd ~/dotfiles
./duck-bash/setup.sh
```

Scripts are stowed to `~/.config/duck-bash/`.

## Scripts

| Script | Purpose | Key Dependencies | More Info |
|--------|---------|------------------|-----------|
| `commit-message.sh` | Generate commit messages via [Hugging Face](https://huggingface.co/) API | curl, jq, git | [HF Inference API](https://huggingface.co/docs/api-inference/) |
| `docker-clean.sh` | Clean Docker containers/volumes/cache | [docker](https://docs.docker.com/) | Keeps images, removes everything else |
| `fzf-tmux.sh` | fzf-powered tmux popup/pane picker | [fzf](https://github.com/junegunn/fzf), [tmux](https://github.com/tmux/tmux) | Upstream fzf-tmux script |
| `fzf-tmux-wild-duck.sh` | Custom tmux window opener | fzf, tmux | Opens fzf directory picker in new tmux window |
| `git-push-code.sh` | Interactive git push workflow | [git](https://git-scm.com/) | Init, add, commit, push in one flow |
| `i3-block.sh` | i3lock screen trigger | [i3lock-color](https://github.com/Raymo111/i3lock-color) | Catppuccin-themed lock screen |
| `install-nvim.sh` | Install latest Neovim from GitHub | curl | [Neovim releases](https://github.com/neovim/neovim/releases) |
| `python-clean.sh` | Remove orphaned pip packages | pip, pacman | Keeps pacman-managed packages |
| `qr-with-image.sh` | Generate QR code with embedded image | [qrencode](https://fukuchi.org/works/qrencode/), [ImageMagick](https://imagemagick.org/) | Overlays image on QR center |
| `screenshot.sh` | Screenshot with selection | [flameshot](https://flameshot.org/) | Full screen, area select, or monitor |
| `sys-package-manager-clean.sh` | Clean pacman/yay caches | pacman, [paccache](https://man.archlinux.org/man/paccache.8), yay | Keeps 3 package versions |
| `system-clean.sh` | Full system cleanup | pacman, journalctl, npm, pip | Caches, orphans, journals, tmp |
| `yt-download.sh` | Download YouTube videos | [yt-dlp](https://github.com/yt-dlp/yt-dlp) | Resolution picker (1080p/720p/best) |

## Dependencies

**Installed by setup.sh:**
- [git](https://git-scm.com/), [curl](https://curl.se/), [jq](https://jqlang.github.io/jq/), [fzf](https://github.com/junegunn/fzf), [tmux](https://github.com/tmux/tmux)
- [qrencode](https://fukuchi.org/works/qrencode/), [ImageMagick](https://imagemagick.org/)
- [pacman-contrib](https://gitlab.archlinux.org/pacman/pacman-contrib) (paccache)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [libnotify](https://gitlab.gnome.org/GNOME/libnotify) (notify-send)
- [flameshot](https://flameshot.org/)

**Optional (not auto-installed):**
- [docker](https://docs.docker.com/) (only for docker-clean.sh)
