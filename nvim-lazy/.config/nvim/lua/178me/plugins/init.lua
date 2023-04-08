local utils = require("178me.utils")
local tools = require("178me.my-tools")
local plugins = {
  -- 格式化 (basically configured)
  {
    "sbdchd/neoformat",
    keys = {
      { "<leader>jf", ":Neoformat<CR>:w<CR>", desc = "format code", silent = true },
    },
  },
  -- colorizer (basically configured) 高亮颜色组
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufReadPost",
    config = function()
      require("colorizer").setup()
    end,
  },
  -- call sudo in neovim (fully configured) 封装sudo (base)
  {
    "lambdalisue/suda.vim",
    keys = {
      { "<leader>jW", "<cmd>SudaWrite<CR>", desc = "force save" },
    },
  },
  -- quick motion 快速移动 * (base)
  {
    "phaazon/hop.nvim",
    keys = {
      { "t", "<cmd>HopChar2MW<CR>", mode = { "n", "o", "v" } },
      { "f", "<cmd>HopWordAC<CR>", mode = { "n", "o", "v" } },
      { "F", "<cmd>HopWordBC<CR>", mode = { "n", "o", "v" } },
    },
    opts = { keys = "etovxqpdygfblzhckisuran" },
    event = "BufReadPost",
  },
  -- 输入模式自动切换输入法
  { "alohaia/fcitx.nvim", event = "BufReadPost" },
  -- 全局字符串搜索替换
  {
    "dyng/ctrlsf.vim",
    event = "BufReadPost",
    keys = {
      {
        "<leader>rf",
        function()
          vim.api.nvim_command("CtrlSF " .. vim.fn.getreg("a"):gsub(" ", "\\ "))
        end,
        desc = "CtrlSF",
        silent = true,
      },
      {
        "<leader>rf",
        function()
          vim.api.nvim_command("CtrlSF " .. utils.get_visual_text():gsub(" ", "\\ "))
        end,
        desc = "CtrlSF",
        mode = "v",
        silent = true,
      },
    },
  },
  -- 中文帮助文档
  { "wsdjeg/vimdoc-cn", lazy = false },
  -- 快速选择
  { "gcmt/wildfire.vim", event = "BufReadPost" },
  -- 修改环绕字符
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    keys = {
      {
        "<leader>cs",
        function()
          tools.mod_pair()
        end,
        desc = "mod pair",
        silent = true,
      },
    },
    config = function()
      require("nvim-surround").setup()
    end,
  },
  {
    "shellRaining/hlchunk.nvim",
    event = "BufReadPost",
    config = function()
      require("hlchunk").setup({
        blank = { enable = false },
      })
    end,
  },
}

-- 获取当前文件所在路径
local current_path = debug.getinfo(1, "S").source:sub(2):match("(.*[/\\])")
local current_module_name = utils.get_current_module_name(true)

local files = io.popen('dir "' .. current_path .. '"'):read()
for file in files:gmatch("%S+") do
  if file ~= "init.lua" then
    local mod_name = file:gsub("%.lua$", "")
    local module = require(current_module_name .. "." .. mod_name)
    if type(module[1]) == "table" then
      for i = 1, #module do
        table.insert(plugins, module[i])
      end
    else
      table.insert(plugins, module)
    end
  end
end

return plugins
