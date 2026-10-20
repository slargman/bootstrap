#!/usr/bin/env bash
set -euo pipefail

# Install Homebrew
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install and log in to GitHub CLI
command -v gh &>/dev/null || brew install gh
gh auth status &>/dev/null || gh auth login --web --clipboard --git-protocol https

# Set up dotfiles repo
# TODO: check that the dotfiles are applied, not just that $DOTS_DIR exists. If the
# checkout fails (e.g. a tracked file already exists in $HOME), the next run skips it.
DOTS_DIR="$HOME/.dotfiles"
if [[ ! -d "$DOTS_DIR" ]]; then
  gh repo clone slargman/dotfiles "$DOTS_DIR" -- --bare
  git --git-dir="$DOTS_DIR" --work-tree="$HOME" checkout
fi

# Run further setup
PRIVATE_SETUP="$HOME/bootstrap.sh"
if [[ -f "$PRIVATE_SETUP" ]]; then
  exec bash "$PRIVATE_SETUP"
fi

echo "Public bootstrap completed."
