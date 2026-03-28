#!/bin/bash

# WezTerm 配置同步脚本
# 使用方法：./sync_config.sh

echo "🔄 正在同步 WezTerm 配置..."

# 检查编辑文件是否存在
if [ ! -f "wezterm_edit.lua" ]; then
    echo "❌ 错误：找不到 wezterm_edit.lua 文件"
    echo "请确保您在 ~/.config/wezterm/ 目录下运行此脚本"
    exit 1
fi

# 备份原配置文件
if [ -f "wezterm.lua" ]; then
    cp wezterm.lua wezterm.lua.backup
    echo "✅ 已备份原配置文件为 wezterm.lua.backup"
fi

# 复制编辑文件到配置文件
cp wezterm_edit.lua ~/.config/wezterm/wezterm.lua
echo "✅ 配置已同步到 wezterm.lua"

# 检查 WezTerm 是否正在运行
if pgrep -x "wezterm" > /dev/null; then
    echo "🔄 WezTerm 正在运行，配置将自动重载..."
    echo "💡 如果配置没有立即生效，请重启 WezTerm"
else
    echo "ℹ️  WezTerm 未运行，启动时将使用新配置"
fi

echo "🎉 配置同步完成！" 
