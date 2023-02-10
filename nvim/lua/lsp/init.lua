local utils = require("utils")

local lspList = {
	"cssls",
	"volar",
	"sumneko_lua",
	"gopls",
	"bashls",
	"cssmodules_ls",
	"eslint",
	"html",
	"jsonls",
	"rust_analyzer",
	"sqls",
	"clangd",
	"taplo",
	"verible",
	"unocss",
	"tailwindcss",
	"pyright",
	-- "jedi_language_server",
	-- "pylsp",
	-- "sourcery"
}

-- common lsp config
local on_attach = function(client, _)
	-- disable default format feature of lsp
	-- client.server_capabilities.document_formatting = false -- 0.7 and earlier
	-- client.server_capabilities.documentFormattingProvider = false -- 0.8 and hopefully later
end

-- nvim-cmp support
local capabilities = utils.fn.require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- load all lsp config
for _, value in pairs(lspList) do
	local config = utils.fn.require("lsp/" .. value, false)
	if type(config) == "string" then
		config = {}
	end

	-- set on_attach
	if config.on_attach == nil then
		config.on_attach = on_attach
	else
		local on_attach_tmp = config.on_attach
		config.on_attach = function(client, bufnr)
			on_attach(client, bufnr)
			on_attach_tmp(client, bufnr)
		end
	end

	-- set capabilities
	if value ~= "taplo" then
		if config.modify_capabilities == nil then
			config.capabilities = capabilities
		else
			config.capabilities = config.modify_capabilities(capabilities)
		end
	end

	-- print(value,config)
	-- utils.fn.require("lspconfig")[value].setup(config)
	-- print(utils.fn.require("lspconfig")[value])
	local _, err = pcall(utils.fn.require("lspconfig")[value].setup, config)
	if err ~= nil then
		print("err", err)
	end
end
