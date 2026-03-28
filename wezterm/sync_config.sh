#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_FILE="$REPO_ROOT/home/dot_config/wezterm/wezterm.lua"
TARGET_FILE="$HOME/.config/wezterm/wezterm.lua"

echo "Syncing WezTerm config..."

if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: source file not found: $SOURCE_FILE"
    exit 1
fi

mkdir -p "$(dirname "$TARGET_FILE")"

if [ -f "$TARGET_FILE" ]; then
    cp "$TARGET_FILE" "${TARGET_FILE}.backup"
    echo "Backup created: ${TARGET_FILE}.backup"
fi

cp "$SOURCE_FILE" "$TARGET_FILE"
echo "Config synced: $TARGET_FILE"

if pgrep -x "wezterm" > /dev/null; then
    echo "WezTerm is running. Restart if config is not reloaded."
else
    echo "WezTerm is not running. New config will apply on next start."
fi
