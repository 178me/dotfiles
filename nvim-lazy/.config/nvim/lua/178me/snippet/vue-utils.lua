local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local M = {
	s("=-", {
		t({ [[() => {]], "\t" }),
		i(1),
		t({ "", "}" }),
	}),
	s("ppr", {
		t({ [[console.info("178me-debug:",]] }),
		i(1),
		t({ [[)]] }),
	}),
	s("/./", {
		t({ [[{/* ]] }),
		i(1),
		t({ [[ */}]] }),
	}),
}

return M
