#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CODEX_SOURCE="$(cd "$SCRIPT_DIR/../home/dot_codex" 2>/dev/null && pwd || true)"
ROOT="${CODEX_ROOT:-$HOME/.codex}"
ACTIVE_PROFILE_FILE="${CODEX_PROFILE_FILE:-$ROOT/tmp/active-profile}"

usage() {
  cat <<'USAGE'
Usage:
  script/codex-profile.sh --select
  script/codex-profile.sh

Examples:
  script/codex-profile.sh --select
  script/codex-profile.sh
USAGE
}

link_if_missing() {
  local target="$1"
  local source="$2"

  if [ -e "$target" ] || [ -L "$target" ]; then
    return 0
  fi
  if [ ! -e "$source" ] && [ ! -L "$source" ]; then
    return 0
  fi
  ln -s "$source" "$target"
}

link_required() {
  local src="$1"
  local dst="$2"

  if [ ! -f "$src" ]; then
    echo "错误: 源文件不存在: $src" >&2
    exit 1
  fi

  if [ -d "$dst" ]; then
    echo "错误: 目标路径是目录，无法创建软链: $dst" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
}

ensure_runtime_files() {
  local profile_dir="$1"

  # Support chezmoi source-state names:
  # private_config.toml -> config.toml
  # private_auth.json   -> auth.json
  link_if_missing "$profile_dir/config.toml" "$profile_dir/private_config.toml"
  link_if_missing "$profile_dir/auth.json" "$profile_dir/private_auth.json"
}

bootstrap_profile_from_repo() {
  local profile="$1"

  if [ -z "$REPO_CODEX_SOURCE" ]; then
    return 0
  fi

  local src="$REPO_CODEX_SOURCE/profiles/$profile"
  local dst="$ROOT/profiles/$profile"

  if [ ! -d "$src" ] || [ -d "$dst" ]; then
    return 0
  fi

  mkdir -p "$ROOT/profiles" "$dst"
  link_if_missing "$dst/config.toml" "$src/config.toml"
  link_if_missing "$dst/config.toml" "$src/private_config.toml"
  link_if_missing "$dst/auth.json" "$src/auth.json"
  link_if_missing "$dst/auth.json" "$src/private_auth.json"
}

