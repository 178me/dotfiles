#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_SOURCE="$REPO_DIR"

DRY_RUN=false

usage() {
  cat <<'USAGE'
Usage: script/chezmoi-save.sh [--dry-run] [-h|--help]

Options:
  --dry-run              Show current changes only (no write)
  -h, --help             Show this help
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "Error: chezmoi is not installed or not in PATH" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is not installed or not in PATH" >&2
  exit 1
fi

if [ ! -f "$HOME_SOURCE/.chezmoiroot" ]; then
  echo "Error: invalid source directory: $HOME_SOURCE" >&2
  exit 1
fi

if [ "$DRY_RUN" = true ]; then
  echo "[home] chezmoi -S $HOME_SOURCE diff"
  chezmoi -S "$HOME_SOURCE" diff
  echo "[repo] git status --short"
  git -C "$REPO_DIR" status --short
  exit 0
fi

echo "[home] chezmoi -S $HOME_SOURCE re-add"
chezmoi -S "$HOME_SOURCE" re-add

git -C "$REPO_DIR" add -A home/

if git -C "$REPO_DIR" diff --cached --quiet -- home/; then
  echo "No home changes."
  exit 0
fi

echo "[repo] git status --short -- home/"
git -C "$REPO_DIR" status --short -- home/
echo "Done (write only, no commit/push)."
