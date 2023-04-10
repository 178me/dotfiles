return {
  -- 浮动终端
  "akinsho/toggleterm.nvim",
  keys = {
    { "<C-t>", "<cmd>Toggleterm<cr>", desc = "float terminal" },
  },
  opts = {
    size = 15,
    open_mapping = "<c-t>",
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    highlights = {},
    shade_terminals = true, -- this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
    shading_factor = 1, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = false, -- whether or not the open mapping applies in insert mode
    terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
    persist_size = true,
    -- direction = 'vertical' | 'horizontal' | 'tab' | 'float',
    direction = "float",
    close_on_exit = true, -- close the terminal window when the process exits
    float_opts = {
      border = "curved",
      width = 100,
      height = 30,
      bufpos = { 100, 10 },
    },
  },
}
