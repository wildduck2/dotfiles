#!/usr/bin/env bash

# INFO: Define variables
REPO_URL="<https://github.com/wildduck2/dotfiles.git>"
CLONE_DIR="~/.config/.dotfiles"
DESTINATION_CONFIG="~/.config/nvim"
DESTINATION_LOCAL_SHARE="~/.local/share/nvim"

# Move existing nvim directories to backup
mv ~/.config/nvim ~/.config/nvim.bakup || true
mv ~/.local/share/nvim ~/.local/share/nvim.bakup || true

# Clone the repository
git clone $REPO_URL $CLONE_DIR

# Change into the cloned directory
cd $CLONE_DIR

# Copy the nvim folder to the destination
cp -r nvim $DESTINATION_CONFIG/


# INFO: List of tools to check
TOOLS=("unzip" "wget" "curl" "gzip" "tar" "bash" "sh" "ripgrep" "fd" "fzf")

# Loop through each tool
for TOOL in "${TOOLS[@]}"; do
    # Attempt to execute the tool
    if! command -v $TOOL &> /dev/null; then
        echo "$TOOL is not installed."
    else
        echo "$TOOL is installed."
    fi
done


echo "Script completed successfully."

