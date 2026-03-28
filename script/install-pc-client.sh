#!/bin/bash
set -e

# 配置参数
default_url="https://dl.lazycat.cloud/client/desktop/stable/lzc-client-desktop_latest.tar.zst"
download_url="${1:-$default_url}"
install_dir="$HOME/.local/share/lzc-client-desktop"
temp_archive="/tmp/lzc-client-$(date +%s).tar.zst"

# 获取版本号
get_version() {
  # 从URL中提取版本号
  if [[ "$download_url" =~ lzc-client-desktop_([^/]+)\.tar\.zst$ ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    # 从压缩包中提取版本号
    curl -sL "$download_url" | zstd -dcq | tar xOf - metadata.json 2>/dev/null |
      grep -oP '"buildVersion"\s*:\s*"\K[^"]+' || echo "unknown"
  fi
}

echo "正在获取版本信息..."
version=$(get_version)
if [ -z "$version" ]; then
  echo "错误：无法确定版本号！"
  exit 1
fi

# 备份旧版本
if [ -d "$install_dir" ]; then
  old_version=$(cat "$install_dir/metadata.json" 2>/dev/null |
    grep -oP '"buildVersion"\s*:\s*"\K[^"]+' || echo "old")
  backup_dir="${install_dir}_${old_version}"

  echo "发现已安装版本 ${old_version}，正在备份到 ${backup_dir}..."
  rm -rf "$backup_dir" 2>/dev/null || true
  mv "$install_dir" "$backup_dir"
fi

# 下载并安装新版本
echo "正在下载版本 ${version}..."
curl -kL "$download_url" -o "$temp_archive"

echo "正在安装到 ${install_dir}..."
mkdir -p "$install_dir"
zstd -dcq "$temp_archive" | tar xf - -C "$install_dir"

# 清理临时文件
rm -f "$temp_archive"

# 显示安装结果
echo ""
echo "安装成功完成！"
echo "新版本路径: ${install_dir}"
echo "安装版本: ${version}"
if [ -n "$backup_dir" ]; then
  echo "旧版本已备份到: ${backup_dir}"
fi
