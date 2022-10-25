local M = { fn = {}, var = {} }

-- find project root
local getPrevLevelPath = function(currentPath)
	local tmp = string.reverse(currentPath)
	local _, i = string.find(tmp, "/")
	return string.sub(currentPath, 1, string.len(currentPath) - i)
end

M.fn.rootPattern = function(pattern)
	pattern = pattern or "/.git"
	local path = vim.fn.getcwd(-1, -1)
	local pathBp = path
	while path ~= "" do
		local file, _ = io.open(path .. pattern)
		if file ~= nil then
			return path
		else
			path = getPrevLevelPath(path)
		end
	end
	return pathBp
end

-- set keymap
M.fn.map = vim.api.nvim_set_keymap
M.var.opt = { noremap = true, silent = true }
M.fn.whichKeyMap = require("which-key").register

-- load config
M.fn.loadConfig = function(configs)
	for _, value in pairs(configs) do
		local status, rel = pcall(require, value)
		if not status then
			print("Error: failed to load config " .. value)
			print(rel)
		end
	end
end

-- `require` with error handling
M.fn.require = function(package_name)
	local status, package = pcall(require, package_name)
	if not status then
		print("Error: package " .. package_name .. " not found")
	end
	return package
end

-- merge table
-- if override is true, table2 will override table1 (default to false)
M.fn.mergeTable = function(table1, table2, override)
	override = override or false
	local res = {}
	for key, value in pairs(table1) do
		res[key] = value
	end
	for key, value in pairs(table2) do
		if res[key] == nil then
			res[key] = value
		else
			if override == true then
				res[key] = value
			end
		end
	end
	return res
end

-- 运行脚本
M.fn.runScript = function()
	local script_path = "/home/yzl178me/Desktop/python-frame/script/jgy_upload.py"
	vim.api.nvim_command("0TermExec open=0 cmd='python " .. script_path .. " %:p'")
end

M.fn.new_file = function()
	vim.ui.input({ prompt = "new file: " }, function(filename)
		local command = "edit " .. vim.fn.expand("%:p:h") .. "/" .. filename
		vim.api.nvim_command(command)
	end)
end

M.fn.replace_global = function()
  local a = vim.fn.getreg("a")
  local b = vim.fn.getreg("b")
  a = string.gsub(a,"/","\\/")
  b = string.gsub(b,"/","\\/")
	local command = ":%s/\\V" .. a .. "/" .. b .. "/g"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(command, true, false, true), "t", true)
end

M.fn.replace = function()
  local a = vim.fn.getreg("a")
  local b = vim.fn.getreg("b")
  a = string.gsub(a,"/","\\/")
  b = string.gsub(b,"/","\\/")
	local command = ":s/\\V" .. a .. "/" .. b .. "/g"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(command, true, false, true), "t", true)
end

M.fn.test = function()
 --  local a = vim.fn.getreg("a")
	-- local command = "CtrlSF " .. a
 --  vim.api.nvim_command(command)
end

-- 运行代码
M.fn.runCode = function()
	local filetype = vim.bo.filetype
	if filetype == "python" then
		vim.api.nvim_command("0TermExec size=70 direction=vertical go_back=1 cmd='cd %:p:h && python %:t'")
	end
end

-- 运行项目
M.fn.runProject = function()
	local filetype = vim.bo.filetype
	if filetype == "python" then
		local root_path = M.fn.rootPattern("/Pipfile")
		vim.api.nvim_command(
			"0TermExec size=70 direction=vertical go_back=0 cmd='cd " .. root_path .. " && pipenv run dev'"
		)
	end
end

-- 打印表格
M.fn.pprint = function(...)
	local info = ""
	for i = 1, select("#", ...) do
		local arg = select(i, ...)
		if type(arg) == "table" then
			arg = vim.inspect(arg)
			info = info .. "\n" .. arg
		else
			if i == 1 then
				info = info .. arg
			else
				info = info .. " " .. arg
			end
		end
	end
	print(info)
end

M.fn.split = function(str, reps)
	local resultStrList = {}
	string.gsub(str, "[^" .. reps .. "]+", function(w)
		table.insert(resultStrList, w)
	end)
	return resultStrList
end

return M
