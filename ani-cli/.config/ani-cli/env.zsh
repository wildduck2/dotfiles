# Sourced by .zshrc; ani-cli reads only these env vars, it has no config file
export ANI_CLI_PLAYER=mpv
export ANI_CLI_MODE=sub
# ani-cli greps the descending links list, so this takes 720 and falls back to 480
export ANI_CLI_QUALITY='^\(720\|480\)'
export ANI_CLI_DOWNLOAD_DIR="$HOME/Videos/anime"
export ANI_CLI_HIST_DIR="$HOME/.local/state/ani-cli"
