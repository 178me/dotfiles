return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        -- init = function()
        --   -- PERF: no need to load the plugin, if we only need its queries for mini.ai
        --   local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
        --   local opts = require("lazy.core.plugin").values(plugin, "opts", false)
        --   local enabled = false
        --   if opts.textobjects then
        --     for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
        --       if opts.textobjects[mod] and opts.textobjects[mod].enable then enabled = true break
        --       end
        --     end
        --   end
        --   if not enabled then
        --     require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
        --   end
        -- end,
      },
    },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Schrink selection", mode = "x" },
    },
    ---Neovim 0.12 会在部分 directive 中传入 TSNode 列表。
    ---旧版 nvim-treesitter 把它当 TSNode 使用会触发 node:range() 崩溃。
    local_patch = function()
      local query = require("vim.treesitter.query")

      local html_script_type_languages = {
        ["importmap"] = "json",
        ["module"] = "javascript",
        ["application/ecmascript"] = "javascript",
        ["text/ecmascript"] = "javascript",
      }

      local non_filetype_match_injection_language_aliases = {
        ex = "elixir",
        pl = "perl",
        sh = "bash",
        uxn = "uxntal",
        ts = "typescript",
      }

      local function get_parser_from_markdown_info_string(injection_alias)
        local match = vim.filetype.match({ filename = "a." .. injection_alias })
        return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
      end

      local function normalize_node(node)
        if type(node) == "table" then
          return node[1]
        end
        return node
      end

      local directive_opts = vim.fn.has("nvim-0.10") == 1 and { force = true, all = false } or true

      query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
        local node = normalize_node(match[pred[2]])
        if not node then
          return
        end
        local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
        local configured = html_script_type_languages[type_attr_value]
        if configured then
          metadata["injection.language"] = configured
        else
          local parts = vim.split(type_attr_value, "/", {})
          metadata["injection.language"] = parts[#parts]
        end
      end, directive_opts)

      query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
        local node = normalize_node(match[pred[2]])
        if not node then
          return
        end
        local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
        metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
      end, directive_opts)

      query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
        local id = pred[2]
        local node = normalize_node(match[id])
        if not node then
          return
        end
        local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
        if not metadata[id] then
          metadata[id] = {}
        end
        metadata[id].text = string.lower(text)
      end, directive_opts)
    end,
    ---@type TSConfig
    opts = {
      auto_install = true,
      sync_install = false,
      ignore_install = {},
      modules = {},
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true, disable = { "python" } },
      rainbow = {
        enable = true,
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean max_file_lines = nil, -- Do not enable for files with more than n lines, int
        colors = { "#0099ff", "#00ff00", "#ff4dc3", "#ffff00", "#ff9933" }, -- table of hex strings
      },
      matchup = {
        enable = true,
      },
      context_commentstring = { enable = true, enable_autocmd = false },
      ensure_installed = {
        "bash",
        "c",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "vue",
        "css",
        "scss",
        "go",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<nop>",
          node_decremental = "<bs>",
        },
      },
    },
    ---@param opts TSConfig
    config = function(plugin, opts)
      require("nvim-treesitter.configs").setup(opts)
      plugin.local_patch()
    end,
  },
}
