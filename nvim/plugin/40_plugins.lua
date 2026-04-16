-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
---@diagnostic disable-next-line: unused-local
local now_if_args, later, on_event, on_filetype = Config.now_if_args, Config.later, Config.on_event, Config.on_filetype

local ensure_installed_treesitter = {
  'bash',
  'c',
  'c_sharp',
  'css',
  'dap_repl',
  'fish',
  'git_config',
  'gitignore',
  'graphql',
  'html',
  'hyprlang',
  'java',
  'javascript',
  'json',
  'json5',
  'latex',
  'markdown_inline',
  'python',
  'query',
  'rasi',
  'regex',
  'rust',
  'scss',
  'svelte',
  'tsx',
  'typescript',
  'typst',
  'vim',
  'vue',
  'yaml',
  'lua',
  'markdown',
  'vimdoc',
}

local ensure_installed_mason_packages = {
  -- install language servers
  'fish-lsp',
  'gh-actions-language-server',
  'lua-language-server',
  'marksman',
  'msbuild_project_tools_server',
  'roslyn',
  'sqls',
  'taplo',
  'tree-sitter-cli',
  'yaml-language-server',

  -- AI assistent
  -- "copilot-language-server",

  -- install formatters
  'black',
  'isort',
  'markdown-toc',
  'rust-analyzer',
  'stylua',

  -- linters
  'dotenv-linter',
  'shellcheck',

  -- install debuggers
  'debugpy',
  'firefox-debug-adapter',
  'local-lua-debugger-vscode',
}

-- File operations ============================================================
now_if_args(function()
  add { 'https://github.com/antosha417/nvim-lsp-file-operations' }
  require('lsp-file-operations').setup {}
  vim.lsp.config('*', {
    capabilities = require('lsp-file-operations').default_capabilities(),
  })
  local ok_mini_files, _ = pcall(require, 'mini.files')
  local log = require 'lsp-file-operations.log'
  if ok_mini_files then
    log.debug 'Setting up mini.files integration'

    Config.new_autocmd(
      'User',
      'MiniFilesActionCreate',
      function(args) require('lsp-file-operations.did-create').callback { fname = args.data.to } end,
      'execute `didCreateFiles` operation when creating files'
    )

    Config.new_autocmd(
      'User',
      'MiniFilesActionDelete',
      function(args) require('lsp-file-operations.did-delete').callback { fname = args.data.from } end,
      'execute `didDeleteFiles` operation when creating files'
    )

    Config.new_autocmd(
      'User',
      'MiniFilesActionRename',
      function(args) require('lsp-file-operations.did-rename').callback { old_name = args.data.from, new_name = args.data.to } end,
      'execute `didRenameFiles` operation when creating files'
    )
  end
end)

-- ╭─────────────────────────────────────────────────────────╮
-- │                        Which-key                        │
-- ╰─────────────────────────────────────────────────────────╯
later(function()
  add { 'https://github.com/folke/which-key.nvim' }

  local config = {
    preset = 'classic',
    notify = true,
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = true, suggestions = 20 },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    win = {
      border = vim.o.winborder,
    },
    keys = {
      scroll_down = '<c-d>',
      scroll_up = '<c-u>',
    },
    icons = {
      group = '',
      rules = false,
      separator = '-',
    },
  }

  if not vim.g.icons_enabled then
    config.icons.breadcrumb = '>'
    config.icons.group = '+'
    config.icons.keys = {
      Up = 'Up',
      Down = 'Down',
      Left = 'Left',
      Right = 'Right',
      C = 'Ctrl+',
      M = 'Alt+',
      D = 'Cmd+',
      S = 'Shift+',
      CR = 'Enter',
      Esc = 'Esc',
      ScrollWheelDown = 'ScrollDown',
      ScrollWheelUp = 'ScrollUp',
      NL = 'Enter',
      BS = 'Backspace',
      Space = 'Space',
      Tab = 'Tab',
      F1 = 'F1',
      F2 = 'F2',
      F3 = 'F3',
      F4 = 'F4',
      F5 = 'F5',
      F6 = 'F6',
      F7 = 'F7',
      F8 = 'F8',
      F9 = 'F9',
      F10 = 'F10',
      F11 = 'F11',
      F12 = 'F12',
    }
  end

  local wk = require 'which-key'
  wk.add(Config.leader_group_which_key)
  wk.setup(config)
end)
-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
now_if_args(function()
  -- Define hook to update tree-sitter parsers after plugin is updated
  local ts_update = function() vim.cmd 'TSUpdate' end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  add {
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    'https://github.com/nvim-treesitter/nvim-treesitter-context',
    'https://github.com/RRethy/nvim-treesitter-endwise',
  }

  -- Define languages which will have parsers installed and auto enabled
  -- After changing this, restart Neovim once to install necessary parsers. Wait
  -- for the installation to finish before opening a file for added language(s).
  local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0 end
  local to_install = vim.tbl_filter(isnt_installed, ensure_installed_treesitter)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  vim.treesitter.language.register('bash', 'kitty')
  vim.treesitter.language.register('xml', { 'msbuild' })
  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(ensure_installed_treesitter) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  -- enable treesitter extra plugins
  require('treesitter-context').setup {
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    multiwindow = false, -- Enable multiwindow support.
    max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 5, -- Maximum number of lines to show for a single context
    trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    separator = '─',
    zindex = 20, -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
  }
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
  add { 'https://github.com/neovim/nvim-lspconfig' }

  -- Use `:h vim.lsp.enable()` to automatically enable language server based on
  -- the rules provided by 'nvim-lspconfig'.
  -- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
  -- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
  -- vim.lsp.enable({
  --   -- For example, if `lua-language-server` is installed, use `'lua_ls'` entry
  -- })
end)

