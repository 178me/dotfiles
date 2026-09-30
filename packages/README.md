# 工具环境备份与恢复

`snapshots/local.json` 是本机环境盘点，包含全部 Arch 包版本、显式安装包及
外部包名称、各 Node/Python 环境的全局依赖、Go 工具版本，以及 Shell 插件提交。
不包含认证文件、缓存或工具二进制。

刷新盘点：

```bash
python3 script/toolchain/snapshot.py --output packages/snapshots/local.json
```

## 在 Arch 设备上恢复工具

从仓库根目录运行。默认只显示计划，不执行安装：

```bash
bash script/bootstrap-arch.sh
bash script/bootstrap-arch.sh --language-tools --all-runtimes
```

实际安装共享 CLI、Oh My Zsh、两个 Zsh 插件、与当前配置兼容的旧版 asdf，
以及全局选择的 Node 20.17.0：

```bash
bash script/bootstrap-arch.sh --apply
```

可选范围可以组合：

- `--desktop`：追加终端、输入法、i3/Sway 等配置对应的桌面工具。
- `--all-runtimes`：安装已记录的 3 个 Node 版本与 4 个 pyenv Python 版本。
- `--language-tools`：按记录版本安装选中 Node 环境的 npm 工具、pnpm 全局工具与 Go 工具。
- `--snapshot PATH`：使用其他盘点文件。
- `--skip-system-packages`：系统包已由用户安装时，继续用户目录中的工具恢复。

`--apply` 使用交互式 `sudo pacman -Syu --needed`，刷新包数据库时同时进行完整系统升级，
因此 Arch 包使用目标仓库当时的版本；原机版本留在快照中作为参考。
Oh My Zsh、插件和 asdf 使用盘点中的确切提交；已有安装若提交不同会提前停止，
应先决定沿用或迁移，不会自动覆盖已有安装。

脚本应以目标设备的普通用户运行，仅系统包安装使用 sudo。
工具准备完成后，再检查并应用 chezmoi 配置；脚本不执行配置应用或修改默认 Shell。
共享 Shell 和 CLI 配置使用当前用户目录；历史桌面/旧 Neovim profile 的机器专属设置仍需单独检查。

安装完工具后，预览并应用 CLI 配置：

```bash
bash script/apply-cli.sh
bash script/apply-cli.sh --apply
```

应用前会将已有目标配置打包到 `~/.local/state/dotfiles/backups/`，并选择当前备份的
`nvim-lazy` 作为 Neovim 配置。此入口不覆盖 SSH 私钥、Codex 根目录登录文件、
系统 `/etc` 或 i3/Sway 的机器专属桌面配置。

## 需要单独恢复的部分

- `@lazycatcloud/lzc-cli` 在 3 个 Node 环境中均为指向本机源码的开发链接。
  脚本会提示并跳过，需要先获取对应项目，再执行该项目的链接流程。
- Python 包按解释器分别记录在快照中。系统 Python 优先由 pacman 管理；
  pyenv 包包含项目和桌面依赖，应按实际需要在对应环境安装，脚本不批量重装 pip 清单。
- 外部/AUR 软件及未被共享清单选中的桌面、驱动、内核软件仅留档，不自动批量安装。
- Go 工具如没有可恢复的模块版本，安装时会提示手动处理。
- 快照包含工具版本和公开源码提交，不代表精确复制系统镜像；旧 Python 构建也可能受目标系统库影响。

安装清单：`arch-cli.txt` 是共享开发环境，`arch-desktop.txt` 是可选桌面工具，
`arch-python-build.txt` 是编译 pyenv Python 时的额外系统依赖。

实现参考：[pacman 使用手册](https://man.archlinux.org/man/pacman.8)、
[pyenv 安装说明](https://github.com/pyenv/pyenv#installation)、
[Oh My Zsh 手动安装说明](https://github.com/ohmyzsh/ohmyzsh#manual-installation)。
