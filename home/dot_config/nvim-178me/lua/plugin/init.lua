-- find more awesome plugins
-- https://github.com/rockerBOO/awesome-neovim
-- http://neovimcraft.com
-- https://github.com/ayamir/nvimdots/wiki/Plugins

local utils = require("utils")

require("packer").startup({
  function(use)
    -- 插件管理 (base)
    use("wbthomason/packer.nvim")
    -- 键位菜单 (base)
    use({ "folke/which-key.nvim", config = utils.fn.loadConfig({ "which-key" }) })
    -- 自动补全成对符号 (base)
    use({ "windwp/nvim-autopairs", config = utils.fn.loadConfig({ "nvim-autopairs" }) })
    -- 输入模式自动切换输入法 (base)
    use({ "alohaia/fcitx.nvim", config = utils.fn.loadConfig({ "fcitx" }) })
    -- displays neovim startup time neovim 的启动时间及时间花在了哪里 (base)
    use({ "dstein64/vim-startuptime" })
    -- a faster version of filetype.vim 听说是用来加快启动速度的 但是不知道具体怎么用
    use({ "nathom/filetype.nvim", config = utils.fn.loadConfig({ "filetype" }) })
    -- 折叠 后期研究
    use({
      "anuvyklack/pretty-fold.nvim",
      -- requires = {
      --   -- only for preview
      --   "anuvyklack/nvim-keymap-amend",
      -- },
      -- config = utils.fn.loadConfig({ "pretty-fold" }),
    })
    -- repeat previous cmd 更加强大的重复上一个命令  不知道怎么用 但是应该和别的插件配合起来的
    use("tpope/vim-repeat")
    -- lazygit git的一个可视化工具
    use({ "kdheepak/lazygit.nvim", config = utils.fn.loadConfig({ "lazygit" }) })
    -- terminal (basically configured) 目前的终端使用方案 可折腾
    use({
      "akinsho/toggleterm.nvim",
      tag = "v1.*",
      config = utils.fn.loadConfig({ "toggleterm" }),
    })
    -- tagbar 显示函数和变量 (base)
    use({ "simrat39/symbols-outline.nvim", config = utils.fn.loadConfig({ "symbols-outline" }) })
    -- toggle comments (basically configured) 注释工具 (base)
    use({ "numToStr/Comment.nvim", config = utils.fn.loadConfig({ "comment" }) })
    -- dashboard (fully configured) 启动页面
    use({ "glepnir/dashboard-nvim", config = utils.fn.loadConfig({ "dashboard-nvim" }) })
    -- automatically toggle between absolute line number and relative one 与行号相关的辅助
    use("jeffkreeftmeijer/vim-numbertoggle")
    -- quick motion 快速移动 * (base)
    use({
      "phaazon/hop.nvim",
      config = utils.fn.loadConfig({ "hop" }),
    })
    -- session 会话管理的一个工具 #
    use({ "rmagatti/auto-session", config = utils.fn.loadConfig({ "auto-session" }) })
    -- file tree 文件树
    use({
      "kyazdani42/nvim-tree.lua",
      requires = {
        "kyazdani42/nvim-web-devicons",
      },
      tag = "nightly",
      config = utils.fn.loadConfig({ "nvim-tree" }),
    })
    -- better syntax highlight 更好的语法显示
    use({
      {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = utils.fn.loadConfig({ "nvim-treesitter" }),
      },
      -- extensions
      -- rainbow brackets 彩虹括号
      "p00f/nvim-ts-rainbow",
      -- better matchup 增强%的功能 好评
      "andymass/vim-matchup",
      -- always show code context 显示代码上下文 好评 (base)
      {
        "nvim-treesitter/nvim-treesitter-context",
        config = utils.fn.loadConfig({ "nvim-treesitter-context" }),
      },
      -- syntax aware text-objects, select, move, swap, and peek support 不太了解 可以去了解
      "nvim-treesitter/nvim-treesitter-textobjects",
    })
    -- sql 关于sql的玩意
    -- use({ "nanotee/sqls.nvim", opt = true, ft = "sql", config = utils.fn.loadConfig({ "sqls" }) })
    -- code auto complete 代码补全功能 ***** (base)
    use({
      -- engine
      {
        "hrsh7th/nvim-cmp",
        requires = {
          -- better ui 补全列表的一些图标
          { "onsails/lspkind-nvim", config = utils.fn.loadConfig({ "lspkind-nvim" }) },
        },
        config = utils.fn.loadConfig({ "nvim-cmp" }),
      },
      -- source
      -- more sources on https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      -- snippets 代码片段 (base)
      { "L3MON4D3/LuaSnip", config = utils.fn.loadConfig({ "luasnip" }) },
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
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
          config = utils.fn.loadConfig({ "nvim-gps" }),
        },
      },
      config = utils.fn.loadConfig({ "lualine" }),
    })
    -- undotree 撤销树 (fail)
    -- use({
    -- 	"jiaoshijie/undotree",
    -- 	requires = {
    -- 		"nvim-lua/plenary.nvim",
    -- 	},
    -- 	config = utils.fn.loadConfig({ "undotree" }),
    -- })
    -- run code snip 运行代码片段 ****
    use({ "michaelb/sniprun", run = "bash ./install.sh", config = utils.fn.loadConfig({ "sniprun" }) })
    -- a pretty diagnostics, references, telescope results, quickfix and location list (basically configured) 代码诊断
    -- use({
    -- 	"folke/trouble.nvim",
    -- 	requires = { "kyazdani42/nvim-web-devicons", "folke/lsp-colors.nvim" },
    -- 	config = utils.fn.loadConfig({ "trouble" }),
    -- })
    -- quickly modify surround char 快速修改环绕字符 (base)
    use({ "ur4ltz/surround.nvim", config = utils.fn.loadConfig({ "surround" }) })
    -- call sudo in neovim (fully configured) 封装sudo (base)
    use({ "lambdalisue/suda.vim", config = utils.fn.loadConfig({ "suda" }) })
    -- translate 翻译 install translate-shell (bu_need)
    -- use({ "uga-rosa/translate.nvim", config = utils.fn.loadConfig({ "translate" }) })
    -- more smooth scroll (fully configured) 后期可折腾
    use({ "karb94/neoscroll.nvim", config = utils.fn.loadConfig({ "neoscroll" }) })
    -- highlights cursor words and lines 高亮当前光标的单词
    use({ "yamatsum/nvim-cursorline", config = utils.fn.loadConfig({ "nvim-cursorline" }) })
    -- debug 调试工具  近期用不上
    -- use({
    -- 	{ "mfussenegger/nvim-dap", config = utils.fn.loadConfig({ "nvim-dap" }) },
    -- 	"theHamsta/nvim-dap-virtual-text",
    -- 	"rcarriga/nvim-dap-ui",
    -- })
    -- expand and repeat expression to multiple lines (fully configured) 将表达式扩展并重复到多行
    use({ "AllenDang/nvim-expand-expr", config = utils.fn.loadConfig({ "nvim-expand-expr" }) })
    -- unit test 单元测试
    -- use({
    -- 	"nvim-neotest/neotest",
    -- 	requires = {
    -- 		-- "nvim-treesitter/nvim-treesitter" is required
    -- 		"nvim-lua/plenary.nvim",
    -- 		"antoinemadec/FixCursorHold.nvim",
    -- 		-- adapters
    -- 		-- check more adapters on https://github.com/nvim-neotest/neotest#supported-runners
    -- 		"haydenmeade/neotest-jest",
    -- 		"nvim-neotest/neotest-go",
    -- 		"nvim-neotest/neotest-vim-test",
    -- 	},
    -- 	config = utils.fn.loadConfig({ "neotest" }),
    -- })
    -- git signs Git 标志
    -- use({ "lewis6991/gitsigns.nvim", config = utils.fn.loadConfig({ "gitsigns" }) })
    -- resolve git conflict 解决Git冲突
    use({ "akinsho/git-conflict.nvim", config = utils.fn.loadConfig({ "git-conflict" }) })
    -- colorizer (basically configured) 高亮颜色组
    use({ "norcalli/nvim-colorizer.lua", config = utils.fn.loadConfig({ "nvim-colorizer" }) })
    -- indentation guides 缩进线
    use({ "lukas-reineke/indent-blankline.nvim", config = utils.fn.loadConfig({ "indent-blankline" }) })
    -- tab line (basically configured) tab 标签 (base)
    use({
      "akinsho/bufferline.nvim",
      tag = "v2.*",
      requires = "kyazdani42/nvim-web-devicons",
      config = utils.fn.loadConfig({ "bufferline" }),
    })
    -- git diff gui git
    -- use({
    -- 	"sindrets/diffview.nvim",
    -- 	requires = "nvim-lua/plenary.nvim",
    -- 	config = utils.fn.loadConfig({ "diffview" }),
    -- })
    -- just use as a formatter manager now (continue to configure) 格式化配置
    -- use({
    -- 	"jose-elias-alvarez/null-ls.nvim",
    -- 	requires = "nvim-lua/plenary.nvim",
    -- 	config = utils.fn.loadConfig({ "null-ls" }),
    -- })
    -- fuzzy search (basically configured) 模糊搜索
    use({
      {
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = utils.fn.loadConfig({ "telescope" }),
      },
      -- extensions
      -- yank
      {
        "gbprod/yanky.nvim",
        config = utils.fn.loadConfig({ "yanky" }),
      },
      -- todo comments 代办事选
      {
        "folke/todo-comments.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = utils.fn.loadConfig({ "todo-comments" }),
      },
      -- project manager (basically configured)
      { "ahmedkhalf/project.nvim", config = utils.fn.loadConfig({ "project" }) },
    })
    -- aysnc tasks 不知道
    -- use({
    -- 	{
    -- 		"skywind3000/asynctasks.vim",
    -- 		requires = {
    -- 			"skywind3000/asyncrun.vim",
    -- 		},
    -- 		config = utils.fn.loadConfig({ "asynctasks" }),
    -- 	},
    -- 	-- search tasks with telescope
    -- 	{ "GustavoKatel/telescope-asynctasks.nvim" },
    -- })
    -- lsp lsp配置
    use({
      {
        "williamboman/nvim-lsp-installer",
        config = utils.fn.loadConfig({ "nvim-lsp-installer" }),
      },
      {
        "neovim/nvim-lspconfig",
        config = utils.fn.loadConfig({ "lsp" }),
      },
      {
        "tami5/lspsaga.nvim",
        config = utils.fn.loadConfig({ "lspsaga" }),
      },
    })
    -- 包围你的单词
    use("gcmt/wildfire.vim")
    -- 中文帮助文档
    use("wsdjeg/vimdoc-cn")
    -- 定制你的终端
    -- use("tracyone/term.vim")
    -- colorscheme (fully configured) 颜色主题
    use("folke/tokyonight.nvim")
    use("sainnhe/sonokai")
    use("rakr/vim-one")
    -- 浏览器扩展
    -- use {
    --   'glacambre/firenvim',
    --   run = function() vim.fn['firenvim#install'](0) end
    -- }
    -- 全局匹配替换
    use("dyng/ctrlsf.vim")
    -- api测试插件
    -- use("bewakes/vim-rest-client")
    -- use("diepm/vim-rest-console")
    -- orgmode 笔记
    -- use { 'nvim-orgmode/orgmode',
    --   ft = { 'org' },
    --   config = utils.fn.loadConfig({ "orgmode" })
    -- }
    -- org
    -- use("dhruvasagar/vim-dotoo")
    -- use("jceb/vim-orgmode")
    -- use("tpope/vim-speeddating"lspsaga)
    -- 文件管理器Ranger
    use({ "kevinhwang91/rnvimr", config = utils.fn.loadConfig({ "rnvimr" }) })
  end,
})
