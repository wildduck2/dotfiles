# ani-cli Configuration

[ani-cli](https://github.com/pystardust/ani-cli) streams and downloads anime from the terminal, played in mpv.

## Quick Start

```bash
cd ~/dotfiles
./ani-cli/setup.sh
```

Then run `ani-cli` in a new shell.

## Settings

ani-cli has no config file, only environment variables. They live in `~/.config/ani-cli/env.zsh`, which `.zshrc` sources.

| Variable | Value | Meaning |
|----------|-------|---------|
| `ANI_CLI_PLAYER` | `mpv` | Video player |
| `ANI_CLI_MODE` | `sub` | `sub` or `dub` |
| `ANI_CLI_QUALITY` | `^\(720\|480\)` | 720p, falling back to 480p (a grep pattern) |
| `ANI_CLI_DOWNLOAD_DIR` | `~/Videos/anime` | Where `-d` saves episodes |
| `ANI_CLI_HIST_DIR` | `~/.local/state/ani-cli` | Watch history (used by `-c`) |

## Usage

| Command | Action |
|---------|--------|
| `ani-cli <name>` | Search and play |
| `ani-cli -c` | Continue from history |
| `ani-cli -d <name>` | Download instead of play |
| `ani-cli -e 5-8 <name>` | Pick episodes up front |
| `ani-cli --dub <name>` | Dubbed version for one run |
| `ani-cli -q 720 <name>` | Quality for one run |
