local utils = require("utils")
local whichKeyMap = require("which-key").register

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local rhs_opt = {}

function rhs_opt:new(rhs)
	local instance = {
		rhs = rhs,
		options = {
			noremap = false,
			silent = false,
			expr = false,
			nowait = false,
		},
	}
	setmetatable(instance, self)
	self.__index = self
	return instance
end

function rhs_opt:new_which_key(rhs, map_desc)
	local instance = {
		rhs = rhs,
		desc = map_desc,
		options = {
			mode = "n",
			prefix = "",
			buffer = nil,
			silent = true,
			noremap = true,
			nowait = false,
		},
	}
	setmetatable(instance, self)
	self.__index = self
	return instance
end

function rhs_opt:new_prefix(prefix_name)
	local instance = {
		rhs = nil,
		desc = nil,
		name = prefix_name,
		options = {
			mode = "n",
		},
	}
	setmetatable(instance, self)
	self.__index = self
	return instance
end

function rhs_opt:set_option(option_key, option_value)
	self.options[option_key] = option_value
	return self
end

-- 主要映射单键
local nvim_mappings = {
	["n|;"] = rhs_opt:new(":"),
	["n|<"] = rhs_opt:new("<<"),
	["n|>"] = rhs_opt:new(">>"),
	["i|jj"] = rhs_opt:new("<Esc>"),
	["t|<C-q>"] = rhs_opt:new("<C-\\><C-n>"),
	-- ["i|<C-j>"] = rhs_opt:new("<cmd>normal! b<CR>"),
	-- ["i|<C-k>"] = rhs_opt:new("<cmd>normal! e<CR><right>"),
	-- ["i|<C-j>"] = rhs_opt:new("<Plug>(Tabout)"),
	-- ["i|<C-k>"] = rhs_opt:new("<Plug>(TaboutBack)"),
	["i c|<C-b>"] = rhs_opt:new("<left>"),
	["i c|<C-f>"] = rhs_opt:new("<right>"),
	["n v|<C-a>"] = rhs_opt:new("^"),
	["i|<C-a>"] = rhs_opt:new("<C-o>^"),
	["c|<C-a>"] = rhs_opt:new("<home>"),
	["n i v c|<C-e>"] = rhs_opt:new("<end>"),
	["n v|<C-j>"] = rhs_opt:new("}"),
	["n v|<C-k>"] = rhs_opt:new("{"),
	["n|<C-h>"] = rhs_opt:new("<cmd>BufferLineCyclePrev<CR>"),
	["n|<C-l>"] = rhs_opt:new("<cmd>BufferLineCycleNext<CR>"),
	["n o v|t"] = rhs_opt:new("<cmd>HopChar2MW<CR>"),
	["n o v|f"] = rhs_opt:new("<cmd>HopWordAC<CR>"),
	["n o v|F"] = rhs_opt:new("<cmd>HopWordBC<CR>"),
	["n|K"] = rhs_opt:new("<cmd>Lspsaga hover_doc<CR>"),
	["n|gj"] = rhs_opt:new("<cmd>Lspsaga diagnostic_jump_next<CR>"),
	["n|gk"] = rhs_opt:new("<cmd>Lspsaga diagnostic_jump_prev<CR>"),
	["n|gd"] = rhs_opt:new("<cmd>Telescope lsp_definitions<cr>"),
	["n|gp"] = rhs_opt:new("<cmd>Lspsaga preview_definition<cr>"),
	["n x|p"] = rhs_opt:new("<Plug>(YankyPutAfter)"),
	["n x|P"] = rhs_opt:new("<Plug>(YankyPutBefore)"),
	["n|<C-2>"] = rhs_opt:new("<cmd>BufferLineGoToBuffer 2<cr>"),
}

