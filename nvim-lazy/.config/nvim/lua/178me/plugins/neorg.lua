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
return {
  "nvim-neorg/neorg",
  lazy = false,
  build = ":Neorg sync-parsers",
  opts = {
    load = {
      -- ["core.defaults"] = {}, -- Loads default behaviour
      -- ["core.norg.concealer"] = {}, -- Adds pretty icons to your documents
      ["core.itero"] = {},
      ["core.promo"] = {},
      ["core.integrations.treesitter"] = {},
      ["core.keybinds"] = {
        config = {
          default_keybinds = false,
          hook = function(keybinds)
            keybinds.map_event_to_mode("norg", {
              n = {
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
      ["core.norg.completion"] = {
        config = {
          engine = "nvim-cmp",
        },
      }, -- Adds pretty icons to your documents
      -- ["core.norg.dirman"] = { -- Manages Neorg workspaces
      --   config = {
      --     workspaces = {
      --       notes = "~/notes",
      --     },
      --   },
      -- },
    },
  },
  dependencies = { { "nvim-lua/plenary.nvim" } },
}
