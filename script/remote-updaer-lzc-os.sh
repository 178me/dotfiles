#!/bin/bash

# 检查参数数量
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 <version> <boxname> [password]"
  exit 1
fi

# 获取参数
version=$1
boxname=$2
password=${3:-root} # 如果没有提供密码，默认使用root

# 定义下载文件路径
file="/tmp/lzc-os-update/lzc-os-$version.tar.lz4"

# 创建目标目录
mkdir -p /tmp/lzc-os-update

# 检查文件是否已存在
if [ ! -f "$file" ]; then
  # 下载文件
  echo "Downloading lzc-os.tar.lz4 for version $version..."
  wget --no-check-certificate -O "$file" "https://dl.corp.linakesi.cn/update-package/full/$version/lzc-os.tar.lz4"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to download file"
    exit 1
  fi
else
  echo "File already exists, skipping download."
fi

# 定义目标路径
destination="root@$boxname.heiyu.space:/run/lzcsys/boot/lzc-os-init/update/package.tar.lz4"

set -x

# 使用scp上传文件
echo "Uploading $file to $boxname..."
scp -o StrictHostKeyChecking=no -P 3322 "$file" "$destination"
if [ $? -ne 0 ]; then
  echo "Error: Failed to upload file"
  exit 1
fi

# 通过sshpass和ssh命令重启服务
echo "Restarting lzc-os on $boxname..."
sshpass -p "$password" ssh root@"$boxname.heiyu.space" -p3322 'systemctl restart lzc-os'
if [ $? -ne 0 ]; then
  echo "Error: Failed to restart lzc-os"
  exit 1
fi

echo "Process completed successfully."
