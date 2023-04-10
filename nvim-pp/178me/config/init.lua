local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local function setup()
  require("lazy").setup({
    spec = {
      { import = "lazyvim.plugins" },
      { import = "178me.plugins" },
    },
    defaults = {
      lazy = true,
      version = false, -- always use the latest git commit
      keymaps = false, -- lazyvim.config.keymaps
    },
    install = { colorscheme = { "tokyonight", "habamax" } },
    checker = { enabled = true }, -- automatically check for plugin updates
    performance = {
      rtp = {
        -- disable some rtp plugins
        disabled_plugins = {
          "gzip",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  })
  require("178me.config.options")
  -- 加载vim脚本映射
  local vim_script_file = os.getenv("HOME") .. "/.config/nvim.lazy/lua/178me/config/keymap.vim"
  local f = io.open(vim_script_file, "r")
  if f ~= nil then
    local script_content = f:read("*all")
    f:close()
    vim.api.nvim_exec(script_content, false)
  end
  local keymap = require("178me.config.keymaps")
  keymap.map_table(keymap.leader_map)
end

setup()
