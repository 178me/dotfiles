# dotfiles (chezmoi)

这个仓库已从 `GNU stow` 迁移到 `chezmoi`。

## 目录说明

- `home/`: chezmoi source state（`~` 下的配置都在这里）
- `system/`: 系统级配置样例（`/etc`），默认不会由 chezmoi 应用
- `script/`: 辅助脚本（不由 chezmoi 直接管理）

仓库根目录通过 `.chezmoiroot` 指向 `home/`，这样根目录的文档和脚本不会被 `chezmoi apply` 同步到家目录。

## 快速开始

```bash
# 首次在本机使用这个仓库
chezmoi init --source="$HOME/dotfiles"

# 预览变更
chezmoi diff

# 应用到当前用户目录
chezmoi apply
```

## 常用工作流

```bash
# 编辑受管文件（推荐）
chezmoi edit ~/.zshrc

# 查看 source state 目录
chezmoi cd

# 查看本次会改动什么
chezmoi diff

# 应用配置
chezmoi apply
```

## 迁移后主要映射

- `home/dot_zshrc` -> `~/.zshrc`
- `home/dot_gitconfig` -> `~/.gitconfig`
- `home/dot_xprofile` -> `~/.xprofile`
- `home/dot_pip/pip.conf` -> `~/.pip/pip.conf`
- `home/dot_ssh/private_config` -> `~/.ssh/config` (private 权限)
- `home/dot_config/*` -> `~/.config/*`

## 系统级配置

`system/` 采用 `etc/...` 布局，可用于 root 级 chezmoi，或按需手工同步到 `/etc`：

```bash
sudo install -Dm644 system/etc/pacman.conf /etc/pacman.conf
sudo install -Dm644 system/etc/udev/hwdb.d/99-personal-kbd.hwdb /etc/udev/hwdb.d/99-personal-kbd.hwdb
```

## Neovim 配置切换

仓库保留了两个 profile：

- `home/dot_config/nvim-178me`
- `home/dot_config/nvim-lazy`

`script/switch_nvim.py` 已更新为新路径结构，可继续用于切换软链接。
