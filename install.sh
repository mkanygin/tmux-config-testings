#!/usr/bin/env bash

#
set -e
set -u
set -o pipefail

# Function to check if a app is installed
is_app_installed() {
  type "$1" &>/dev/null
}

#
REPODIR="$(cd "$(dirname "$0")"; pwd -P)"
cd "$REPODIR";

# Check if tmux is installed
if ! is_app_installed tmux; then
  echo -e "WARNING: \"tmux\" command is not found. Install it first\n"
  exit 1
fi

# Check if tmux plugin manager is installed
if [ ! -e "~/.tmux/plugins/tpm" ]; then
  echo -e "WARNING: Cannot found TPM (Tmux Plugin Manager) at default location: \$HOME/.tmux/plugins/tpm.\n"

  # Clone tmux plugin manager (tpm)
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Check if tmux config file exist, then backup the file
if [ -e "~/.tmux.conf" ]; then
  echo -e "Found existing .tmux.conf in your \$HOME directory. Will create a backup at $HOME/.tmux.conf.bak\n"
  
  # Backup tmux config file
  cp -f ~/.tmux.conf ~/.tmux.conf.bak 2>/dev/null || true
fi

# Symlink tmux config file
ln -sf ~/.tmux/tmux/tmux.conf ~/.tmux.conf

# Create tmux script directory
mkdir -p ~/.scripts/tmux

# Symlink tmux scripts
ln -sf ~/.tmux/yank.sh ~/.scripts/yank.sh
#ln -sf ~/.tmux/tmux.conf ~/.scripts/
#ln -sf ~/.tmux/tmux.conf ~/.scripts/

# Chmod tmux scripts to +x
chmod +x ~/.scripts/

# Install TPM plugins
echo -e "Install TPM plugins\n"

# TPM requires running tmux server,
# as soon as `tmux start-server` does not work,
# create dump __noop session in detached mode
# and kill it when plugins are installed
tmux new -d -s __noop >/dev/null 2>&1 || true 
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "~/.tmux/plugins"
~/.tmux/plugins/tpm/bin/install_plugins || true
tmux kill-session -t __noop >/dev/null 2>&1 || true

# Finish!
echo -e "OK: Completed\n"
