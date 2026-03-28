#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_SOURCE="$REPO_DIR"

PUSH=true
DRY_RUN=false
MESSAGE=""

usage() {
  cat <<'USAGE'
Usage: script/chezmoi-save.sh [--dry-run] [--no-push] [-m|--message <msg>] [-h|--help]

Options:
  --dry-run              Show current changes only (no write)
  --no-push              Commit locally only, do not push
  -m, --message <msg>    Use a custom commit message
  -h, --help             Show this help
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-push)
      PUSH=false
      shift
      ;;
    -m|--message)
      if [ "$#" -lt 2 ]; then
        echo "Error: missing commit message after $1" >&2
        exit 1
      fi
      MESSAGE="$2"
      shift 2
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
  echo "No home changes to commit."
  exit 0
fi

if [ -z "$MESSAGE" ]; then
  MESSAGE="chore(dotfiles): sync home from host $(date '+%Y-%m-%d %H:%M:%S')"
fi

echo "[repo] git commit"
git -C "$REPO_DIR" commit -m "$MESSAGE"

if [ "$PUSH" = true ]; then
  echo "[repo] git push"
  if ! git -C "$REPO_DIR" push; then
    branch="$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD)"
    git -C "$REPO_DIR" push -u origin "$branch"
  fi
fi

echo "Done."
