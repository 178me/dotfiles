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
}
