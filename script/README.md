# Neovim Profile Switcher

一个用于管理多个 Neovim 配置 profile 的 Python 脚本。

## 功能特性

- 使用 Click 包提供友好的命令行界面
- 支持多个 Neovim 配置 profile 的快速切换
- 自动管理符号链接，确保配置的一致性
- 自动清理 state 和 cache 目录，避免配置冲突

## 安装依赖

```bash
pip install -r requirements.txt
```

## 使用方法

### 列出所有可用的 profile

```bash
python nvim-switch.py list
```

### 切换到指定 profile

```bash
python nvim-switch.py switch <profile_name>
```

### 查看帮助信息

```bash
python nvim-switch.py --help
python nvim-switch.py list --help
python nvim-switch.py switch --help
```

## Profile 目录结构

每个 profile 需要包含以下目录结构：

```
~/.config/nvim-profiles/
└── your_profile/
    ├── config/     # Neovim 配置文件 (必须)
    ├── share/      # Neovim 数据文件 (必须)
    ├── state/      # 状态文件 (可选，会被删除)
    └── cache/      # 缓存文件 (可选，会被删除)
```

## 工作原理

1. **配置链接**: 将 `~/.config/nvim` 链接到 profile 的 `config` 目录
2. **数据链接**: 将 `~/.local/share/nvim` 链接到 profile 的 `share` 目录
3. **清理缓存**: 删除 `~/.local/state/nvim` 和 `~/.cache/nvim` 目录，确保新配置生效

## 注意事项

- 脚本会自动删除现有的符号链接或目录
- state 和 cache 目录会被完全删除，以确保新配置的纯净性
- 建议在切换 profile 前备份重要的配置数据 