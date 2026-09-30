#!/usr/bin/env sh
set -eu

src="${1:-}"
name="${2:-unknown}"
tag="${3:-}"

if [ -z "$src" ]; then
  echo "missing source image id"
  exit 1
fi

echo "source image: ${name}:${tag} (${src})"
printf "target image tag (e.g. repo/app:dev): "
read -r target_tag
[ -n "$target_tag" ] || {
  echo "cancelled"
  exit 1
}

docker image tag "$src" "$target_tag"
echo "tagged $src -> $target_tag"
