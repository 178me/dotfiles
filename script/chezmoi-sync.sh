#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_SOURCE="$REPO_DIR"
SYSTEM_SOURCE="$REPO_DIR/system"

WITH_SYSTEM=false
DRY_RUN=false

usage() {
  cat <<'USAGE'
Usage: script/chezmoi-sync.sh [--with-system] [--dry-run] [-h|--help]

Options:
  --with-system   Apply system source to /etc (requires sudo)
  --dry-run       Show diff only, do not write files
  -h, --help      Show this help
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --with-system)
      WITH_SYSTEM=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "Error: chezmoi is not installed or not in PATH" >&2
  exit 1
fi

if [ ! -f "$HOME_SOURCE/.chezmoiroot" ]; then
  echo "Error: invalid source directory: $HOME_SOURCE" >&2
  exit 1
fi

if [ "$DRY_RUN" = true ]; then
  echo "[home] chezmoi -S $HOME_SOURCE diff"
  chezmoi -S "$HOME_SOURCE" diff
else
  echo "[home] chezmoi -S $HOME_SOURCE apply"
  chezmoi -S "$HOME_SOURCE" apply
fi

if [ "$WITH_SYSTEM" = true ]; then
  if [ ! -d "$SYSTEM_SOURCE/etc" ]; then
    echo "Error: system source not found: $SYSTEM_SOURCE/etc" >&2
    exit 1
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "[system] sudo chezmoi -S $SYSTEM_SOURCE -D / diff"
    sudo chezmoi -S "$SYSTEM_SOURCE" -D / diff
  else
    echo "[system] sudo chezmoi -S $SYSTEM_SOURCE -D / apply"
    sudo chezmoi -S "$SYSTEM_SOURCE" -D / apply
  fi
fi

echo "Done."
