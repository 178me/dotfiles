#!/usr/bin/env bash

set -euo pipefail

if [[ "${1:-}" == "--name" ]]; then
  archive_name="${2:-}"
  shift 2 || true
else
  archive_name=""
fi

if [[ "$#" -eq 0 ]]; then
  echo "No files selected."
  exit 1
fi

cwd="$PWD"
rel_paths=()

for path in "$@"; do
  case "$path" in
    "$cwd"/*) rel_paths+=("${path#"$cwd"/}") ;;
    *) rel_paths+=("$(basename -- "$path")") ;;
  esac
done

name_stem() {
  local base="$1"

  # Keep dotfiles like ".env" untouched.
  if [[ "$base" == *.* && "$base" != .* ]]; then
    printf "%s" "${base%.*}"
  else
    printf "%s" "$base"
  fi
}

first="${rel_paths[0]%/}"
first_base="$(basename -- "$first")"
first_stem="$(name_stem "$first_base")"
[[ -n "$first_stem" ]] || first_stem="archive"

if [[ -z "$archive_name" ]]; then
  if [[ "${#rel_paths[@]}" -eq 1 ]]; then
    archive_name="$first_stem"
  else
    archive_name="${first_stem}等文件"
  fi

  if [[ -t 0 && -t 1 ]]; then
    printf "Archive name (empty for \"%s\"): " "$archive_name"
    IFS= read -r input_name || true
    [[ -n "$input_name" ]] && archive_name="$input_name"
  fi
fi

archive_name="${archive_name%.zip}.zip"

tmp_list="$(mktemp)"
trap 'rm -f "$tmp_list"' EXIT
printf "%s\n" "${rel_paths[@]}" > "$tmp_list"

zip -r "$archive_name" -@ < "$tmp_list"
echo "Created: $cwd/$archive_name"
