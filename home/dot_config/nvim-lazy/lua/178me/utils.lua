local M = { fn = {}, var = {} }

M.fn.print_diagnostics = function()
  local buf = vim.api.nvim_get_current_buf()
  local line_num = (vim.api.nvim_win_get_cursor(0)[1] - 1)
  local msg = vim.lsp.diagnostic.get_line_diagnostics(buf, line_num)
  print(vim.inspect(msg))
  vim.cmd("message")
end

M.fn.test = function()
  package.loaded["utils"] = nil
  package.loaded["window.components"] = nil
  vim.inspect(vim.lsp.buf.code_action({
    apply = true,
    filter = function(val)
      if val.title == "Delete all unused imports" then
        return true
      end
      return false
    end,
  }))
  -- vim.inspect(vim.lsp.buf.code_action({
  -- 	apply = true,
  -- 	filter = function(val)
  -- 		if val.title == "Delete all unused imports" then
  -- 			return true
  -- 		end
  -- 		return false
  -- 	end,
  -- }))
  -- print(vim.inspect(get_visual()))
  -- require("window.components").input(function(text)
  -- 	print(a, text)
  -- 	-- vim.fn.jobstart({ "xdg-open", string.format("https://google.com/search?q=%s", text) }, { detach = true })
  -- end)
end

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
M.fn.require = function(package_name, print_error)
  local status, package = pcall(require, package_name)
  if print_error and not status then
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
  local script_path = vim.fn.expand("~/Desktop/python-frame/script/jgy_upload.py")
  vim.api.nvim_command("0TermExec open=0 cmd='python " .. script_path .. " %:p'")
end

M.fn.new_file = function()
  vim.ui.input({ prompt = "new file: " }, function(filename)
    if not filename then
      return
    end
    local command = "edit " .. vim.fn.expand("%:p:h") .. "/" .. filename
    vim.api.nvim_command(command)
  end)
end

M.fn.replace_global = function()
  local a = vim.fn.getreg("a")
  local b = vim.fn.getreg("b")
  a = string.gsub(a, "/", "\\/")
  b = string.gsub(b, "/", "\\/")
  local command = ":%s/\\V" .. a .. "/" .. b .. "/g"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(command, true, false, true), "t", true)
end

M.fn.replace = function()
  local a = vim.fn.getreg("a")
  local b = vim.fn.getreg("b")
  a = string.gsub(a, "/", "\\/")
  b = string.gsub(b, "/", "\\/")
  local command = ":s/\\V" .. a .. "/" .. b .. "/g"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(command, true, false, true), "t", true)
end

M.fn.look_ref = function()
  local index = string.find(vim.fn.expand("%:h"), "src")
  local path = string.sub(vim.fn.expand("%:h"), index)
  local command = "CtrlSF " .. string.gsub(path, "src", "@") .. "/" .. vim.fn.expand("%:t:r")
  print(command)
  vim.api.nvim_command(command)
end

M.fn.look_str = function()
  local a = vim.fn.getreg("a")
  a = string.gsub(a, " ", "\\ ")
  local command = "CtrlSF " .. a
  print(command)
  vim.api.nvim_command(command)
end

-- 运行代码
M.fn.runCode = function()
  vim.api.nvim_command("w")
  local filetype = vim.bo.filetype
  if filetype == "python" then
    vim.api.nvim_command("0TermExec size=15 direction=horizontal go_back=1 cmd='cd %:p:h && python %:t'")
  end
end

M.fn.runTempCode = function()
  local filetype = vim.bo.filetype
  if filetype == "python" then
    vim.cmd.edit(vim.fn.expand("~/repo/178me/py-project-frame/demo/temp/main.py"))
  end
  if filetype == "go" then
    vim.api.nvim_command("0TermExec size=15 direction=horizontal go_back=1 cmd='cd %:p:h && go test %:t'")
  end
end

-- 运行测试
M.fn.runTest = function()
  local filetype = vim.bo.filetype
  if filetype == "python" then
    local root_path = M.fn.rootPattern("/Pipfile")
    vim.api.nvim_command(
      "0TermExec size=15 direction=horizontal go_back=1 cmd='cd " .. root_path .. " && pytest -s -m testing" .. "'"
    )
  end
  if filetype == "go" then
    vim.api.nvim_command("0TermExec size=15 direction=horizontal go_back=1 cmd='cd %:p:h && go test'")
  end
end

-- 运行项目
M.fn.runProject = function()
  vim.api.nvim_command("w")
  local filetype = vim.bo.filetype
  if filetype == "python" then
    local root_path = M.fn.rootPattern("/Pipfile")
    vim.api.nvim_command(
      "0TermExec size=70 direction=vertical go_back=1 cmd='cd " .. root_path .. " && pipenv run dev'"
    )
  end
end

