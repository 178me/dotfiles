#!/usr/bin/env sh
set -eu

image_id="${1:-}"

if [ -z "$image_id" ]; then
  echo "missing image id"
  exit 1
fi

inspect_output="$(
  docker image inspect "$image_id" --format '{{range .RepoTags}}{{println .}}{{end}}' 2>&1
)" || {
  echo "failed to inspect image: $image_id"
  echo "$inspect_output"
  exit 1
}
repo_tags_raw="$inspect_output"
repo_tags="$(printf '%s\n' "$repo_tags_raw" | sed '/^$/d' | sed '/^<none>:<none>$/d')"

if [ -z "$repo_tags" ]; then
  echo "no pushable tags found for image: $image_id"
  echo "tip: tag the image first"
  if [ -r /dev/tty ]; then
    printf "press Enter to continue..."
    read -r _ </dev/tty || true
  fi
  exit 1
fi

echo "select a tag to push:"
printf '%s\n' "$repo_tags" | nl -ba -w1 -s') '

count=$(printf '%s\n' "$repo_tags" | wc -l | tr -d ' ')

printf "choose [1-%s] (default 1): " "$count"
if [ -r /dev/tty ]; then
  read -r idx </dev/tty
else
  read -r idx || true
fi

if [ -z "${idx:-}" ]; then
  idx=1
fi

case "$idx" in
  *[!0-9]*)
    echo "invalid selection: $idx"
    exit 1
    ;;
esac

if [ "$idx" -lt 1 ] || [ "$idx" -gt "$count" ]; then
  echo "selection out of range: $idx"
  exit 1
fi

selected_tag=$(printf '%s\n' "$repo_tags" | sed -n "${idx}p")

[ -n "$selected_tag" ] || {
  echo "failed to resolve selected tag"
  exit 1
}

echo "pushing: $selected_tag"
docker image push "$selected_tag"
echo "pushed: $selected_tag"