local which_key_mappings = {
	["n|<leader><leader>"] = rhs_opt:new_which_key(
		'<CMD>lua require("Comment.api").toggle.linewise.current()<CR>',
		"comment code"
	),
	["v|<leader><leader>"] = rhs_opt:new_which_key("<Plug>(comment_toggle_linewise_visual)", "comment code"),
	["n|<leader><cr>"] = rhs_opt:new_which_key("<cmd>nohlsearch<cr>", "nohlsearch"),
	["v|<leader>y"] = rhs_opt:new_prefix("yank to"),
	["v|<leader>ya"] = rhs_opt:new_which_key('"ay<Esc>', "a"),
	["v|<leader>yb"] = rhs_opt:new_which_key('"by<Esc>', "b"),
	["v|<leader>yy"] = rhs_opt:new_which_key('"+y<Esc>', "system clipboard"),
	["n|<leader>t"] = rhs_opt:new_which_key(utils.fn.test, "test"),
	["n|<leader>j"] = rhs_opt:new_prefix("quick"),
	["n|<leader>jq"] = rhs_opt:new_which_key("<cmd>bd<CR>", "close tab"),
	["n|<leader>jQ"] = rhs_opt:new_which_key("<cmd>qa!<CR>", "exit nvim"),
	["n|<leader>jw"] = rhs_opt:new_which_key("<cmd>w!<CR>", "save"),
	["n|<leader>jW"] = rhs_opt:new_which_key("<cmd>SudaWrite<CR>", "force save"),
	["n|<leader>jr"] = rhs_opt:new_which_key("<cmd>RnvimrToggle<CR><Esc>", "Ranger"),
	["n|<leader>jR"] = rhs_opt:new_which_key(":luafile $MYVIMRC<CR>", "refush config"),
	["n|<leader>jt"] = rhs_opt:new_which_key("<cmd>BufferLinePick<CR>", "jump tab"),
	["n|<leader>jb"] = rhs_opt:new_which_key('<cmd>lua require("nvim-toggler").toggle()<CR>', "toggler"),
	["n|<leader>jc"] = rhs_opt:new_which_key(utils.fn.runCode, "run code"),
	["n|<leader>jp"] = rhs_opt:new_which_key(utils.fn.runProject, "run project"),
	-- ["n|<leader>jf"] = rhs_opt:new_which_key('<cmd>lua vim.lsp.buf.formatting()<CR>:w<CR>', "format code"),
	["n|<leader>jf"] = rhs_opt:new_which_key("<cmd>Neoformat<CR>:w<CR>", "format code"),
	["n|<leader>uf"] = rhs_opt:new_which_key(utils.fn.runScript, "upload file"),
	["n|<leader>l"] = rhs_opt:new_prefix("Lsp"),
	["n|<leader>lr"] = rhs_opt:new_which_key("<cmd>Lspsaga rename<CR>", "rename"),
	["n|<leader>lf"] = rhs_opt:new_which_key("<cmd>Lspsaga lsp_finder<CR>", "finder"),
	["n|<leader>la"] = rhs_opt:new_which_key("<cmd>Lspsaga code_action<CR>", "code action"),
	["x|<leader>la"] = rhs_opt:new_which_key("<cmd>Lspsaga range_code_action<CR>", "code action"),
	["n|<leader>ls"] = rhs_opt:new_which_key("<cmd>Lspsaga signature<CR>", "signature help"),
	["n|<leader>lud"] = rhs_opt:new_which_key("<cmd>lua vim.diagnostic.disable()<CR>", "disable diagnostics"),
	["n|<leader>lue"] = rhs_opt:new_which_key("<cmd>lua vim.diagnostic.enable()<CR>", "enable diagnostics"),
	["n|<leader>ld"] = rhs_opt:new_which_key("<cmd>Lspsaga show_line_diagnostics<CR>", "show diagnostics"),
	["n|<leader>ly"] = rhs_opt:new_which_key("<cmd>Lspsaga yank_line_diagnostics<CR>", "copy diagnostics"),
	["n|<leader>lt"] = rhs_opt:new_which_key("<cmd>SymbolsOutline<CR>", "toggle tagbar"),
	["n|<leader>lR"] = rhs_opt:new_which_key("<cmd>LspRestart<CR>", "restart lsp"),
	["n|<leader>o"] = rhs_opt:new_prefix("Telescope"),
	["n|<leader>ol"] = rhs_opt:new_which_key("<cmd>Telescope<CR>", "telescope list"),
	["n|<leader>ob"] = rhs_opt:new_which_key("<cmd>Telescope buffers<CR>", "buffers"),
	["n|<leader>of"] = rhs_opt:new_which_key("<cmd>Telescope find_files<CR>", "files+"),
	["n|<leader>oF"] = rhs_opt:new_which_key("<cmd>Telescope fd<CR>", "files"),
	["n|<leader>oh"] = rhs_opt:new_which_key("<cmd>Telescope oldfiles<CR>", "history files"),
	["n|<leader>oH"] = rhs_opt:new_which_key("<cmd>Telescope help_tags<CR>", "neovim help"),
	["n|<leader>ot"] = rhs_opt:new_which_key("<cmd>Telescope treesitter<CR>", "tag"),
	["n|<leader>oT"] = rhs_opt:new_which_key("<cmd>Telescope colorscheme<CR>", "theme"),
	["n|<leader>ow"] = rhs_opt:new_which_key("<cmd>Telescope current_buffer_fuzzy_find<CR>", "fuzzy search word"),
	["n|<leader>oW"] = rhs_opt:new_which_key("<cmd>Telescope live_grep<CR>", "global word"),
	["n|<leader>on"] = rhs_opt:new_which_key("<cmd>TodoTelescope<CR>", "note(TODO,FIXME)"),
	["n|<leader>op"] = rhs_opt:new_which_key("<cmd>Telescope projects<CR>", "projects"),
	["n|<leader>oy"] = rhs_opt:new_which_key("<cmd>Telescope yank_history<CR>", "yank history"),
	["n|<leader>og"] = rhs_opt:new_which_key("<cmd>Telescope grep_string<CR>", "grep string"),
	["n|<leader>o;"] = rhs_opt:new_which_key("<cmd>Telescope commands<CR>", "grep string"),
	["n|<leader>r"] = rhs_opt:new_prefix("replace"),
	["n|<leader>rr"] = rhs_opt:new_which_key(utils.fn.replace_global, "replace"),
	["v|<leader>rr"] = rhs_opt:new_which_key(utils.fn.replace, "replace"),
	["n|<leader>rf"] = rhs_opt:new_which_key(":CtrlSF <C-r>a<CR>", "CtrlSF"),
	["n|<leader>rp"] = rhs_opt:new_which_key(
		"<cmd>lua require('spectre').open_visual({select_word=true})<CR>",
		"spectre"
	),
	["n|<leader>p"] = rhs_opt:new_prefix("plugin"),
	["n|<leader>pd"] = rhs_opt:new_which_key(":Neogen<CR>", "generate doc"),
	["n|<leader>ph"] = rhs_opt:new_which_key(":Twilight<CR>", "Twilight"),
	["n|<leader>pm"] = rhs_opt:new_which_key(":ZenMode<CR>", "ZenMode"),
	["n|<leader>g"] = rhs_opt:new_prefix("git"),
	["n|<leader>gl"] = rhs_opt:new_which_key(":LazyGit<CR>", "lazygit"),
	["n|<leader>gm"] = rhs_opt:new_which_key(":Neogit<CR>", "magit"),
	["n|<leader>gt"] = rhs_opt:new_which_key(":GitBlameToggle<CR>", "blameToggle"),
	["n|<leader>go"] = rhs_opt:new_which_key(":GitBlameOpenCommitURL<CR>", "open comment"),
	["n|<leader>nf"] = rhs_opt:new_which_key(utils.fn.new_file, "new file"),
}

local load_mappings = function(map_type, mappings)
	for key, value in pairs(mappings) do
		local mode, lhs = string.match(key, "([^|]*)|?(.*)")
		if map_type == "nvim" then
			-- utils.fn.pprint("lhs",mode,lhs)
			-- utils.fn.pprint(string)
			mode = utils.fn.split(mode, " ")
			-- utils.fn.pprint("mode",mode)
			vim.keymap.set(mode, lhs, value.rhs, value.options)
		elseif map_type == "which_key" then
			value.options.mode = mode
			whichKeyMap({
				[lhs] = { value.rhs, value.desc, name = value.name },
			}, value.options)
		end
	end
end

load_mappings("nvim", nvim_mappings)
load_mappings("which_key", which_key_mappings)
