#!/usr/bin/env bash

set -e

install_dir() {
  [ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.shorebird" || printf %s "${XDG_CONFIG_HOME}/shorebird"
}

# Prints the rc file for the user's login shell (from $SHELL), or nothing if
# the shell isn't one we know how to configure.
shell_rc_file() {
  case "$(basename "${SHELL-}")" in
  zsh) printf %s "${ZDOTDIR:-$HOME}/.zshrc" ;;
  bash)
    # macOS Terminal starts bash as a login shell, which reads .bash_profile.
    if [ "$(uname)" = "Darwin" ]; then
      printf %s "$HOME/.bash_profile"
    else
      printf %s "$HOME/.bashrc"
    fi
    ;;
  esac
}

add_shorebird_to_path() {
  # Add the Shorebird CLI to your PATH.
  path_line="export PATH=\"$(install_dir)/bin:\$PATH\""
  rc_file="$(shell_rc_file)"

  if [ -z "$rc_file" ]; then
    echo "Unable to determine shell type. Please add Shorebird to your PATH manually:"
    echo "  $path_line"
    return
  fi

  if [ -f "$rc_file" ] && grep -qF "$path_line" "$rc_file"; then
    return
  fi

  echo "Adding Shorebird to your PATH in $rc_file"
  echo "$path_line" >>"$rc_file"
}

# Function to compare two major.minor.patch versions
# Returns:
#   0 - If version1 is equal to version2
#   1 - If version1 is older than version2
#   2 - If version1 is newer than version2
# With help from copilot :)
version_compare () {
  # Get the two versions as arguments
  local version1=$1
  local version2=$2

  # Split the versions into their major, minor, and patch components
  local major1=${version1%%.*}
  local minor1=${version1#*.}
  minor1=${minor1%%.*}
  local patch1=${version1##*.}

  local major2=${version2%%.*}
  local minor2=${version2#*.}
  minor2=${minor2%%.*}
  local patch2=${version2##*.}

  # Compare major versions
  if [ "$major1" -lt "$major2" ]; then
    return 1
  elif [ "$major1" -gt "$major2" ]; then
    return 2
  else
    # Major versions are the same, compare minor versions
    if [ "$minor1" -lt "$minor2" ]; then
      return 1
    elif [ "$minor1" -gt "$minor2" ]; then
      return 2
    else
      # Minor versions are the same, compare patch versions
      if [ "$patch1" -lt "$patch2" ]; then
        return 1
      elif [ "$patch1" -gt "$patch2" ]; then
        return 2
      else
        # Patch versions are the same
        return 0
      fi
    fi
  fi
}

FORCE=false
if [[ "$*" == *"--force"* ]]; then
  FORCE=true
fi

# Test if Git is available on the Host
if ! hash git 2>/dev/null; then
  echo >&2 "Error: Unable to find git in your PATH."
  exit 1
fi

MIN_GIT_VERSION="2.25.1"
GIT_VERSION=$(git --version | awk '{print $3}')
set +e
version_compare "$MIN_GIT_VERSION" "$GIT_VERSION"
GIT_VERSION_COMPARISON=$?
set -e
if [ $GIT_VERSION_COMPARISON -eq 2 ]; then
  echo >&2 "Error: system git version ($GIT_VERSION) is older than required ($MIN_GIT_VERSION)."
  exit 1
fi

# Check if install_dir already exists
if [ -d "$(install_dir)" ]; then
  if [ "$FORCE" = true ]; then
    echo "Existing Shorebird installation detected. Overwriting..."
    rm -rf "$(install_dir)"
  else
    echo >&2 "Error: Shorebird is already installed at $(install_dir).

To update it, run:

  shorebird upgrade

To delete it and install again, run:

  curl --proto '=https' --tlsv1.2 https://shorebird.dev/install.sh -sSf | bash -s -- --force"
    exit 1
  fi
fi

# A fresh install (Shorebird, Flutter and the Dart SDK) needs about 2.5GB.
MIN_FREE_KB=$((3 * 1024 * 1024))
install_parent="$(dirname "$(install_dir)")"
[ -d "$install_parent" ] || install_parent="$HOME"
FREE_KB=$(df -Pk "$install_parent" | awk 'NR==2 {print $4}')
if [ -n "$FREE_KB" ] && [ "$FREE_KB" -lt "$MIN_FREE_KB" ]; then
  echo >&2 "Error: Not enough disk space to install Shorebird.
Shorebird needs 3GB free on the disk holding $install_parent; $((FREE_KB / 1024))MB is free."
  exit 1
fi

# If the install fails partway (a dropped connection, a full disk), remove
# what was installed so running the installer again starts clean.
INSTALL_COMPLETE=false
cleanup_failed_install() {
  if [ "$INSTALL_COMPLETE" != true ] && [ -d "$(install_dir)" ]; then
    rm -rf "$(install_dir)"
    echo >&2 "
Error: Shorebird installation failed. Removed the partial install at $(install_dir).
Fix the error above, then run the installer again."
  fi
}
trap cleanup_failed_install EXIT

# Clone the Shorebird repository into the install_dir
echo "Cloning Shorebird into $(install_dir)"
git clone https://github.com/shorebirdtech/shorebird.git -b stable "$(install_dir)"

# Build Shorebird
(cd "$(install_dir)" && ./bin/shorebird --version)
INSTALL_COMPLETE=true

RELOAD_REQUIRED=false
SHOREBIRD_BIN="$(install_dir)/bin"
case :$PATH: in *:$SHOREBIRD_BIN:*) ;; # do nothing, it's there
*)
  RELOAD_REQUIRED=true
  add_shorebird_to_path >&2
  ;;
esac

echo ""
echo "🐦 Shorebird has been installed!"

if [ "$RELOAD_REQUIRED" = true ]; then
  echo "
Close and reopen your terminal to start using Shorebird or run the following command to start using it now:

  export PATH=\"$(install_dir)/bin:\$PATH\""
fi

echo "
To create an account, visit: https://console.shorebird.dev
Then login using:

  shorebird login

For more information, visit:
https://docs.shorebird.dev
"
