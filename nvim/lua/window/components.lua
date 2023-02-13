local M = {}
local api = vim.api

M.completeFn = function(_) end
M.close = function()
	local _, winid = pcall(api.nvim_win_get_var, 0, "my-window-id")
	vim.cmd([[stopinsert]])
	api.nvim_win_close(winid, true)
end

M.finish = function()
	local input_text = vim.trim(vim.fn.getline("."))
	M.completeFn(input_text)
	M.close()
end

M.input = function(completeFn)
	local bufnr = vim.api.nvim_create_buf(false, true)
	local winid = vim.api.nvim_open_win(bufnr, true, {
		anchor = "NW",
		border = "single",
		col = 0,
		height = 1,
		relative = "cursor",
		row = 1,
		style = "minimal",
		width = 29,
	})
	api.nvim_win_set_option(winid, "winhl", "Normal:LspFloatWinNormal,FloatBorder:LspSagaRenameBorder")
	api.nvim_win_set_var(0, "my-window-id", winid)
	vim.cmd([[startinsert!]])
	-- vim.fn.feedkeys("hslfsdhhh")
	M.completeFn = completeFn
	api.nvim_command("inoremap <buffer><nowait>" .. "<Esc>" .. " <cmd>lua require('window.components').close()<CR>")
	api.nvim_command("inoremap <buffer><nowait>" .. "<Enter>" .. " <cmd>lua require('window.components').finish()<CR>")
end

return M
