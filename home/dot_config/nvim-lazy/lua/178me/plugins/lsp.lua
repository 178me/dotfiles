return {
  "nvimdev/lspsaga.nvim",
  event = "BufEnter",
  keys = {
    { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "show hover documentation" },
    { "gj", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "jump to next diagnostic" },
    { "gk", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "jump to previous diagnostic" },
    { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "go to definition" },
    { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "rename symbol" },
    { "<leader>lf", "<cmd>Lspsaga finder<CR>", desc = "show LSP finder" },
    { "<leader>lF", "<cmd>Telescope lsp_references<CR>", desc = "find references with Telescope" },
    { "<leader>la", "<cmd>Lspsaga code_action<CR>", desc = "show code actions" },
    { "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "show line diagnostics" },
    { "<leader>li", "<cmd>Lspsaga finder imp<CR>", desc = "show implementation finder" },
    { "<leader>lci", "<cmd>Lspsaga incoming_calls<CR>", desc = "show incoming calls" },
    { "<leader>lco", "<cmd>Lspsaga outgoing_calls<CR>", desc = "show outgoing calls" },
    { "<leader>lp", "<cmd>Lspsaga peek_definition<CR>", desc = "peek definition" },
  },
  opts = {
    symbol_in_winbar = {
      enable = false,
    },
    rename = {
      in_select = false,
      keys = {
        quit = "<ESC>",
      },
    },
    code_action = {
      keys = {
        -- quit = "<ESC>",
      },
    },
    callhierarchy = {
      keys = {
        quit = "<ESC>",
      },
    },
    finder = {
      keys = {
        shuttle = "<C-f><C-f>",
        close = "<C-f><C-k>",
        toggle_or_open = "<CR>",
      },
    },
    lightbulb = {
      enable = false,
      sign = false,
    },
    ui = {},
  },
}
