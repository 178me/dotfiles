-- find more awesome plugins
-- https://github.com/rockerBOO/awesome-neovim
-- http://neovimcraft.com
-- https://github.com/ayamir/nvimdots/wiki/Plugins

local utils = require("utils")

require("packer").startup({
	function(use)
		-- 插件管理 (base)
		use("wbthomason/packer.nvim")
		--------------------------- ui --------------------------
		-- 键位菜单 (base)
		use({ "folke/which-key.nvim", config = utils.fn.loadConfig({ "plugin/which-key" }) })
		-- dashboard (fully configured) 启动页面
		-- use({ "glepnir/dashboard-nvim", config = utils.fn.loadConfig({ "plugin/dashboard-nvim" }) })
		-- colorscheme (fully configured) 颜色主题
		use("folke/tokyonight.nvim")
		use("sainnhe/sonokai")
		use("rakr/vim-one")
		-- tab line (basically configured) tab 标签 (base)
		use({
			"akinsho/bufferline.nvim",
			tag = "v2.*",
			requires = "kyazdani42/nvim-web-devicons",
			config = utils.fn.loadConfig({ "plugin/bufferline" }),
		})
		-- status line (basically configured) 状态栏配置 (base)
		use({
			"nvim-lualine/lualine.nvim",
			requires = {
				"folke/tokyonight.nvim",
				"kyazdani42/nvim-web-devicons",
				-- show lsp status
				"arkav/lualine-lsp-progress",
				-- show current function name
				{
					"SmiteshP/nvim-gps",
					-- "nvim-treesitter/nvim-treesitter" is required
					config = utils.fn.loadConfig({ "plugin/nvim-gps" }),
				},
			},
			config = utils.fn.loadConfig({ "plugin/lualine" }),
		})
		--------------------------- tools --------------------------
		-- quickly modify surround char 快速修改环绕字符 (base)
		use({ "kylechui/nvim-surround", config = utils.fn.loadConfig({ "plugin/surround" }) })
		-- more smooth scroll (fully configured) 后期可折腾
		use({ "karb94/neoscroll.nvim", config = utils.fn.loadConfig({ "plugin/neoscroll" }) })
		-- highlights cursor words and lines 高亮当前光标的单词
		use({ "yamatsum/nvim-cursorline", config = utils.fn.loadConfig({ "plugin/nvim-cursorline" }) })
		-- 包围你的单词
		use("gcmt/wildfire.vim")
		-- 中文帮助文档
		use("wsdjeg/vimdoc-cn")
		-- 全局匹配替换
		use("dyng/ctrlsf.vim")
		-- 文件管理器Ranger
		use({ "kevinhwang91/rnvimr", config = utils.fn.loadConfig({ "plugin/rnvimr" }) })
		-- 输入模式自动切换输入法 (base)
		use({ "alohaia/fcitx.nvim", config = utils.fn.loadConfig({ "plugin/fcitx" }) })
		-- displays neovim startup time neovim 的启动时间及时间花在了哪里 (base)
		use({ "dstein64/vim-startuptime", config = utils.fn.loadConfig({ "plugin/vim-startuptime" }) })
		-- a faster version of filetype.vim 听说是用来加快启动速度的 但是不知道具体怎么用
		use({ "nathom/filetype.nvim", config = utils.fn.loadConfig({ "plugin/filetype" }) })
		-- terminal (basically configured) 目前的终端使用方案
		use({
			"akinsho/toggleterm.nvim",
			tag = "v1.*",
			config = utils.fn.loadConfig({ "plugin/toggleterm" }),
		})
		-- repeat previous cmd 更加强大的重复上一个命令  不知道怎么用 但是应该和别的插件配合起来的
		use("tpope/vim-repeat")
		-- toggle comments (basically configured) 注释工具 (base)
		use({ "numToStr/Comment.nvim", config = utils.fn.loadConfig({ "plugin/comment" }) })
		-- automatically toggle between absolute line number and relative one 与行号相关的辅助
		use("jeffkreeftmeijer/vim-numbertoggle")
		-- quick motion 快速移动 * (base)
		use({
			"phaazon/hop.nvim",
			config = utils.fn.loadConfig({ "plugin/hop" }),
		})
		-- indentation guides 缩进线
		use({ "lukas-reineke/indent-blankline.nvim", config = utils.fn.loadConfig({ "plugin/indent-blankline" }) })
		-- call sudo in neovim (fully configured) 封装sudo (base)
		use({ "lambdalisue/suda.vim", config = utils.fn.loadConfig({ "plugin/suda" }) })
		-- session 会话管理的一个工具 #
		-- use({ "rmagatti/auto-session", config = utils.fn.loadConfig({ "plugin/auto-session" }) })
		--------------------------- highlight --------------------------
		-- colorizer (basically configured) 高亮颜色组
		use({ "norcalli/nvim-colorizer.lua", config = utils.fn.loadConfig({ "plugin/nvim-colorizer" }) })
		-- better syntax highlight 更好的语法显示
		use({
			{
				"nvim-treesitter/nvim-treesitter",
				run = ":TSUpdate",
				config = utils.fn.loadConfig({ "plugin/nvim-treesitter" }),
			},
			-- extensions
			-- rainbow brackets 彩虹括号
			"p00f/nvim-ts-rainbow",
			-- better matchup 增强%的功能 好评
			"andymass/vim-matchup",
			-- always show code context 显示代码上下文 好评 (base)
			{
				"nvim-treesitter/nvim-treesitter-context",
				config = utils.fn.loadConfig({ "plugin/nvim-treesitter-context" }),
			},
			-- syntax aware text-objects, select, move, swap, and peek support 不太了解 可以去了解
			"nvim-treesitter/nvim-treesitter-textobjects",
		})
		--------------------------- cmp --------------------------
		-- 自动补全成对符号 (base)
		use({ "windwp/nvim-autopairs", config = utils.fn.loadConfig({ "plugin/nvim-autopairs" }) })
		-- code auto complete 代码补全功能 ***** (base)
		use({
			-- engine
			{
				"hrsh7th/nvim-cmp",
				requires = {
					-- better ui 补全列表的一些图标
					{ "onsails/lspkind-nvim", config = utils.fn.loadConfig({ "plugin/lspkind-nvim" }) },
				},
				config = utils.fn.loadConfig({ "plugin/nvim-cmp" }),
			},
			-- source
			-- more sources on https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			-- snippets 代码片段 (base)
			{ "L3MON4D3/LuaSnip", config = utils.fn.loadConfig({ "plugin/luasnip" }) },
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		})
		--------------------------- fuzzy search --------------------------
		-- fuzzy search (basically configured) 模糊搜索
		use({
			{
				"nvim-telescope/telescope.nvim",
				requires = { "nvim-lua/plenary.nvim" },
				config = utils.fn.loadConfig({ "plugin/telescope" }),
			},
			-- extensions
			-- yank
			{
				"gbprod/yanky.nvim",
				config = utils.fn.loadConfig({ "plugin/yanky" }),
			},
			-- todo comments 代办事选
			{
				"folke/todo-comments.nvim",
				requires = "nvim-lua/plenary.nvim",
				config = utils.fn.loadConfig({ "plugin/todo-comments" }),
			},
			-- project manager (basically configured)
			{ "ahmedkhalf/project.nvim", config = utils.fn.loadConfig({ "plugin/project" }) },
		})
		--------------------------- lsp --------------------------
		-- tagbar 显示函数和变量 (base)
		use({ "simrat39/symbols-outline.nvim", config = utils.fn.loadConfig({ "plugin/symbols-outline" }) })
		-- lsp lsp配置
		use({
			{
				"williamboman/nvim-lsp-installer",
				config = utils.fn.loadConfig({ "plugin/nvim-lsp-installer" }),
			},
			{
				"neovim/nvim-lspconfig",
				config = utils.fn.loadConfig({ "lsp" }),
			},
			{
				"tami5/lspsaga.nvim",
				config = utils.fn.loadConfig({ "plugin/lspsaga" }),
			},
			{
				"sbdchd/neoformat",
			},
		})
		use({
			"danymat/neogen",
			config = function()
				require("neogen").setup({ snippet_engine = "luasnip" })
			end,
			requires = "nvim-treesitter/nvim-treesitter",
			-- Uncomment next line if you want to follow only stable versions
			-- tag = "*"
		})
		-- git管理
		use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" })
		use({ "kdheepak/lazygit.nvim", requires = "nvim-lua/plenary.nvim" })
    -- 专注高亮
		use({
			"folke/twilight.nvim",
			config = utils.fn.loadConfig({ "plugin/twilight" }),
		})
    -- 禅模式
		use({
			"folke/zen-mode.nvim",
			config = utils.fn.loadConfig({ "plugin/zen-mode" }),
		})
    use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
	end,
})
