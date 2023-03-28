#!/usr/bin/env bash

set -e

install_dir() {
  [ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.shorebird" || printf %s "${XDG_CONFIG_HOME}/shorebird"
}

# Check if install_dir already exists
if [ -d "$(install_dir)" ]; then
  echo "Shorebird is already installed."
  exit 1
fi

# Test if Git is available on the Host
if ! hash git 2>/dev/null; then
  echo >&2 "Error: Unable to find git in your PATH."
  exit 1
fi

# Clone the Shorebird repository into the install_dir
echo "Cloning Shorebird into $(install_dir)"
git clone https://github.com/shorebirdtech/shorebird.git -b stable "$(install_dir)"

# Build Shorebird
eval $(install_dir)/bin/shorebird

SHOREBIRD_BIN="$(install_dir)/bin"
case :$PATH: in *:$SHOREBIRD_BIN:*) ;; # do nothing, it's there
*) ./source.sh >&2 ;;
esac

echo "
🐦 Shorebird has been installed!

To get started, run the following command:

  shorebird --help

For more information, visit https://github.com/shorebirdtech/shorebird.
"
