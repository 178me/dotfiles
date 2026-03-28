require("nvim-toggler").setup({
	-- 自定义一些反转
	inverses = {
		["True"] = "False",
		["and"] = "or",
		["&&"] = "||",
	},
	-- removes the default <leader>i keymap
	remove_default_keybinds = true,
})
