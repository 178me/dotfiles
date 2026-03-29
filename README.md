# dotfiles (chezmoi)

个人配置仓库，使用 `chezmoi` 统一管理用户级配置（`home/`）和系统级配置（`system/`）。

## 目录说明

- `home/`: 用户配置 source state（最终应用到 `~`）
- `system/etc/`: 系统配置 source state（最终应用到 `/etc`）
- `script/`: 常用辅助脚本（包含一键同步脚本）

仓库根目录通过 `.chezmoiroot` 指向 `home/`，因此根目录中的脚本和文档不会被同步到家目录。

## 依赖

- `chezmoi`
- `git`
- 同步 `system` 配置时需要 `sudo`

## 一键同步

```bash
# 仅同步 home（默认）
bash script/chezmoi-sync.sh

# 仅预览变更（不写入）
bash script/chezmoi-sync.sh --dry-run

# 同步 home + system(/etc)
bash script/chezmoi-sync.sh --with-system
```

## 无感工作流（推荐）

`home/dot_zshrc` 已内置两个别名：

- `cmx-apply`: 一键应用配置（等价于 `bash script/chezmoi-sync.sh`）
- `cmx-save`: 把你在 `~` 下改过的受管文件回写到仓库，自动 `commit` 并 `push`

首次拉取后执行一次：

```bash
chezmoi -S "$HOME/dotfiles" apply
source ~/.zshrc
```

`cmx-save` 常用参数：

```bash
# 仅预览，不写入
cmx-save --dry-run

# 只提交到本地，不推送
cmx-save --no-push

# 自定义提交信息
cmx-save -m "chore: update zsh aliases"
```

## 常用命令

```bash
# 预览 home 变更
chezmoi -S "$HOME/dotfiles" diff

# 应用 home 配置
chezmoi -S "$HOME/dotfiles" apply

# 编辑受管文件
chezmoi -S "$HOME/dotfiles" edit ~/.zshrc

# 查看受管状态
chezmoi -S "$HOME/dotfiles" status
```

## 终端配置

已纳管配置：

- `home/dot_config/wezterm/wezterm.lua` -> `~/.config/wezterm/wezterm.lua`
- `home/dot_config/zellij/config.kdl` -> `~/.config/zellij/config.kdl`

纯 `chezmoi` 同步方式：

```bash
make sync
# 或
chezmoi -S "$HOME/dotfiles" apply
```

## Codex 配置

当前已纳管的 Codex 配置：

- `home/dot_codex/profiles/<name>/private_config.toml` -> `~/.codex/profiles/<name>/config.toml`
- `home/dot_codex/profiles/<name>/private_auth.json` -> `~/.codex/profiles/<name>/auth.json`
- `home/dot_codex/rules/*` -> `~/.codex/rules/*`（全局）
- `home/dot_codex/skills/*` -> `~/.codex/skills/*`（全局）

当前内置 profile 示例：

- `openai`: `home/dot_codex/profiles/openai/*`
- `lzc`: `home/dot_codex/profiles/lzc/*`

切换方式（通过 `codex-select` 建立软链）：

```bash
make codex-select
# 或
bash script/codex-profile.sh --select
```

效果：`~/.codex/config.toml` 与 `~/.codex/auth.json` 会软链到选中的 profile 文件。

说明：`history.jsonl`、`sessions/`、`logs_*.sqlite`、`state_*.sqlite` 等运行时文件不纳管；根目录的 `config.toml`/`auth.json` 也不直接纳管。
注意：`auth.json` 含密钥，建议仅在私有仓库中管理，或改为 `chezmoi` 加密文件。

## 系统配置

当前 system 受管文件：

- `system/etc/pacman.conf` -> `/etc/pacman.conf`
- `system/etc/udev/hwdb.d/99-personal-kbd.hwdb` -> `/etc/udev/hwdb.d/99-personal-kbd.hwdb`

可单独应用：

```bash
sudo chezmoi -S "$HOME/dotfiles/system" -D / apply
```

## Neovim 配置切换

仓库保留两个 profile：

- `home/dot_config/nvim-178me`
- `home/dot_config/nvim-lazy`

切换脚本：`script/switch_nvim.py`
