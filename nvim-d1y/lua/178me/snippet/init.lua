local utils = require("178me.utils")
local luasnip = require("luasnip")

local langList = {
  "go",
  "lua",
  "vue",
}
local vue_lang = {
  "vue",
  "javascript",
  "typescript",
  "typescriptreact",
}

-- register custom snippets
for _, value in pairs(langList) do
  local snippet = require("178me.snippet." .. value)
  luasnip.add_snippets(value, snippet, {
    key = value,
  })
end
-- vue
for _, value in pairs(vue_lang) do
  local snippet = require("178me.snippet.vue-utils")
  luasnip.add_snippets(value, snippet, {
    key = value,
  })
end

require("luasnip.loaders.from_lua").load({ include = langList })
