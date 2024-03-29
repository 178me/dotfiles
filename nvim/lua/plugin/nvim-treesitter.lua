local utils = require("utils")

utils.fn.require("nvim-treesitter.configs").setup({
  -- use :TSInstallInfo to check pasers
  ensure_installed = {
    "bash",
    "c",
    "cmake",
    "cpp",
    "css",
    "go",
    "gomod",
    "html",
    "javascript",
    "json",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "ninja",
    "python",
    "rust",
    "scss",
    "toml",
    "todotxt",
    "tsx",
    "typescript",
    "verilog",
    "vim",
    "vue",
  },
  highlight = { enable = true, disable = { "org" }, additional_vim_regex_highlighting = false },
  intent = { enable = true },
  rainbow = {
    enable = true,
    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
    colors = { "#0099ff", "#00ff00", "#ff4dc3", "#ffff00", "#ff9933" }, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  },
  matchup = {
    enable = true, -- mandatory, false will disable the whole extension
    -- disable = { "c", "ruby" }, -- optional, list of language that will be disabled
    -- [options]
  },
  -- check more textobjects on https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
})