now_if_args(function()
  add {
    'https://github.com/mason-org/mason.nvim',
  }
  local mason_update = function() vim.cmd 'MasonUpdate' end
  Config.on_packchanged('mason.nvim', { 'update' }, mason_update, ':MasonUpdate')

  require('mason').setup {
    registries = {
      'github:mason-org/mason-registry',
      'github:Crashdummyy/mason-registry',
      'github:boydaihungst/mason-registry',
    },
    ui = {
      icons = vim.g.icons_enabled == false and {
        package_installed = 'O',
        package_uninstalled = 'X',
        package_pending = '0',
      } or {
        package_installed = '✓',
        package_uninstalled = '✗',
        package_pending = '⟳',
      },
    },
  }
end)

now_if_args(function()
  add {
    'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  }
  require('mason-tool-installer').setup {
    ensure_installed = ensure_installed_mason_packages,
    -- Disable alternative name from these package, only use name from Mason.Nvim
    integrations = { ['mason-lspconfig'] = false, ['mason-null-ls'] = false, ['mason-nvim-dap'] = false },
  }
end)

now_if_args(function()
  add {
    'https://github.com/mason-org/mason-lspconfig.nvim',
  }
  -- Borrow from astronvim. Auto config and enable lsp servers
  local _ = require 'mason-core.functional'
  local registry = require 'mason-registry'
  local mappings = require 'mason-lspconfig.mappings'

  local enabled_servers = {}
  if not mason_lsp_setup then
    _G.mason_lsp_setup = vim.schedule_wrap(function(mason_pkg)
      if type(mason_pkg) ~= 'string' then mason_pkg = mason_pkg.name end
      local lspconfig_name = mappings.get_mason_map().package_to_lspconfig[mason_pkg]
      if not lspconfig_name or enabled_servers[lspconfig_name] then return end

      local ok, config = pcall(require, 'mason-lspconfig.lsp.' .. lspconfig_name)
      if ok then vim.lsp.config(lspconfig_name, config) end

      vim.lsp.enable(lspconfig_name)
      enabled_servers[lspconfig_name] = true
    end)
  end

  _.each(mason_lsp_setup, registry.get_installed_package_names())
  registry.refresh(vim.schedule_wrap(function(success, updated_registries)
    if success and #updated_registries > 0 then _.each(mason_lsp_setup, registry.get_installed_package_names()) end
  end))
  registry:off('package:install:success', mason_lsp_setup)
  registry:on('package:install:success', mason_lsp_setup)

  require('mason-lspconfig').setup {
    automatic_enable = true,
    ensure_installed = nil, -- because we use mason-tool-installer to install lsp severs
  }
end)

now_if_args(function()
  add {
    'https://github.com/jay-babu/mason-nvim-dap.nvim',
  }
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
  add { 'https://github.com/stevearc/conform.nvim' }

  -- See also:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  require('conform').setup {
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter is available
      lsp_format = 'fallback',
    },
    format_on_save = function(bufnr)
      if vim.F.if_nil(vim.b[bufnr].autoformat, vim.g.autoformat, true) then return { lsp_format = 'fallback' } end
    end,
    formatters_by_ft = {
      toml = { 'taplo' },
      markdown = { 'markdown-toc', 'prettierd', stop_after_first = false },
      sh = { 'shfmt' },
    },
    formatters = {
      -- nginxfmt = {
      --   -- Change where to find the command
      --   command = os.getenv "HOME" .. "/.venv/bin/nginxfmt",
      -- },
      taplo = {
        -- prepend_args = { "-o", "" },
        env = {
          TAPLO_CONFIG = os.getenv 'HOME' .. '/.config/.taplo.toml',
        },
      },
      ['clang-format'] = {},
      stylua = {
        prepend_args = { '--syntax', 'LuaJIT' },
      },
    },
    -- Set the log level. Use `:ConformInfo` to see the location of the log file.
    log_level = vim.log.levels.OFF,
    -- Conform will notify you when a formatter errors
    notify_on_error = true,
    -- Conform will notify you when no formatters are available for the buffer
    notify_no_formatters = true,
  }

  vim.api.nvim_create_user_command('Format', function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = {
        start = { args.line1, 0 },
        ['end'] = { args.line2, end_line:len() },
      }
    end
    require('conform').format { async = true, range = range }
  end, { desc = 'Format buffer', range = true })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function() add { 'https://github.com/rafamadriz/friendly-snippets' } end)

-- Honorable mentions =========================================================

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
-- Config.now(function()
--  -- Install only those that you need
--  add({
--    'https://github.com/sainnhe/everforest',
--    'https://github.com/Shatur/neovim-ayu',
--    'https://github.com/ellisonleao/gruvbox.nvim',
--  })
--
--   -- Enable only one
--   vim.cmd('color everforest')
-- end)
on_filetype('lua', function()
  add {
    'https://github.com/folke/lazydev.nvim',
    -- 'https://github.com/DrKJeff16/wezterm-types',
  }
  require('lazydev').setup {
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      { path = os.getenv 'HOME' .. '/.config/yazi/plugins/types.yazi', words = { 'ya%.', 'ui%.' } },
      -- { path = "wezterm-types", mods = { "wezterm" } },
    },
  }
end)
