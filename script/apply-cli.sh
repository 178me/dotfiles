#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY=false
case "${1:---dry-run}" in
  --apply) APPLY=true ;;
  --dry-run) ;;
  *) echo 'Usage: bash script/apply-cli.sh [--dry-run|--apply]' >&2; exit 1 ;;
esac
if [ "$#" -gt 1 ]; then
  echo 'Expected at most one option' >&2
  exit 1
fi

command -v chezmoi >/dev/null
TARGET_NAMES=(
  .zshenv .zshrc .bashrc .bash_profile .profile .gitconfig .vimrc .pip .ssh/config
  .config/lazydocker .config/lazygit .config/nvim-lazy .config/yazi
  .config/zellij .config/wezterm .config/alacritty .config/ranger .config/fish .config/pnpm
  .codex/AGENTS.md .codex/rules .codex/skills
)
TARGETS=()
for name in "${TARGET_NAMES[@]}"; do
  TARGETS+=("$HOME/$name")
done

if [ "$APPLY" = false ]; then
  chezmoi -S "$REPO_DIR" status "${TARGETS[@]}"
  printf '\nApply will first archive existing target configs and activate ~/.config/nvim-lazy.\n'
  exit 0
fi

umask 077
BACKUP_ROOT="$HOME/.local/state/dotfiles/backups"
mkdir -p "$BACKUP_ROOT"
BACKUP_DIR="$(mktemp -d "$BACKUP_ROOT/cli-$(date +%Y%m%d-%H%M%S).XXXXXX")"
EXISTING=()
for name in "${TARGET_NAMES[@]}" .config/nvim; do
  if [ -e "$HOME/$name" ] || [ -L "$HOME/$name" ]; then
    EXISTING+=("$name")
  fi
done
if [ "${#EXISTING[@]}" -gt 0 ]; then
  tar -czf "$BACKUP_DIR/configs.tar.gz" -C "$HOME" "${EXISTING[@]}"
fi
printf 'Backup directory: %s\n' "$BACKUP_DIR"
mkdir -p "$HOME/.codex" "$HOME/.config" "$HOME/.ssh"
chezmoi -S "$REPO_DIR" apply "${TARGETS[@]}"

NVIM_TARGET="$HOME/.config/nvim-lazy"
if [ "$(readlink "$HOME/.config/nvim" 2>/dev/null || true)" != "$NVIM_TARGET" ]; then
  if [ -e "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim.previous"
  fi
  ln -s "$NVIM_TARGET" "$HOME/.config/nvim"
fi
printf 'CLI configs applied. Neovim profile: %s\n' "$NVIM_TARGET"
