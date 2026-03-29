.DEFAULT_GOAL := menu

# 本地目录变量
SCRIPTS_DIR := ./script
PYTHON := python3
BASH := bash

# 脚本路径变量
CHEZMOI_SYNC_SCRIPT := $(SCRIPTS_DIR)/chezmoi-sync.sh
CHEZMOI_SAVE_SCRIPT := $(SCRIPTS_DIR)/chezmoi-save.sh
CODEX_PROFILE_SCRIPT := $(SCRIPTS_DIR)/codex-profile.sh
SWITCH_NVIM_SCRIPT := $(SCRIPTS_DIR)/switch_nvim.py
NVIM_SWITCH_SCRIPT := $(SCRIPTS_DIR)/nvim-switch.py

# 运行辅助函数
# $(call run_shell,script,args)
define run_shell
	@if [ ! -f $(1) ]; then \
		echo "错误: $(1) 脚本不存在"; \
		exit 1; \
	fi; \
	chmod +x $(1); \
	$(BASH) $(1) $(2)
endef

# $(call run_python,script,args)
define run_python
	@if [ ! -f $(1) ]; then \
		echo "错误: $(1) 脚本不存在"; \
		exit 1; \
	fi; \
	$(PYTHON) $(1) $(2)
endef

.PHONY: init \
	sync sync-dry-run sync-system sync-system-dry-run \
	save save-dry-run save-local save-msg \
	codex-select \
	nvim-178me nvim-lazy nvim-list nvim-switch \
	help menu

# 0. 初始化
init:
	@echo "初始化完成（当前仓库无需额外目录创建）"

# 1. dotfiles 同步与保存
sync:
	@$(call run_shell,$(CHEZMOI_SYNC_SCRIPT),)

sync-dry-run:
	@$(call run_shell,$(CHEZMOI_SYNC_SCRIPT),--dry-run)

sync-system:
	@$(call run_shell,$(CHEZMOI_SYNC_SCRIPT),--with-system)

sync-system-dry-run:
	@$(call run_shell,$(CHEZMOI_SYNC_SCRIPT),--with-system --dry-run)

save:
	@$(call run_shell,$(CHEZMOI_SAVE_SCRIPT),)

save-dry-run:
	@$(call run_shell,$(CHEZMOI_SAVE_SCRIPT),--dry-run)

save-local:
	@$(call run_shell,$(CHEZMOI_SAVE_SCRIPT),--no-push)

# 用法: make save-msg MSG="chore: update zsh aliases"
save-msg:
	@if [ -z "$(MSG)" ]; then \
		echo "错误: 缺少 MSG 参数。示例: make save-msg MSG=\"chore: update zsh aliases\""; \
		exit 1; \
	fi
	@$(call run_shell,$(CHEZMOI_SAVE_SCRIPT),--message "$(MSG)")

# 2. Codex / Neovim
codex-select:
	@$(call run_shell,$(CODEX_PROFILE_SCRIPT),--select)

nvim-178me:
	@$(call run_python,$(SWITCH_NVIM_SCRIPT),178me)

nvim-lazy:
	@$(call run_python,$(SWITCH_NVIM_SCRIPT),lazy)

nvim-list:
	@$(call run_python,$(NVIM_SWITCH_SCRIPT),list)

# 用法: make nvim-switch <profile>
nvim-switch:
	@$(call run_python,$(NVIM_SWITCH_SCRIPT),switch $(filter-out $@,$(MAKECMDGOALS)))

# 额外参数声明为伪目标，避免 make 将参数识别为文件目标
.PHONY: $(filter-out \
	init \
	sync sync-dry-run sync-system sync-system-dry-run \
	save save-dry-run save-local save-msg \
	codex-select \
	nvim-178me nvim-lazy nvim-list nvim-switch \
	help menu,$(MAKECMDGOALS))

# 命令列表定义
define COMMANDS
=== 初始化 ===
init                 - 初始化（校验 make 工作流）

=== dotfiles 同步 ===
sync                 - 同步 home 配置（chezmoi apply）
sync-dry-run         - 仅预览 home 变更（chezmoi diff）
sync-system          - 同步 home + system(/etc)
sync-system-dry-run  - 仅预览 home + system 变更
save                 - 回写 home 变更并 commit + push
save-dry-run         - 仅预览回写结果与 git status
save-local           - 回写并仅本地 commit（不 push）
save-msg             - 回写并使用 MSG 作为 commit 信息

=== Codex / Neovim ===
codex-select         - 交互选择 profile 并应用
nvim-178me           - 切换到仓库内 nvim-178me 配置
nvim-lazy            - 切换到仓库内 nvim-lazy 配置
nvim-list            - 列出 ~/.config/nvim-profiles 下的 profile
nvim-switch          - 切换到指定 nvim profile（示例: make nvim-switch work）

=== 帮助 ===
help                 - 显示所有命令
menu                 - fzf 交互式命令菜单
endef
export COMMANDS

# 帮助信息
help:
	@echo "$$COMMANDS" | sed '/^[[:space:]]*$$/b; /^===/b; s/^/  make /'

# 交互式菜单
menu:
	@command -v fzf >/dev/null 2>&1 || { echo "请先安装 fzf: brew install fzf 或 sudo pacman -S fzf"; exit 1; }
	@clear
	@echo "选择一个命令执行，支持模糊搜索，按 ESC 退出"
	@selected=$$(echo "$$COMMANDS" | \
		grep -v "^===" | \
		grep -v "^$$" | \
		awk -F ' - ' '{print $$1}' | \
		fzf --height=40% \
			--layout=reverse \
			--border \
			--prompt="选择要执行的命令: " \
			--preview="echo \"$$COMMANDS\" | grep -E '^{}[[:space:]]+-' | awk -F ' - ' '{print \\$2}'" \
			--preview-window=up:3:wrap); \
	if [ -n "$$selected" ]; then \
		$(MAKE) $$selected; \
	fi
