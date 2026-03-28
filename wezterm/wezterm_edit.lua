-- 加载 wezterm API 和获取 config 对象
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-------------------- 窗口配置 --------------------
-- 窗口装饰：恢复标题栏以显示圆角效果
config.window_decorations = "TITLE | RESIZE"

-- 窗口尺寸
config.initial_cols = 100    -- 初始列数（宽度）
config.initial_rows = 30     -- 初始行数（高度）

-- 窗口圆角配置
config.window_background_opacity = 1  -- 半透明背景，圆角效果更明显
config.macos_window_background_blur = 15 -- 背景模糊效果

-- 窗口内边距（可选，增加圆角视觉效果）
config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 10,
}

-- 窗口框架样式（移除边框以显示圆角）
config.window_frame = {
	-- 活动窗口边框颜色
	active_titlebar_bg = "#2b2042",
	-- 非活动窗口边框颜色
	inactive_titlebar_bg = "#1a1b26",
	-- 移除边框以显示圆角效果
	border_left_width = 0,
	border_right_width = 0,
	border_top_height = 0,
	border_bottom_height = 0,
}

-------------------- 标签栏配置 --------------------
-- 启用标签栏
config.enable_tab_bar = true

-- 标签栏位置：放在底部
config.tab_bar_at_bottom = true

-- 标签栏显示选项
config.show_tab_index_in_tab_bar = true        -- 显示标签索引（数字）
config.hide_tab_bar_if_only_one_tab = true     -- 只有一个标签时隐藏标签栏
config.show_new_tab_button_in_tab_bar = true   -- 显示新建标签按钮
config.use_fancy_tab_bar = false               -- 使用简洁的标签栏样式
config.tab_max_width = 25                      -- 标签最大宽度

-------------------- 字体配置 --------------------
-- 字体大小
config.font_size = 12

-- 字体配置 - 解决缺失字符问题
config.font = wezterm.font_with_fallback({
	-- 主字体，支持中文和英文
	"JetBrainsMono Nerd Font Mono",
	-- 备用字体，确保特殊字符能正常显示
	"Noto Sans CJK SC",
	"Noto Sans CJK TC",
	"Noto Sans CJK JP",
	"Noto Sans CJK KR",
	-- 系统默认字体作为最后的备用
	"DejaVu Sans Mono",
})

-- 禁用缺失字符的警告信息
config.warn_about_missing_glyphs = false

-------------------- 颜色主题配置 --------------------
-- 设置颜色主题
config.color_scheme = "tokyonight_storm"

-- 设置非活动窗格的色调、饱和度和亮度
config.inactive_pane_hsb = {
	saturation = 0.9,  -- 饱和度设为90%
	brightness = 0.8,  -- 亮度设为80%
}

-------------------- 键盘快捷键配置 --------------------
local act = wezterm.action

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

-- 定义键盘快捷键
config.keys = {
	-- 窗格操作
	{ key = "h", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "q", mods = "CTRL", action = act.CloseCurrentPane({ confirm = false }) },

	-- 窗格切换
	{ key = "l", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Down") },

	-- 标签和窗口操作
	{ key = "t", mods = "CTRL", action = act.SpawnTab("DefaultDomain") },           -- Ctrl+T 新建标签
	{ key = "T", mods = "CTRL|SHIFT", action = act.SpawnWindow },                   -- Ctrl+Shift+T 新建窗口

	-- 粘贴操作
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },        -- Ctrl+Shift+V 粘贴

	-- 配置重载（运行同步脚本）
	{ key = "r", mods = "CTRL|SHIFT", action = act.SpawnCommandInNewWindow({
		args = { "bash", "-c", "sh ~/dotfiles/wezterm/sync_config.sh" },
	}) },                                                                           -- Ctrl+Shift+R 运行同步脚本
}

-- 为标签1-8设置快捷键：Ctrl + 数字键切换到对应标签
for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL",
		action = act.ActivateTab(i - 1),
	})
end

-------------------- 鼠标配置 --------------------
config.mouse_bindings = {
	-- 复制选中的文本到剪贴板
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},

	-- 打开鼠标光标处的超链接
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

-------------------- 实用配置 --------------------
-- 实用配置
config.scrollback_lines = 10000  -- 增加滚动历史行数
config.scroll_to_bottom_on_input = true  -- 输入时自动滚动到底部
config.automatically_reload_config = true  -- 重新启用配置文件热更新（配合外部编辑方案）

-- 9. 滚动配置
config.scrollback_lines = 10000  -- 增加滚动历史行数
config.scroll_to_bottom_on_input = true  -- 输入时自动滚动到底部

-- 10. 光标配置
-- config.default_cursor_style = "BlinkingBar"  -- 闪烁竖线光标
-- config.cursor_blink_rate = 1000  -- 光标闪烁频率（毫秒）
-- config.cursor_thickness = 2  -- 光标粗细

-- 13. 自动重载配置
config.automatically_reload_config = true  -- 重新启用配置文件热更新（配合外部编辑方案）

return config
