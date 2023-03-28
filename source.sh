#!/usr/bin/env bash

# Add the Shorebird CLI to your PATH.
echo "Adding Shorebird to your PATH"

# Check if using zsh
if [ -z "${ZSH_VERSION}" ]; then
  echo "Updating ~/.zshrc"
  echo "export PATH=\"$(install_dir)/bin:\$PATH\"" >>~/.zshrc
  exec zsh && source ~/.zshrc
# Check if using bash
elif [ -z "${BASH_VERSION}" ]; then
  echo "Updating ~/.bashrc"
  echo "export PATH=\"$(install_dir)/bin:\$PATH\"" >>~/.bashrc
  exec bash && source ~/.bashrc
else
  echo "Unable to determine shell type. Please add Shorebird to your PATH manually."
  echo "export PATH=\"$(install_dir)/bin:\$PATH\""
fi