M.get_current_filename = function()
  -- 获取当前缓冲区的绝对路径
  local filename = vim.fn.expand("%:p")
  -- 找到项目根目录标识（这里假设项目根目录包含 package.json 或 .git）
  local root_patterns = { "package.json", ".git" }
  local root_dir = nil
  for _, pattern in ipairs(root_patterns) do
    local found = vim.fs.find(pattern, { path = filename, upward = true })[1]
    if found then
      root_dir = vim.fs.dirname(found)
      break
    end
  end
  if not root_dir then
    return "" -- 或者返回默认值/报错
  end
  -- 获取相对于项目根目录的路径
  local relative_path = filename:sub(#root_dir + 2) -- +2 跳过斜杠
  -- 分割路径并处理每个部分
  local parts = {}
  for part in relative_path:gmatch("[^/]+") do
    -- 移除文件扩展名（如果是最后一部分）
    if part == relative_path:match("[^/]+$") then
      part = vim.fn.fnamemodify(part, ":r")
      -- 特别处理文件名部分：驼峰转蛇形
      part = part:gsub("([a-z])([A-Z])", "%1_%2"):lower()
    end

    -- 将所有非字母数字字符转换为下划线，并转为小写
    part = part:gsub("[^%w]", "_"):lower()
    -- 合并连续的下划线
    part = part:gsub("_+", "_")
    -- 移除开头和结尾的下划线
    part = part:gsub("^_", ""):gsub("_$", "")

    table.insert(parts, part)
  end
  -- 用点连接各部分
  return table.concat(parts, ".")
end

M.fn.insert_filename_at_cursor = function()
  -- 处理驼峰命名
  local new_filename = M.get_current_filename()
  -- 加一个.
  new_filename = new_filename .. "."
  -- 在光标位置插入处理后的文件名
  vim.api.nvim_put({ new_filename }, "c", false, true)
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
  local _ = string.gsub(str, "[^" .. reps .. "]+", function(w)
    table.insert(resultStrList, w)
  end)
  return resultStrList
end

M.get_visual_text = function()
  local _, ls, cs = unpack(vim.fn.getpos("v"))
  local _, le, ce = unpack(vim.fn.getpos("."))
  local l1, c1, l2, c2 = math.min(ls, le), math.min(cs, ce), math.max(ls, le), math.max(cs, ce)
  return table.concat(vim.api.nvim_buf_get_text(0, l1 - 1, c1 - 1, l2 - 1, c2, {}))
end

M.get_current_module_name = function(is_dir)
  local module_path = debug.getinfo(2, "S").source -- 获取模块路径
  if module_path:sub(1, 1) == "@" then
    module_path = module_path:sub(2) -- 去掉前面的 @ 符号
  end
  local module_name = module_path:gsub("/", "."):gsub("%.lua$", "") -- 将路径中的 / 转为.，去掉 .lua 后缀
  local prefix = module_name:match("^%..+%.lua%.") -- 匹配前缀，注意括号里的内容要根据你的实际情况修改
  if prefix then
    module_name = module_name:gsub(prefix, "") -- 如果匹配到了前缀，去掉前缀部分
  end
  -- 是否是目录模块
  if is_dir then
    module_name = module_name:gsub(".init", "")
  end
  return module_name
end

M.fn.process_i18n_tags = function()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local filename_key = M.get_current_filename()
  local i18n_entries = {}

  -- 检查当前是否在 setup() 函数内
  local in_setup = false
  for _, line in ipairs(lines) do
    if line:match("setup%(%s*[%){]") then
      in_setup = true
      break
    end
  end

  -- 获取当前光标位置（行号，0-based）
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local insert_line = cursor_pos[1] -- 直接在光标行下方插入

  -- 收集所有i18n标签并准备替换
  for i, line in ipairs(lines) do
    local modified_line = line
    for text in line:gmatch("<i18n>(.-)</i18n>") do
      local key = filename_key .. "." .. string.char(#i18n_entries + 97) -- a, b, c...
      table.insert(i18n_entries, {
        key = key,
        text = text,
        line = i - 1, -- 0-based
        original = line,
      })
      -- 根据是否在 setup 内决定是否加 {}
      local replacement = in_setup and "{i18nText['%1']}" or "i18nText['%1']"
      modified_line = modified_line:gsub("<i18n>(.-)</i18n>", replacement)
    end
    if modified_line ~= line then
      lines[i] = modified_line
    end
  end

  if #i18n_entries == 0 then
    print("No <i18n> tags found")
    return
  end

  -- 生成i18nText对象（分开每行）
  local i18n_text_lines = {
    "const i18nText = {",
  }
  for _, entry in ipairs(i18n_entries) do
    table.insert(i18n_text_lines, string.format("  '%s': t('%s', '%s'),", entry.text, entry.key, entry.text))
  end
  table.insert(i18n_text_lines, "};")

  -- 在光标下方插入i18nText定义（逐行插入）
  for i, line in ipairs(i18n_text_lines) do
    table.insert(lines, insert_line + i, line)
  end

  -- 应用所有修改
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  print(string.format("Processed %d i18n tags", #i18n_entries))
end

M.fn.wrap_selection_with_i18n = function()
  -- 1. 获取选择的文本
  local selection = GetSelectedText()
  -- 2. 处理文本
  -- a. 清除开头结尾的空格和引号
  local processed = selection:gsub("^['\"%s]+", ""):gsub("['\"%s]+$", "")
  -- b. 包裹i18n标签
  local wrapped = "<i18n>" .. processed .. "</i18n>"
  -- 3. 删除当前选择文本
  vim.cmd("normal! gvdh")
  -- 4. 插入处理后的文本
  vim.api.nvim_put({ wrapped }, "c", true, true)
end

-- 获取当前选择的文本
function GetSelectedText()
  -- 保存当前寄存器内容
  local saved_reg = vim.fn.getreg('"')
  local saved_regtype = vim.fn.getregtype('"')

  -- 使用 normal 命令 yank 选择内容到寄存器
  vim.cmd("silent normal! y")

  -- 获取选择的文本
  local selection = vim.fn.getreg('"')

  -- 恢复寄存器内容
  vim.fn.setreg('"', saved_reg, saved_regtype)

  return selection
end

function GetVisualSelection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)

  -- 调整第一行和最后一行的内容
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end

  return table.concat(lines, "\n")
end

return M
