local utils = require("178me.utils")
local tools = require("178me.my-tools")
local map = require("lazyvim.config.keymaps")
local M = {}

M.leader_map = {
  ["v|<leader>ya"] = { '"ay<Esc>', { desc = "a" } },
  ["v|<leader>yb"] = { '"by<Esc>', { desc = "b" } },
  ["v|<leader>yy"] = { '"+y<Esc>', { desc = "system clipboard" } },
  ["n v|<leader>t"] = { utils.fn.test, { desc = "test" } },
  ["n|<leader>jR"] = { ":so $MYVIMRC<CR>:e %<CR>", { desc = "refush config" } },
  ["n|<leader>jc"] = { utils.fn.runCode, { desc = "run code" } },
  ["n|<leader>jp"] = { utils.fn.runProject, { desc = "run project" } },
  ["n|<leader>uf"] = { utils.fn.runScript, { desc = "upload file" } },
  ["n|<leader>lud"] = { "<cmd>lua vim.diagnostic.disable{}<CR>", { desc = "disable diagnostics" } },
  ["n|<leader>lue"] = { "<cmd>lua vim.diagnostic.enable{}<CR>", { desc = "enable diagnostics" } },
  ["n|<leader>lD"] = { tools.delete_unused_imports, { desc = "delete all unused imports" } },
  ["n|<leader>rr"] = { utils.fn.replace_global, { desc = "replace" } },
  ["v|<leader>rr"] = { utils.fn.replace, { desc = "replace" } },
  ["n|<leader>nf"] = { utils.fn.new_file, { desc = "new file" } },
  ["n|<leader>fr"] = { utils.fn.look_ref, { desc = "look ref" } },
  ["n v|<leader>ss"] = { tools.network_search, { desc = "browser search" } },
  ["n|<leader>pL"] = { "<cmd>Lazy<CR>", { desc = "lazy manage" } },
}

M.map_table = function(mapping)
  for key, value in pairs(mapping) do
    local mode, lhs = string.match(key, "([^|]*)|?(.*)")
    mode = utils.fn.split(mode, " ")
    local status, res = pcall(map, mode, lhs, unpack(value))
    if not status then
      print(vim.inspect(res))
    end
  end
end

return M
