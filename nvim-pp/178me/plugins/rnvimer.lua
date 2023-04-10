return {
  -- 文件管理器
  "kevinhwang91/rnvimr",
  keys = {
    { "<leader>jr", "<cmd>RnvimrToggle<CR>", desc = "Ranger File Manage" },
    { "<C-g>", "<C-\\><C-n>:RnvimrResize<CR>", desc = "Ranger Resize", silent = true, mode = "t" },
  },
  config = function()
    vim.cmd([[
        let g:rnvimr_layout = {
                    \ 'relative': 'editor',
                    \ 'width': float2nr(round(0.6 * &columns)),
                    \ 'height': float2nr(round(1.0 * &lines)),
                    \ 'col': float2nr(round(0.4 * &columns)),
                    \ 'row': float2nr(round(0.0 * &lines)),
                    \ 'style': 'minimal'
                    \ }
        let g:rnvimr_presets = [
                    \ {},
                    \ {'width': 0.600, 'height': 0.600},
                    \ {'width': 0.800, 'height': 0.800},
                    \ {'width': 0.950, 'height': 0.950},
                    \ {'width': 0.500, 'height': 0.500, 'col': 0.5, 'row': 0},
                    \ {'width': 0.500, 'height': 0.500, 'col': 0.5, 'row': 0.5},
                    \ {'width': 0.500, 'height': 1.000, 'col': 0, 'row': 0},
                    \ {'width': 0.500, 'height': 1.000, 'col': 0.5, 'row': 0},
                    \ {'width': 1.000, 'height': 0.500, 'col': 0, 'row': 0},
                    \ {'width': 1.000, 'height': 0.500, 'col': 0, 'row': 0.5}
                    \ ]
        ]])
  end,
}
