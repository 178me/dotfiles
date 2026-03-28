#!/bin/bash

# 检查参数数量
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 <file.tar.lz4> <boxname> [password]"
  exit 1
fi

# 获取参数
file=$1
boxname=$2
password=${3:-root} # 如果没有提供密码，默认使用root

# 验证文件是否为.tar.lz4包
if [[ $file != *.tar.lz4 ]]; then
  echo "Error: File is not a .tar.lz4 package"
  exit 1
fi

# 验证文件是否存在
if [ ! -f "$file" ]; then
  echo "Error: File not found"
  exit 1
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
