local utils = require("utils")
require("telescope").load_extension("lazygit")

utils.fn.require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-j>"] = "move_selection_next",
				["<C-k>"] = "move_selection_previous",
				["<C-g>"] = "close",
			},
		},
	},
	pickers = {},
	extensions = {},
})

