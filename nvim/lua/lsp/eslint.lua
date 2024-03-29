local utils = require("utils")

local M = {
	settings = {
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine",
			},
			showDocumentation = {
				enable = true,
			},
		},
		codeActionOnSave = {
			enable = false,
			mode = "all",
		},
		format = true,
		nodePath = "",
		onIgnoredFiles = "off",
		packageManager = "yarn",
		quiet = false,
		rulesCustomizations = {},
		run = "onType",
		useESLintClass = false,
		validate = "on",
		workingDirectory = {
			mode = "location",
		},
	},
	filetypes = {
		"javascript",
		-- "javascriptreact",
		-- "typescript",
		-- "typescriptreact",
	},
	root_dir = utils.fn.rootPattern,
	handlers = {
		["eslint/noLibrary"] = function()
			return {}
		end,
	},
}

return M
