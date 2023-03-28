#!/usr/bin/env bash

set -e

install_dir() {
  [ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.shorebird" || printf %s "${XDG_CONFIG_HOME}/shorebird"
}

add_shorebird_to_path() {
  # Add the Shorebird CLI to your PATH.
  echo "Adding Shorebird to your PATH"
  
  # Check if using zsh
  if [ -z "${ZSH_VERSION}" ]; then
    echo "Updating ~/.zshrc"
    echo "export PATH=\"$(install_dir)/bin:\$PATH\"" >> ~/.zshrc    
    sched +1 'source ~/.zshrc'
  # Check if using bash
  elif [ -z "${BASH_VERSION}" ]; then
    echo "Updating ~/.bashrc"
    echo "export PATH=\"$(install_dir)/bin:\$PATH\"" >> ~/.bashrc    
    sched +1 'source ~/.bashrc'
  else
    echo "Unable to determine shell type. Please add Shorebird to your PATH manually."
    echo "export PATH=\"$(install_dir)/bin:\$PATH\""
  fi
}

# Check if install_dir already exists
if [ -d "$(install_dir)" ]; then
  echo "Shorebird is already installed."
  exit 1
fi

# Test if Git is available on the Host
if ! hash git 2>/dev/null; then
  >&2 echo "Error: Unable to find git in your PATH."
  exit 1
fi

# Clone the Shorebird repository into the install_dir
echo "Cloning Shorebird into $(install_dir)"
git clone https://github.com/shorebirdtech/shorebird.git -b stable "$(install_dir)"

# Build Shorebird
eval $(install_dir)/bin/shorebird

SHOREBIRD_BIN="$(install_dir)/bin"
case :$PATH:
  in *:$SHOREBIRD_BIN:*) ;; # do nothing, it's there
  *) add_shorebird_to_path >&2;;
esac

echo "🐦 Shorebird has been installed!"