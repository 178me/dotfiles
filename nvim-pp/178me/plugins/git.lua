return {
  -- git blame
  {
    "f-person/git-blame.nvim",
    keys = {
      { "<leader>gb", "<Cmd>GitBlameToggle<CR>", desc = "git blame" },
      { "<leader>go", "<Cmd>GitBlameOpenCommitURL<CR>", desc = "open blame url" },
    },
  },
  -- git diff
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gd", "<Cmd>DiffviewFileHistory<CR>", desc = "git diff" },
      { "<leader>gF", "<Cmd>DiffviewFileHistory %<CR>", desc = "diff current file" },
      { "<leader>gq", "<Cmd>DiffviewClose<CR>", desc = "close diff" },
    },
  },
  -- Lazygit Git工具
  {
    "kdheepak/lazygit.nvim",
    keys = {
      { "<leader>gl", ":LazyGit<CR>", desc = "Lazygit", silent = true },
      { "<leader>gf", ":LazyGitFilterCurrentFile<CR>", desc = "Lazygit filter file", silent = true },
    },
  },
  -- lsp 操作
  {
    "tami5/lspsaga.nvim",
    keys = {
      { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "next diagnostic" },
      { "gj", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "next diagnostic" },
      { "gk", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "prev diagnostic" },
      { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "go to definition" },
      { "gp", "<cmd>Lspsaga preview_definition<cr>", desc = "preview definition" },
      { "<leader>lr", "<cmd>Lspsaga rename<CR>", desc = "rename" },
      { "<leader>lf", "<cmd>Lspsaga lsp_finder<CR>", desc = "lsp finder" },
      { "<leader>la", "<cmd>Lspsaga code_action<CR>", desc = "code action" },
      { "<leader>ls", "<cmd>Lspsaga signature<CR>", desc = "lsp sign" },
      { "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "show diagnostic" },
      { "<leader>ly", "<cmd>Lspsaga yank_line_diagnostics<CR>", desc = "yank diagnostic" },
    },
    opts = {
      debug = false,
      use_saga_diagnostic_sign = true,
      -- diagnostic sign
      error_sign = "",
      warn_sign = "",
      hint_sign = "",
      infor_sign = "",
      diagnostic_header_icon = "   ",
      -- code action title icon
      code_action_icon = " ",
      code_action_prompt = {
        enable = true,
        sign = true,
        sign_priority = 40,
        virtual_text = true,
      },
      finder_definition_icon = "  ",
      finder_reference_icon = "  ",
      max_preview_lines = 10,
      finder_action_keys = {
        open = "<CR>",
        vsplit = "s",
        split = "i",
        quit = "<ESC>",
        scroll_down = "<C-d>",
        scroll_up = "<C-u>",
      },
      code_action_keys = {
        quit = "<ESC>",
        exec = "<CR>",
      },
      rename_action_keys = {
        quit = "<ESC>",
        exec = "<CR>",
      },
      definition_preview_icon = "  ",
      border_style = "single",
      rename_prompt_prefix = "➤",
      rename_output_qflist = {
        enable = false,
        auto_open_qflist = false,
      },
      server_filetype_map = {},
      diagnostic_prefix_format = "%d. ",
      diagnostic_message_format = "%m %c",
      highlight_prefix = false,
    },
  },
}
