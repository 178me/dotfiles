local M = {}
local utils = require("utils")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

M.network_search = function()
	local opts = {}
	local book_marks = {
		{ "google", "https://google.com/search?q=%s" },
		{ "mdn", "https://developer.mozilla.org/zh-CN/search?q=%s" },
		{ "github", "https://github.com/search?q=%s" },
		{ "stackoverflow", "https://stackoverflow.com/search?q=%s" },
	}
	if vim.fn.mode() == "v" then
		opts.default_text = utils.get_visual_text()
	end
	pickers
		.new(opts, {
			prompt_title = "Search",
			finder = finders.new_table({
				results = book_marks,
				entry_maker = function(entry)
					return {
						value = entry[2],
						display = entry[1],
						ordinal = entry[1],
					}
				end,
			}),
			-- sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local url = action_state.get_selected_entry().value or book_marks[1]
					local keyword = action_state.get_current_line()
					actions.close(prompt_bufnr)
					vim.fn.jobstart({ "xdg-open", string.format(url, keyword) }, { detach = true })
				end)
				return true
			end,
		})
		:find()
end

M.mod_pair = function()
	-- 当前下标字符
	local a = vim.api.nvim_eval("matchstr(getline('.'), '\\%' . col('.') . 'c.')")
	require("window.components").input(function(text)
		vim.fn.feedkeys(string.format("cs%s%s", a, text))
	end)
end

return M
