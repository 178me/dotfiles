local utils = require("utils")
local luasnip = utils.fn.require("luasnip")

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

-- load friendly-snippets
utils.fn.require("luasnip.loaders.from_vscode").lazy_load()

-- register custom snippets
for _, value in pairs(langList) do
	local snippet = utils.fn.require("snippet/" .. value)
	luasnip.add_snippets(value, snippet, {
		key = value,
	})
end
-- vue
for _, value in pairs(vue_lang) do
	local snippet = utils.fn.require("snippet/" .. "vue-utils")
	luasnip.add_snippets(value, snippet, {
		key = value,
	})
end


utils.fn.require("luasnip.loaders.from_lua").load({ include = langList })
