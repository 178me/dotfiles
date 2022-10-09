local basic = {}

basic.options = {
	["tab宽度"] = { { "opt|tabstop", 2 }, { "opt|shiftwidth", 2 } },
	["智能缩进"] = { { "o|autoindent", true }, { "o|smartindent", true } },
	["鼠标模式"] = { "o|mouse", "a" },
	["自动换行"] = { "wo|wrap", true },
	["显示行号"] = { "wo|number", true },
	["智能补全"] = { "o|wildmenu", true },
	["更新时间"] = { "o|updatetime", 300 },
	["超时时间"] = { "o|timeoutlen", 300 },
	["tab转space"] = { "opt|expandtab", true },
	["python路径"] = { "g|python3_host_prog", "/usr/bin/python" },
	["命令行行高"] = { "o|cmdheight", 2 },
	["自动刷新文件"] = { { "o|autoread", true }, { "bo|autoread", true } },
	["swap文件路径"] = { "o|swapfile", false },
	["默认分割方向"] = { { "o|splitbelow", true }, { "o|splitright", true } },
	["文件编码格式"] = { { "o|encoding", "utf-8" }, { "o|encoding", "utf-8" } },
	["搜索高亮选项"] = {
		{ "o|ignorecase", true },
		{ "o|smartcase", true },
		{ "o|hlsearch", true },
		{ "o|incsearch", true },
	},
	["backup文件路径"] = { { "o|backup", false }, { "o|writebackup", false } },
	["上下屏幕距离行数"] = { "o|scrolloff", 8 },
	["左右屏幕距离列数"] = { "o|sidescrolloff", 5 },
	["在左侧显示符号列"] = { "wo|signcolumn", "yes" },
	["修改空格和Tab为符号"] = { { "o|list", true }, { "o|listchars", "tab:▸\\ ,trail:▫" } },
	["避免不必要的重新绘制"] = { "g|lazyredraw", true },
}

basic.set_nvim_option = function(option)
	local key1, key2 = string.match(option[1], "([^|]*)|?(.*)")
	vim[key1][key2] = option[2]
	-- print(vim[key1][key2],key1,key2)
end

basic.load_options = function()
	for _, value in pairs(basic.options) do
		-- 加载单个选项
		if type(value[1]) == "string" then
			basic.set_nvim_option(value)
		elseif type(value[1]) == "table" then
			-- 加载多个选项
			for key2 in pairs(value) do
				basic.set_nvim_option(value[key2])
			end
		end
		-- print("成功:", key)
	end
end

basic.load_autocmd = function()
	-- vim.cmd("markdownLinkText xxx gui='#121122' guifg='#222222'")
	vim.cmd("setf i3config")
	vim.cmd("syntax on")
	vim.cmd("map J <nop>")
	-- colorscheme
	vim.g.tokyonight_transparent = true
	vim.g.tokyonight_transparent_sidebar = true
	vim.g.tokyonight_dark_sidebar = false
	vim.g.tokyonight_dark_float = false
	vim.g.tokyonight_style = "storm"
	vim.cmd([[colorscheme tokyonight]])
	-- vim.highlight.create("LineNr", { guifg = "#00ff0d" }, false)
	vim.api.nvim_set_hl("LineNr", { guifg = "#00ff0d" }, false)
	vim.cmd([[
    augroup remember_folds
        autocmd!
        au BufWinLeave ?* mkview 1
        au BufWinEnter ?* silent! loadview 1
    augroup END
]])
	-- spell check
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		pattern = { "*.md" },
		callback = function()
			vim.cmd([[set spell]])
		end,
	})
end

basic.main = function()
	pcall(basic.load_options)
	pcall(basic.load_autocmd)
end

pcall(basic.main)
