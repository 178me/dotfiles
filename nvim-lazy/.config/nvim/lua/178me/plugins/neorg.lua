-- leader = "<LocalLeader>",
-- map = <function 1>,
-- map_event = <function 2>,
-- map_event_to_mode = <function 3>,
-- map_eventd = <function 4>,
-- map_to_mode = <function 5>,
-- mapd = <function 6>,
-- mode = "norg",
-- remap = <function 7>,
-- remap_event = <function 8>,
-- remap_eventd = <function 9>,
-- remap_key = <function 10>,
-- remap_keyd = <function 11>,
-- remapd = <function 12>,
-- unmap = <function 13>,
-- unmapd = <function 14>
local function task_command(command)
  return "core.norg.qol.todo_items.todo." .. command
end
return {
  "nvim-neorg/neorg",
  lazy = false,
  build = ":Neorg sync-parsers",
  keys = {
    { "<leader>nl", "<cmd>Neorg<CR>", desc = "list", silent = true },
    { "<leader>nk", "<cmd>Neorg keybind all<CR>", desc = "core", silent = true },
    {
      "<leader>nt",
      function()
        vim.api.nvim_command("Neorg toc right")
        local width = vim.api.nvim_get_option("columns")
        local new_width = math.floor(width * 0.35)
        vim.api.nvim_command("vertical resize " .. new_width)
      end,
      desc = "Neorg tag",
      silent = true,
    },
  },
  opts = {
    load = {
      -- ["core.defaults"] = {}, -- Loads default behaviour
      ["core.itero"] = {},
      ["core.promo"] = {},
      ["core.integrations.treesitter"] = {},
      ["core.integrations.telescope"] = {},
      -- 在缓冲区编写代码块
      -- ["core.looking-glass"] = {},
      -- 自动缩进处理
      ["core.norg.esupports.indent"] = {},
      -- 元数据
      ["core.norg.esupports.metagen"] = {},
      -- 生成索引文件
      ["core.norg.qol.toc"] = {},
      -- 日记
      ["core.norg.journal"] = {
        config = {
          strategy = "flat",
        },
      },
      ["core.norg.completion"] = {
        config = {
          engine = "nvim-cmp",
        },
      },
      -- Adds pretty icons to your documents
      ["core.norg.dirman"] = { -- Manages Neorg workspaces
        config = {
          workspaces = {
            default = "~/Documents/neorg",
          },
        },
      },
      -- todo
      ["core.norg.qol.todo_items"] = {},
      -- 美化
      ["core.norg.concealer"] = {
        config = {
          folds = true,
          icon_preset = "varied",
          dim_code_blocks = {
            conceal = false,
          },
          icons = {
            todo = {
              done = { icon = " " },
              pending = { icon = " " },
              undone = { icon = " " },
              uncertain = { icon = " " },
              on_hold = { icon = " " },
              cancelled = { icon = " " },
              recurring = { icon = "↺" },
              urgent = { icon = "⚠ " },
            },
          },
        },
      },
      ["core.keybinds"] = {
        config = {
          default_keybinds = false,
          hook = function(keybinds)
            keybinds.map("norg", "n", "<Tab>", "za")
            keybinds.map_event("norg", "n", "gtu", task_command("task_undone"), { desc = "未完成" })
            keybinds.map_event("norg", "n", "gtp", task_command("task_pending"), { desc = "未决定" })
            keybinds.map_event("norg", "n", "gtd", task_command("task_done"), { desc = "已完成" })
            keybinds.map_event("norg", "n", "gth", task_command("task_on_hold"), { desc = "暂停" })
            keybinds.map_event("norg", "n", "gtc", task_command("task_cancelled"), { desc = "取消" })
            keybinds.map_event("norg", "n", "gtr", task_command("task_recurring"), { desc = "重复" })
            keybinds.map_event("norg", "n", "gti", task_command("task_important"), { desc = "重要" })
            keybinds.map_event_to_mode("norg", {
              n = {
                { "<leader>n<space>", "core.norg.qol.todo_items.todo.task_cycle", desc = "todo" },
                { "J", "core.integrations.treesitter.next.heading" },
                { "K", "core.integrations.treesitter.previous.heading" },
                { "gj", "core.integrations.treesitter.next.link" },
                { "gk", "core.integrations.treesitter.previous.link" },
                { ">", "core.promo.promote", "nested" },
                { "<", "core.promo.demote", "nested" },
              },
              i = {
                { "<C-t>", "core.promo.promote" },
                { "<C-d>", "core.promo.demote" },
                { "<C-]>", "core.itero.next-iteration" },
              },
            }, {
              silent = true,
              noremap = true,
            })
          end,
        },
      },
    },
  },
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    {
      "nvim-neorg/neorg-telescope",
      lazy = false,
      keys = {
        { "<leader>on", "<cmd>Telescope neorg<cr>", desc = "Neorg" },
      },
    },
  },
}
