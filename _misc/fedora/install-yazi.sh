#!/bin/bash
set -e

# Variables
URL="https://github.com/sxyazi/yazi/releases/download/nightly/yazi-x86_64-unknown-linux-gnu.zip"
ZIP_NAME="yazi.zip"
TMP_DIR=$(mktemp -d)
DEST_BIN="/usr/bin"
FISH_COMPLETION_DIR="/usr/share/fish/completions"
BASH_COMPLETION_DIR="/usr/share/bash-completion/completions"

# Download
echo "Downloading Yazi..."
curl -L "$URL" -o "$ZIP_NAME"

# Unzip
echo "Extracting..."
unzip "$ZIP_NAME" -d "$TMP_DIR"

# Find base folder (should be yazi-x86_64-unknown-linux-gnu)
BASE_DIR=$(find "$TMP_DIR" -type d -name "yazi-x86_64-unknown-linux-gnu")

# Install binaries
echo "Installing ya and yazi to $DEST_BIN..."
sudo install -m 755 "$BASE_DIR/ya" "$DEST_BIN/ya"
sudo install -m 755 "$BASE_DIR/yazi" "$DEST_BIN/yazi"

if [ -d "$FISH_COMPLETION_DIR" ]; then
  # Install Fish completion
  echo "Installing Fish completion to $FISH_COMPLETION_DIR..."
  sudo cp "$BASE_DIR/completions/ya.fish" "$FISH_COMPLETION_DIR/"
fi
if [ -d "$BASH_COMPLETION_DIR" ]; then
  # Install Bash completion
  echo "Installing Bash completion to $BASH_COMPLETION_DIR..."
  sudo cp "$BASE_DIR/completions/ya.bash" "$BASH_COMPLETION_DIR/"
fi

# Cleanup
rm -rf "$TMP_DIR" "$ZIP_NAME"
echo "Done!"