discover_profiles() {
  local -A seen=()
  local profiles=()
  local dir
  local name

  if [ -d "$ROOT/profiles" ]; then
    for dir in "$ROOT"/profiles/*; do
      [ -d "$dir" ] || continue
      name="$(basename "$dir")"
      if [ -z "${seen[$name]+x}" ]; then
        profiles+=("$name")
        seen["$name"]=1
      fi
    done
  fi

  if [ -n "$REPO_CODEX_SOURCE" ] && [ -d "$REPO_CODEX_SOURCE/profiles" ]; then
    for dir in "$REPO_CODEX_SOURCE"/profiles/*; do
      [ -d "$dir" ] || continue
      name="$(basename "$dir")"
      if [ -z "${seen[$name]+x}" ]; then
        profiles+=("$name")
        seen["$name"]=1
      fi
    done
  fi

  printf "%s\n" "${profiles[@]}"
}

profile_dir_hint() {
  local profile="$1"
  if [ -d "$ROOT/profiles/$profile" ]; then
    echo "$ROOT/profiles/$profile"
    return
  fi
  if [ -n "$REPO_CODEX_SOURCE" ] && [ -d "$REPO_CODEX_SOURCE/profiles/$profile" ]; then
    echo "$REPO_CODEX_SOURCE/profiles/$profile (repo source)"
    return
  fi
  echo "$ROOT/profiles/$profile"
}

resolve_profile_dir() {
  local profile="$1"
  local profile_dir=""

  bootstrap_profile_from_repo "$profile"
  profile_dir="$ROOT/profiles/$profile"

  if [ ! -d "$profile_dir" ]; then
    echo "Profile directory not found: $profile_dir" >&2
    if [ -n "$REPO_CODEX_SOURCE" ] && [ -d "$REPO_CODEX_SOURCE/profiles/$profile" ]; then
      echo "Hint: run 'make sync' first, or set CODEX_ROOT to a directory containing profiles." >&2
    fi
    exit 1
  fi

  ensure_runtime_files "$profile_dir"

  local missing=()
  [ -f "$profile_dir/config.toml" ] || missing+=("config.toml")
  [ -f "$profile_dir/auth.json" ] || missing+=("auth.json")
  if [ "${#missing[@]}" -gt 0 ]; then
    echo "Profile '$profile' is missing: ${missing[*]}" >&2
    exit 1
  fi

  echo "$profile_dir"
}

get_current_profile() {
  local p=""
  local fallback=""
  local exists=1
  local candidate=""

  if [ -f "$ACTIVE_PROFILE_FILE" ]; then
    p="$(sed -n '1p' "$ACTIVE_PROFILE_FILE" 2>/dev/null || true)"
  fi

  while IFS= read -r candidate; do
    if [ -n "$candidate" ] && [ -z "$fallback" ]; then
      fallback="$candidate"
    fi
    if [ -n "$p" ] && [ "$candidate" = "$p" ]; then
      exists=0
      break
    fi
  done < <(discover_profiles)

  if [ "$exists" -eq 0 ]; then
    echo "$p"
  else
    echo "$fallback"
  fi
}

set_current_profile() {
  local profile="$1"
  (
    umask 077
    mkdir -p "$(dirname "$ACTIVE_PROFILE_FILE")" && \
      printf "%s\n" "$profile" > "$ACTIVE_PROFILE_FILE"
  ) >/dev/null 2>&1
}

apply_profile() {
  local profile="$1"
  local profile_dir

  profile_dir="$(resolve_profile_dir "$profile")"

  mkdir -p "$ROOT"

  # 切换后，让 ~/.codex/config.toml 与 auth.json 软链到目标 profile
  link_required "$profile_dir/config.toml" "$ROOT/config.toml"
  link_required "$profile_dir/auth.json" "$ROOT/auth.json"

  if ! set_current_profile "$profile"; then
    echo "警告: 无法持久化当前 profile 到 $ACTIVE_PROFILE_FILE" >&2
  fi

  echo "已应用 profile: $profile"
  echo "profile 源: $profile_dir"
  echo "生效软链: $ROOT/config.toml -> $profile_dir/config.toml"
  echo "生效软链: $ROOT/auth.json -> $profile_dir/auth.json"
}

list_profiles() {
  local current
  local p
  current="$(get_current_profile)"

  while IFS= read -r p; do
    if [ "$p" = "$current" ]; then
      printf "* %s\t%s\n" "$p" "$(profile_dir_hint "$p")"
    else
      printf "  %s\t%s\n" "$p" "$(profile_dir_hint "$p")"
    fi
  done < <(discover_profiles)
}

select_profile() {
  local profiles=""
  local current
  local selected=""
  current="$(get_current_profile)"
  profiles="$(discover_profiles)"

  if [ -z "$profiles" ]; then
    echo "错误: 未发现可用 profile。请先执行 make sync。" >&2
    exit 1
  fi

  if [ -n "$current" ]; then
    echo "当前 profile: $current" >&2
  else
    echo "当前 profile: <none>" >&2
  fi
  echo "可用 profile:" >&2
  list_profiles >&2

  if command -v fzf >/dev/null 2>&1; then
    selected="$(
      printf "%s\n" "$profiles" | \
        fzf --prompt="选择 profile: " \
            --header="当前 profile: ${current:-<none>}" \
            --height=40% \
            --layout=reverse \
            --border
    )"
  else
    echo "未安装 fzf，改为手动输入。" >&2
    if [ -n "$current" ]; then
      read -r -p "输入 profile 名称（默认: $current）: " selected
      selected="${selected:-$current}"
    else
      read -r -p "输入 profile 名称: " selected
    fi
  fi

  if [ -z "$selected" ]; then
    echo "未选择 profile，已取消。" >&2
    exit 1
  fi

  echo "$selected"
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

if [ "${1:-}" = "--select" ] || [ "${1:-}" = "-s" ] || [ $# -eq 0 ]; then
  chosen="$(select_profile)"
  apply_profile "$chosen"
  exit 0
fi

echo "错误: 仅支持 --select（或不带参数）。" >&2
usage >&2
exit 1
