local Util = require("lazyvim.util")

return {

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    keys = {
      { "<leader>o;", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>ol", "<cmd>Telescope<CR>", desc = "Telescope List" },
      { "<leader>ob", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>of", "<cmd>Telescope find_files<cr>", desc = "Find Files (root dir)" },
      { "<leader>oF", "<cmd>Telescope git_files<cr>", desc = "git files" },
      { "<leader>or", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>oR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>oC", Util.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
      { "<leader>ow", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer word" },
      { "<leader>oW", "<cmd>Telescope live_grep<CR>", desc = "Project Word" },
      -- search
      { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sm", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>st", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Goto Symbol" },
      {
        "<leader>sc",
        function()
          local config_path = "/home/yzl178me/.config/nvim/lua"
          vim.api.nvim_set_current_dir(config_path)
          Util.telescope("find_files", { search_dirs = { config_path } })()
        end,
        desc = "serach nvim config",
      },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        mappings = {
          i = {
            ["<c-t>"] = function(...)
              return require("trouble.providers.telescope").open_with_trouble(...)
            end,
            ["<a-t>"] = function(...)
              return require("trouble.providers.telescope").open_selected_with_trouble(...)
            end,
            ["<a-i>"] = function()
              Util.telescope("find_files", { no_ignore = true })()
            end,
            ["<a-h>"] = function()
              Util.telescope("find_files", { hidden = true })()
            end,
            ["a-j>"] = function(...)
              return require("telescope.actions").cycle_history_next(...)
            end,
            ["<a-k>"] = function(...)
              return require("telescope.actions").cycle_history_prev(...)
            end,
            ["<C-j>"] = function(...)
              return require("telescope.actions").move_selection_next(...)
            end,
            ["<C-k>"] = function(...)
              return require("telescope.actions").move_selection_previous(...)
            end,
            ["C-g"] = function(...)
              return require("telescope.actions").close(...)
            end,
          },
        },
      },
    },
    depend = {},
  },

  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      local keymaps = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["gz"] = { name = "+surround" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
        ["<leader>j"] = { name = "quick" },
        ["<leader>k"] = { name = "kill" },
        ["<leader>n"] = { name = "new" },
        ["<leader>o"] = { name = "open" },
        ["<leader>p"] = { name = "plugin" },
        ["<leader>r"] = { name = "replace" },
      }
      if Util.has("noice.nvim") then
        keymaps["<leader>sn"] = { name = "+noice" }
      end
      wk.register(keymaps)
    end,
  },

  -- git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
  },

  -- references
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = { delay = 200 },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },

  -- todo comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    -- stylua: ignore
    keys = {
      { "<leader>sT", "<cmd>TodoTelescope<cr>", desc = "Todo" },
    },
  },
}
