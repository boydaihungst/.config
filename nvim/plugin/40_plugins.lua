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
  'tree-sitter-cli',
  'fish-lsp',
  'gh-actions-language-server',
  'lua-language-server',
  'marksman',
  'msbuild_project_tools_server',
  'roslyn',
  'sqls',
  'taplo',
  'yaml-language-server',
  'ast-grep',

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
  _G.wk = wk
  wk.add(Config.leader_group_which_key)
  wk.setup(config)
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
  -- Enable via mason below
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
  local mason_tool_installer = require 'mason-tool-installer'
  mason_tool_installer.setup {
    ensure_installed = ensure_installed_mason_packages,
    -- Disable alternative name from these package, only use name from Mason.Nvim
    integrations = { ['mason-lspconfig'] = false, ['mason-null-ls'] = false, ['mason-nvim-dap'] = false },
  }
  -- Install at the startup
  mason_tool_installer.run_on_start()
end)

now_if_args(function()
  add {
    -- dependencies
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.x' },
    'https://github.com/mason-org/mason-lspconfig.nvim',
  }
  vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
  })

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
    'https://github.com/andersevenrud/nvim_context_vt', -- Shows virtual text of the current context after functions, methods, statements, etc.
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

  require('nvim_context_vt').setup {
    prefix = Config.get_custom_icon 'ArrowRight',
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

-- Search and Replace with gui
later(function()
  add { 'https://github.com/MagicDuck/grug-far.nvim' }
  require('grug-far').setup {
    transient = true,
  }
  local default_opts = { instanceName = 'main' }
  local function grug_far_open(opts, with_visual)
    local grug_far = require 'grug-far'
    opts = vim.tbl_extend('force', default_opts, opts or {})
    if not grug_far.has_instance(opts.instanceName) then
      grug_far.open(opts)
    else
      if with_visual then
        if not opts.prefills then opts.prefills = {} end
        opts.prefills.search = grug_far.get_current_visual_selection()
      end
      grug_far.get_instance(opts.instanceName):open()
      if opts.prefills then grug_far.get_instance(opts.instanceName):update_input_values(opts.prefills, false) end
    end
  end
  if MiniFiles then
    Config.new_autocmd('User', 'MiniFilesBufferCreate', function(args)
      vim.keymap.set(
        'n',
        '?',
        function() grug_far_open { prefills = { paths = vim.fs.dirname(require('mini.files').get_fs_entry().path) } } end,
        { buffer = args.data.buf_id, desc = 'Search/Replace in directory' }
      )
    end, 'Create mapping in `mini.files` for searching in directory')
  end
  local key_prefix = '<Leader>s'
  if wk then wk.add { { key_prefix, group = Config.get_custom_icon('GrugFar', 1, true) .. 'Search/Replace', mode = { 'n', 'x' } } } end
  -- Workspace Search
  vim.keymap.set('n', key_prefix .. 's', function() grug_far_open() end, { desc = 'Search/Replace workspace' })

  -- Filetype Search
  vim.keymap.set('n', key_prefix .. 'e', function()
    local ext = vim.api.nvim_buf_is_valid(0) and vim.bo.buflisted and vim.fn.expand '%:e' or ''
    grug_far_open {
      prefills = { filesFilter = ext ~= '' and '*.' .. ext or nil },
    }
  end, { desc = 'Search/Replace filetype' })

  -- Current File Search
  vim.keymap.set('n', key_prefix .. 'f', function()
    local filter = vim.api.nvim_buf_is_valid(0) and vim.bo.buflisted and vim.fn.fnameescape(vim.fn.expand '%') or nil
    grug_far_open { prefills = { paths = filter } }
  end, { desc = 'Search/Replace file' })

  -- Word under cursor (Normal mode)
  vim.keymap.set('n', key_prefix .. 'w', function()
    local current_word = vim.fn.expand '<cword>'
    if current_word ~= '' then
      grug_far_open {
        startCursorRow = 4,
        prefills = { search = current_word },
      }
    else
      vim.notify('No word under cursor', vim.log.levels.WARN, { title = 'Grug-far' })
    end
  end, { desc = 'Search/Replace word' })

  -- Selection Search (Visual mode)
  vim.keymap.set('x', key_prefix .. 'w', function() grug_far_open(nil, true) end, { desc = 'Replace selection' })
end)
later(function()
  add { 'https://github.com/LudoPinelli/comment-box.nvim' }
  require('comment-box').setup {
    comment_style = 'auto',
    outer_blank_lines_above = true, -- insert a blank line above the box
    outer_blank_lines_below = true, -- insert a blank line below the box
    inner_blank_lines = true, -- insert a blank line above and below the text
    line_blank_line_above = true, -- insert a blank line above the line
    line_blank_line_below = true, -- insert a blank line below the line
  }
  local key_prefix = '<Leader>B'
  local modes = { 'n', 'x' }
  if wk then
    wk.add {
      { key_prefix, group = Config.get_custom_icon('CommentBox', 1, true) .. 'Comment Box/Line', mode = modes },
      { key_prefix .. 'b', group = 'Comment Box', mode = modes },
      { key_prefix .. 'l', group = 'Comment Line', mode = modes },
    }
  end
  vim.keymap.set(modes, key_prefix .. 'bl', '<Cmd>CBllbox<Cr>', { desc = 'Comment Box Left' })
  vim.keymap.set(modes, key_prefix .. 'bc', '<Cmd>CBlcbox<Cr>', { desc = 'Comment Box Center' })
  vim.keymap.set(modes, key_prefix .. 'br', '<Cmd>CBlrbox<Cr>', { desc = 'Comment Box Right' })

  vim.keymap.set(modes, key_prefix .. 'll', '<Cmd>CBllline<Cr>', { desc = 'Comment Line Left' })
  vim.keymap.set(modes, key_prefix .. 'lc', '<Cmd>CBlcline<Cr>', { desc = 'Comment Line Center' })
  vim.keymap.set(modes, key_prefix .. 'lr', '<Cmd>CBlrline<Cr>', { desc = 'Comment Line Right' })
end)
on_event('LspAttach', function()
  add { 'https://github.com/j-hui/fidget.nvim' }
  require('fidget').setup {
    -- Options related to LSP progress subsystem
    progress = {
      ignore = {}, -- List of LSP servers to ignore

      -- Options related to how LSP progress messages are displayed as notifications
      display = {
        render_limit = 5, -- How many LSP messages to show at once
        done_ttl = 1, -- How long a message should persist after completion
        done_icon = '✔', -- Icon shown when all LSP progress tasks are complete
        done_style = 'Constant', -- Highlight group for completed LSP tasks
        -- Icon shown when LSP progress tasks are in progress
        progress_icon = { 'dots' },
        -- Highlight group for in-progress LSP tasks
        progress_style = 'WarningMsg',
        group_style = 'Title', -- Highlight group for group name (LSP server name)
        icon_style = 'Question', -- Highlight group for group icons
        overrides = { -- Override options from the default notification config
          rust_analyzer = { name = 'rust-analyzer' },
        },
      },

      -- Options related to Neovim's built-in LSP client
      lsp = {
        progress_ringbuf_size = 0, -- Configure the nvim's LSP progress ring buffer size
        log_handler = false, -- Log `$/progress` handler invocations (for debugging)
      },
    },
  }
end)

on_event('BufEnter', function()
  add { 'https://github.com/stevearc/aerial.nvim' }
  require('aerial').setup {
    attach_mode = 'global',
    backends = { 'lsp', 'treesitter', 'markdown', 'man' },
    layout = { min_width = 28 },
    filter_kind = false,
    guides = {
      mid_item = '├ ',
      last_item = '└ ',
      nested_top = '│ ',
      whitespace = '  ',
    },
    keymaps = {
      ['[y'] = 'actions.prev',
      [']y'] = 'actions.next',
      ['[Y'] = 'actions.prev_up',
      [']Y'] = 'actions.next_up',
      ['{'] = false,
      ['}'] = false,
      ['[['] = false,
      [']]'] = false,
    },
    on_attach = function(bufnr)
      local aerial = require 'aerial'
      vim.keymap.set('n', ']y', function() aerial.next(vim.v.count1) end, { buffer = bufnr, desc = 'Next symbol' })
      vim.keymap.set('n', '[y', function() aerial.prev(vim.v.count1) end, { buffer = bufnr, desc = 'Previous symbol' })
      vim.keymap.set('n', ']Y', function() aerial.next_up(vim.v.count1) end, { buffer = bufnr, desc = 'Next symbol upwards' })
      vim.keymap.set('n', '[Y', function() aerial.prev_up(vim.v.count1) end, { buffer = bufnr, desc = 'Previous symbol upwards' })
    end,
    close_automatic_events = { 'unfocus', 'unsupported' },
    highlight_on_hover = true,
    -- Jump to symbol in source window when the cursor moves
    autojump = true,

    -- Automatically open aerial when entering supported buffers.
    -- This can be a function (see :help aerial-open-automatic)
    open_automatic = false,

    -- -- Use symbol tree for folding. Set to true or false to enable/disable
    -- -- Set to "auto" to manage folds if your previous foldmethod was 'manual'
    -- -- This can be a filetype map (see :help aerial-filetype-map)
    manage_folds = false,
    --
    -- -- When you fold code with za, zo, or zc, update the aerial tree as well.
    -- -- Only works when manage_folds = true
    link_folds_to_tree = true,
    --
    -- -- Fold code when you open/collapse symbols in the tree.
    -- -- Only works when manage_folds = true
    link_tree_to_folds = true,
    -- Show box drawing characters for the tree hierarchy
    show_guides = true,
    --TODO: disable if big buffer
    disable_max_lines = 10000,
  }
end)
later(function()
  add { 'https://github.com/otavioschwanck/arrow.nvim' }
  require('arrow').setup {
    show_icons = vim.g.icons_enabled,
    leader_key = 'M', -- Recommended to be a single key
    buffer_leader_key = 'm', -- Per Buffer Mappings
    always_show_path = false,
    separate_by_branch = true, -- Bookmarks will be separated by git branch
    hide_handbook = false, -- set to true to hide the shortcuts on menu.
    separate_save_and_remove = true, -- if true, will remove the toggle and create the save/remove keymaps.
    save_key = 'cwd', -- what will be used as root to save the bookmarks. Can be also `git_root` and `git_root_bare`.
    global_bookmarks = false, -- if true, arrow will save files globally (ignores separate_by_branch)
    index_keys = '123456789zxcbnmZXVBNM,afghjklAFGHJKLwrtyuiopWRTYUIOP', -- keys mapped to bookmark index, i.e. 1st bookmark will be accessible by 1, and 12th - by c
    mappings = {
      edit = 'e',
      delete_mode = 'd',
      clear_all_items = 'C',
      toggle = 's', -- used as save if separate_save_and_remove is true
      open_vertical = 'v',
      open_horizontal = '-',
      quit = 'q',
      remove = 'x', -- only used if separate_save_and_remove is true
      next_item = ']',
      prev_item = '[',
    },
    window = { -- controls the appearance and position of an arrow window (see nvim_open_win() for all options)
      width = 'auto',
      height = 'auto',
      row = 'auto',
      col = 'auto',
      border = vim.o.winborder,
    },
    per_buffer_config = {
      lines = 4, -- Number of lines showed on preview.
      sort_automatically = true, -- Auto sort buffer marks.
      satellite = { -- default to nil, display arrow index in scrollbar at every update
        enable = true,
        overlap = true,
        priority = 1000,
      },
      -- zindex = 10, --default 50
      -- treesitter_context = {
      --   line_shift_down = 2,
      -- }, -- it can be { line_shift_down = 2 }, currently not usable, for detail see https://github.com/otavioschwanck/arrow.nvim/pull/43#issue-2236320268
    },
  }
end)
later(function()
  add { 'https://github.com/monaqa/dial.nvim' }

  local augend = require 'dial.augend'

  local logical_alias = augend.constant.new {
    elements = { '&&', '||' },
    word = true,
    cyclic = true,
  }

  local and_or = augend.constant.new {
    elements = {
      'and',
      'or',
    },
    word = true,
    cyclic = true,
  }

  local ordinal_numbers = augend.constant.new {
    -- elements through which we cycle. When we increment, we go down
    -- On decrement we go up
    elements = {
      'first',
      'second',
      'third',
      'fourth',
      'fifth',
      'sixth',
      'seventh',
      'eighth',
      'ninth',
      'tenth',
    },
    -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
    word = false,
    -- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
    -- Otherwise nothing will happen when there are no further values
    cyclic = true,
    match_before_cursor = true,
  }

  local weekdays = augend.constant.new {
    elements = {
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    },
    word = true,
    cyclic = true,
    match_before_cursor = true,
  }

  local months = augend.constant.new {
    elements = {
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    },
    word = true,
    cyclic = true,
    match_before_cursor = true,
  }

  local capitalized_boolean = augend.constant.new {
    elements = {
      'True',
      'False',
    },
    word = true,
    cyclic = true,
  }

  local import_export = augend.constant.new {
    elements = {
      'import',
      'export',
    },
    word = true,
    cyclic = true,
    match_before_cursor = true,
  }
  local yes_no = augend.constant.new {
    elements = {
      'yes',
      'no',
    },
    word = true,
    cyclic = true,
    match_before_cursor = true,
  }
  local groups = {
    default = {
      augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
      augend.integer.alias.decimal_int, -- nonnegative and negative decimal number
      augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
      augend.date.alias['%Y/%m/%d'], -- date (2022/02/18, etc.)
      ordinal_numbers,
      weekdays,
      months,
      capitalized_boolean,
      augend.constant.alias.bool, -- boolean value (true <-> false)
      logical_alias,
      and_or,
      yes_no,
    },
    ssa = {
      augend.constant.new {
        elements = {
          '640',
          '1920',
        },
        word = true,
        cyclic = true,
        match_before_cursor = true,
      },
      augend.constant.new {
        elements = {
          '360',
          '1080',
        },
        word = true,
        cyclic = true,
        match_before_cursor = true,
      },
    },
    vue = {
      augend.constant.new { elements = { 'let', 'const' }, match_before_cursor = true, word = true, cyclic = true },
      import_export,
      augend.hexcolor.new { case = 'lower', match_before_cursor = true },
      augend.hexcolor.new { case = 'upper', match_before_cursor = true },
      augend.constant.new {
        elements = {
          '|',
          '&',
        },
        word = true,
        cyclic = true,
      },
      augend.constant.new {
        elements = {
          '!=',
          '==',
        },
        word = true,
        cyclic = true,
      },
    },
    typescript = {
      augend.constant.new { elements = { 'let', 'const' }, match_before_cursor = true, word = true, cyclic = true },
      import_export,
    },
    css = {
      augend.hexcolor.new {
        case = 'lower',
        match_before_cursor = true,
      },
      augend.hexcolor.new {
        case = 'upper',
        match_before_cursor = true,
      },
    },
    markdown = {
      augend.constant.new {
        elements = { '[ ]', '[x]' },
        word = false,
        cyclic = true,
        match_before_cursor = true,
      },
      augend.misc.alias.markdown_header,
    },
    json = {
      augend.semver.alias.semver, -- versioning (v1.1.2)
    },
    lua = {
      augend.constant.new {
        elements = { '~=', '==' },
        word = true,
        cyclic = true,
      },
      augend.constant.new {
        elements = {
          'if',
          'else',
          'elseif',
        },
        word = true,
        cyclic = true,
        match_before_cursor = true,
      },
    },
    python = {
      import_export,
      augend.constant.new {
        elements = {
          'if',
          'else',
          'elif',
        },
        word = true,
        cyclic = true,
        match_before_cursor = true,
      },
    },
  }

  local dial_config = require 'dial.config'
  -- copy defaults to each group
  for name, group in pairs(groups) do
    if name ~= 'default' then vim.list_extend(group, groups.default) end
  end
  dial_config.augends:register_group(groups)
  dial_config.augends:on_filetype(groups)

  vim.keymap.set('n', '<C-a>', function() require('dial.map').manipulate('increment', 'normal') end)
  vim.keymap.set('n', '<C-x>', function() require('dial.map').manipulate('decrement', 'normal') end)
  vim.keymap.set('n', 'g<C-a>', function() require('dial.map').manipulate('increment', 'gnormal') end)
  vim.keymap.set('n', 'g<C-x>', function() require('dial.map').manipulate('decrement', 'gnormal') end)
  vim.keymap.set('x', '<C-a>', function() require('dial.map').manipulate('increment', 'visual') end)
  vim.keymap.set('x', '<C-x>', function() require('dial.map').manipulate('decrement', 'visual') end)
  vim.keymap.set('x', 'g<C-a>', function() require('dial.map').manipulate('increment', 'gvisual') end)
  vim.keymap.set('x', 'g<C-x>', function() require('dial.map').manipulate('decrement', 'gvisual') end)
end)

later(function()
  add { 'https://github.com/linrongbin16/gitlinker.nvim' }
  local function to_litteral(str) return str and str:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1') end
  require('gitlinker').setup {
    router = {
      browse = {
        -- My gitea server
        -- https://git.linuxholic.com/boydaihungst/AnimeSubtitles/src/commit/250145403bde3858562337528233b0707fdf6e86/typesetting_fonts.txt#L4-L10
        [to_litteral 'ssh.linuxholic.com'] = 'https://git.linuxholic.com/'
          .. '{_A.ORG}/'
          .. '{_A.REPO}/src/commit/'
          .. '{_A.REV}/'
          .. '{_A.FILE}'
          .. '#L{_A.LSTART}-L{_A.LEND}',
      },
      blame = {
        -- My gitea server
        -- https://git.linuxholic.com/boydaihungst/AnimeSubtitles/blame/commit/250145403bde3858562337528233b0707fdf6e86/typesetting_fonts.txt#L4-L10
        [to_litteral 'ssh.linuxholic.com'] = 'https://git.linuxholic.com/'
          .. '{_A.ORG}/'
          .. '{_A.REPO}/blame/commit/'
          .. '{_A.REV}/'
          .. '{_A.FILE}'
          .. '#L{_A.LSTART}-L{_A.LEND}',
      },
    },
  }
  local prefix = '<leader>g'

  vim.keymap.set({ 'n', 'x' }, prefix .. 'y', '<cmd>GitLink<cr>', { desc = 'Copy Git link' })
  vim.keymap.set({ 'n', 'x' }, prefix .. 'z', '<cmd>GitLink!<cr>', { desc = 'Open Git link' })
end)

later(function()
  add { 'https://github.com/kevinhwang91/nvim-hlslens' }

  local hlslens = require 'hlslens'
  hlslens.setup {
    -- NOTE: disable this because it makes mini.files incremental search error
    enable_incsearch = false,
    override_lens = function(render, posList, nearest, idx, relIdx)
      local text, chunks

      local lnum, col = unpack(posList[idx])
      if nearest then
        local cnt = #posList
        text = ('[%d/%d]'):format(idx or 0, cnt or 0)
        chunks = { { ' ' }, { text, 'IncSearch' } }
      else
        text = ('[%d]'):format(idx or 0)
        chunks = { { ' ' }, { text, 'CurSearch' } }
      end
      render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
    end,
  }

  local function n_with_hlslens(char)
    local count = vim.v.count1
    -- Executes the normal command (n, N, *, etc) then starts hlslens
    vim.cmd(('normal! %d%s'):format(count, char))
    hlslens.start()
  end

  -- n and N
  vim.keymap.set('n', 'n', function() n_with_hlslens 'n' end, { silent = true, desc = 'Next search result' })
  vim.keymap.set('n', 'N', function() n_with_hlslens 'N' end, { silent = true, desc = 'Prev search result' })

  -- * and # (Directly trigger the command then start hlslens)
  vim.keymap.set('n', '*', '*<Cmd>lua require("hlslens").start()<CR>', { silent = true, desc = 'Search word forward' })
  vim.keymap.set('n', '#', '#<Cmd>lua require("hlslens").start()<CR>', { silent = true, desc = 'Search word backward' })

  -- g* and g#
  vim.keymap.set('n', 'g*', 'g*<Cmd>lua require("hlslens").start()<CR>', { silent = true, desc = 'Search word forward (partial)' })
  vim.keymap.set('n', 'g#', 'g#<Cmd>lua require("hlslens").start()<CR>', { silent = true, desc = 'Search word backward (partial)' })
end)

on_filetype('vue,typescript,javascript,typescriptreact,javascriptreact,tsx,jsx,java,json,yaml', function()
  add { 'https://github.com/yelog/i18n.nvim' }
  local original_sig_help = vim.lsp.buf.signature_help

  require('i18n').setup {
    activation = 'lazy',
    show_mode = 'both',
    diagnostic = true,
    -- Locales to parse; first is the default locale
    -- Use I18nNextLocale command to switch the default locale in real time
    locales = { 'en', 'vn', 'jp', 'zh', 'en_US', 'vi_VN', 'ja_JP', 'zh_CN' },
    usage = {
      -- Popup provider used when choosing between multiple usage locations
      -- Available values: 'vim_ui', 'telescope', 'fzf-lua', 'snacks'
      popup_type = 'vim_ui',
      notify_no_key = false,
      max_file_size = 0, -- 0 = no limit
      scan_on_startup = true,
    },
    func_pattern = { 't', '$t' },
    -- sources can be string or table { pattern = "...", prefix = "..." }
    -- Project-level configuration files
    -- .i18nrc.json
    -- i18n.config.json
    -- .i18nrc.lua
    sources = {
      'src/locales/{locales}.json',
      'src/lang/{locales}.json',
      -- { pattern = "src/locales/lang/{locales}/{module}.ts",            prefix = "{module}." },
      -- { pattern = "src/views/{bu}/locales/lang/{locales}/{module}.ts", prefix = "{bu}.{module}." },
    },
    i18n_keys = {
      popup_type = 'vim_ui',
    },

    -- Enable namespace resolution
    -- false: Disabled, no namespace resolution
    -- 'auto': Auto-detect framework based on filetype (tsx/jsx → react_i18next, vue → vue_i18n)
    -- 'react_i18next': Detect useTranslation('namespace') calls in React components
    -- 'vue_i18n': Detect useI18n({ namespace: '...' }) in Vue components
    namespace_resolver = 'auto', -- or 'react_i18next', 'vue_i18n', custom function, or table
    -- Separator between namespace and key
    namespace_separator = '.', -- set ':' for i18next standard
  }
  vim.lsp.buf.signature_help = function(opts)
    if require('i18n.display').get_key_under_cursor() then
      require('i18n').show_popup()
    else
      opts = vim.tbl_extend('force', opts, {
        anchor_bias = 'above',
      })
      return original_sig_help(opts)
    end
  end

  vim.g.changed_sign_helper = true
  Config.new_autocmd('DirChanged', '*', function()
    if vim.fn.exists ':I18nReload' == 2 then vim.cmd 'I18nReload' end
  end, 'Reload i18n on cwd/workspace changed')
end)

on_event('LspAttach', function()
  add {
    'https://github.com/Fildo7525/pretty_hover',
  }
  require('pretty_hover').setup {}
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.buf.hover = function(opts)
    if not pcall(require, 'i18n') then return require('pretty_hover').hover(opts) end
    if require('i18n.display').get_key_under_cursor() then
      require('i18n').show_popup()
      return
    end
    require('pretty_hover').hover()
  end
end)

on_event('InsertEnter,CmdlineEnter', function()
  add {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/xzbdmw/colorful-menu.nvim',
    'https://github.com/Fildo7525/pretty_hover',
    -- sources
    'https://github.com/Kaiser-Yang/blink-cmp-git',
    'https://github.com/disrupted/blink-cmp-conventional-commits',
    'https://github.com/yelog/i18n.nvim',

    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.x' },
  }

  -- local function has_words_before()
  --   local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  --   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
  -- end

  -- Check if there is any autopair fastwrap extmarks
  -- local function has_fastwrap_extmarks(bufnr)
  --   bufnr = bufnr or 0 -- Default to current buffer
  --   local fastwarp_exist, fastwarp = pcall(require, 'nvim-autopairs.fastwrap')
  --   if not fastwarp_exist then return false end
  --   local line_num = vim.api.nvim_win_get_cursor(0)[1] - 1
  --   local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, fastwarp.ns_fast_wrap, { line_num, 0 }, { line_num, -1 }, { details = false, limit = 1 })
  --
  --   return #extmarks > 0
  -- end

  ---@type function?, function?
  local icon_provider, hl_provider

  local function get_kind_icon(CTX)
    -- Evaluate icon provider
    if not icon_provider then
      local _, mini_icons = pcall(require, 'mini.icons')
      if _G.MiniIcons then
        icon_provider = function(ctx)
          local is_specific_color = ctx.kind_hl and ctx.kind_hl:match '^HexColor' ~= nil
          if ctx.item.source_name == 'LSP' then
            local icon, hl = mini_icons.get('lsp', ctx.kind or '')
            if icon then
              ctx.kind_icon = icon
              if not is_specific_color then ctx.kind_hl = hl end
            end
          elseif ctx.item.source_name == 'Path' then
            ctx.kind_icon, ctx.kind_hl = mini_icons.get(ctx.kind == 'Folder' and 'directory' or 'file', ctx.label)
          elseif ctx.item.source_name == 'Snippets' then
            ctx.kind_icon, ctx.kind_hl = mini_icons.get('lsp', 'snippet')
          end
        end
      end
      if not icon_provider then
        local lspkind_avail, lspkind = pcall(require, 'lspkind')
        if lspkind_avail then
          icon_provider = function(ctx)
            if ctx.item.source_name == 'LSP' then
              local icon = lspkind.symbol_map[ctx.kind]
              if icon then ctx.kind_icon = icon end
            elseif ctx.item.source_name == 'Snippets' then
              local icon = lspkind.symbol_map['Snippet']
              if icon then ctx.kind_icon = icon end
            end
          end
        end
      end
      if not icon_provider then icon_provider = function() end end
    end
    -- Evaluate highlight provider
    if not hl_provider then
      local highlight_colors_avail, highlight_colors = pcall(require, 'nvim-highlight-colors')
      if highlight_colors_avail then
        local kinds
        hl_provider = function(ctx)
          if not kinds then kinds = require('blink.cmp.types').CompletionItemKind end
          if ctx.item.kind == kinds.Color then
            local doc = vim.tbl_get(ctx, 'item', 'documentation')
            if doc then
              local color_item = highlight_colors_avail and highlight_colors.format(doc, { kind = kinds[kinds.Color] })
              if color_item and color_item.abbr_hl_group then
                if color_item.abbr then ctx.kind_icon = color_item.abbr end
                ctx.kind_hl = color_item.abbr_hl_group
              end
            end
          end
        end
      end
      if not hl_provider then hl_provider = function() end end
    end
    -- Call resolved providers
    icon_provider(CTX)
    hl_provider(CTX)
    -- Return text and highlight information
    return { text = CTX.kind_icon .. CTX.icon_gap, highlight = CTX.kind_hl }
  end

  require('blink.cmp').setup {
    enabled = function()
      local dap_prompt = pcall(require, 'cmp-dap') -- add interoperability with cmp-dap
        and vim.tbl_contains({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, vim.bo.filetype)
      if vim.bo.buftype == 'prompt' and not dap_prompt then return false end
      return vim.b.completion ~= false
    end,
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'i18n', 'conventional_commits', 'git', 'lazydev' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        git = {
          module = 'blink-cmp-git',
          name = 'Git',
          -- only enable this source when filetype is gitcommit, markdown, or 'octo'
          enabled = function() return vim.tbl_contains({ 'octo', 'gitcommit', 'markdown' }, vim.bo.filetype) end,
          --- @module 'blink-cmp-git'
          --- @type blink-cmp-git.Options
          opts = {
            commit = {
              -- You may want to customize when it should be enabled
              -- The default will enable this when `git` is found and `cwd` is in a git repository
              -- enable = function() end
              -- You may want to change the triggers
              -- triggers = { ':' },
            },
            git_centers = {
              github = {
                -- Those below have the same fields with `commit`
                -- Those features will be enabled when `git` and `gh` (or `curl`) are found and
                -- remote contains `github.com`
                -- issue = {
                --     get_token = function() return '' end,
                -- },
                -- pull_request = {
                --     get_token = function() return '' end,
                -- },
                -- mention = {
                --     get_token = function() return '' end,
                --     get_documentation = function(item)
                --         local default = require('blink-cmp-git.default.github')
                --             .mention.get_documentation(item)
                --         default.get_token = function() return '' end
                --         return default
                --     end
                -- }
              },
              gitlab = {
                -- Those below have the same fields with `commit`
                -- Those features will be enabled when `git` and `glab` (or `curl`) are found and
                -- remote contains `gitlab.com`
                -- issue = {
                --     get_token = function() return '' end,
                -- },
                -- NOTE:
                -- Even for `gitlab`, you should use `pull_request` rather than`merge_request`
                -- pull_request = {
                --     get_token = function() return '' end,
                -- },
                -- mention = {
                --     get_token = function() return '' end,
                --     get_documentation = function(item)
                --         local default = require('blink-cmp-git.default.gitlab')
                --            .mention.get_documentation(item)
                --         default.get_token = function() return '' end
                --         return default
                --     end
                -- }
              },
            },
          },
        },
        conventional_commits = {
          name = 'Conventional Commits',
          module = 'blink-cmp-conventional-commits',
          enabled = function() return vim.bo.filetype == 'gitcommit' end,
          ---@module 'blink-cmp-conventional-commits'
          ---@type blink-cmp-conventional-commits.Options
          opts = {}, -- none so far
        },
        -- Path completion from cwd instead of current buffer's directory
        path = {
          opts = {
            get_cwd = function(_) return vim.fn.getcwd() end,
          },
        },
        i18n = {
          name = 'i18n',
          module = 'i18n.integration.blink_source',
        },
      },
    },
    keymap = {
      ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-N>'] = { 'select_next', 'show' },
      ['<C-P>'] = { 'select_prev', 'show' },
      ['<C-J>'] = { 'select_next', 'fallback' },
      ['<C-K>'] = { 'select_prev', 'fallback' },
      ['<C-U>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-D>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-e>'] = { 'hide', 'fallback' },
      -- recommended, as the default keymap will only show and select the next item
      -- NOTE: use mini.keymap instead
      -- ['<Tab>'] = {
      --   -- function(cmp)
      --   --   if cmp.is_ghost_text_visible() and not cmp.is_menu_visible() then return cmp.accept() end
      --   -- end,
      --   'show_and_insert',
      --   'select_next',
      -- },
      -- ['<CR>'] = {
      --   function(cmp)
      --     if cmp.is_ghost_text_visible() and not cmp.is_menu_visible() then return cmp.accept() end
      --   end,
      --   'accept_and_enter',
      --   'fallback',
      -- },
      ['<Left>'] = {},
      ['<Right>'] = {},
    },
    fuzzy = { implementation = 'prefer_rust' },
    completion = {
      trigger = {
        show_on_backspace_in_keyword = true,
        show_on_insert = true,
      },
      ghost_text = {
        enabled = true,
        show_with_menu = true,
      },
      list = { selection = { preselect = false, auto_insert = true } },
      menu = {
        auto_show = true,
        -- NOTE: Fix autopairs fastwrap overlapping menu
        -- auto_show = function(_, _) return not has_fastwrap_extmarks() end,
        winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        draw = {
          treesitter = { 'lsp' },
          components = {
            kind_icon = {
              text = function(ctx) return get_kind_icon(ctx).text end,
              highlight = function(ctx) return get_kind_icon(ctx).highlight end,
            },
            label = {
              text = function(ctx) return require('colorful-menu').blink_components_text(ctx) end,
              highlight = function(ctx) return require('colorful-menu').blink_components_highlight(ctx) end,
            },
            source_name = {
              width = { max = 100 },
              text = function(ctx) return '(' .. ctx.source_name .. ')' end,
              highlight = 'BlinkCmpSource',
            },
          },
          columns = {
            { 'kind_icon' },
            { 'label', gap = 1 },
            { 'source_name' },
          },
        },
        direction_priority = function()
          local ctx = require('blink.cmp').get_context()
          local item = require('blink.cmp').get_selected_item()
          if ctx == nil or item == nil then return { 's', 'n' } end

          local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
          local is_multi_line = item_text:find '\n' ~= nil

          -- after showing the menu upwards, we want to maintain that direction
          -- until we re-open the menu, so store the context id in a global variable
          if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
            vim.g.blink_cmp_upwards_ctx_id = ctx.id
            return { 'n', 's' }
          end
          return { 's', 'n' }
        end,
      },
      accept = {
        auto_brackets = { enabled = true },
      },
      documentation = {
        draw = function(opts)
          if opts.item and opts.item.documentation and opts.item.documentation.value then
            local out = require('pretty_hover.parser').parse(opts.item.documentation.value)
            opts.item.documentation.value = out:string()
          end

          opts.default_implementation(opts)
        end,
        auto_show = true,
        auto_show_delay_ms = 0,
        window = {
          winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        },
      },
    },
    cmdline = {
      -- NOTE: use mini.cmdline instead
      enabled = false,
      keymap = {
        ['<End>'] = { 'hide', 'fallback' },
      },
      completion = {
        ghost_text = { enabled = false },
        menu = {
          auto_show = true,
          draw = {
            columns = {
              { 'kind_icon' },
              { 'label', gap = 1 },
            },
          },
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
      },
    },
    -- NOTE: Use default nvim stead
    signature = {
      enabled = false,
      window = {
        winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder',
      },
    },
  }
end)

later(function()
  add { 'https://github.com/HakonHarnes/img-clip.nvim' }
  require('img-clip').setup {
    default = {
      prompt_for_file_name = false,
      drag_and_drop = {
        insert_mode = true,
      },
      use_absolute_path = vim.fn.has 'win32' == 1, -- default to absolute path for windows users
    },
    filetypes = {
      codecompanion = {
        prompt_for_file_name = false,
        template = '[Image]($FILE_PATH)',
        use_absolute_path = true,
      },
    },
  }
  vim.keymap.set('n', '<Leader>P', '<CMD>PasteImage<CR>', { desc = 'Paste image' })
end)
