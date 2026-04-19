-- TODO: DAP, NEOTEST
-- A lots of codes borrow from astronvim. Auto config and enable lsp servers

local add = vim.pack.add
---@diagnostic disable-next-line: unused-local
local now, now_if_args, later, on_event, on_filetype =
  Config.now, Config.now_if_args, Config.later, Config.on_event, Config.on_filetype

local ensure_installed_treesitter = {
  "bash",
  "c",
  "c_sharp",
  "css",
  "dap_repl",
  "diff",
  "fish",
  "git_config",
  "gitignore",
  "graphql",
  "html",
  "hyprlang",
  "java",
  "javascript",
  "json",
  "json5",
  "latex",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "rasi",
  "regex",
  "rust",
  "scss",
  "svelte",
  "tsx",
  "typescript",
  "typst",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
  "xml",
  "sql",
}

local ensure_installed_mason_packages = {
  -- install language servers
  "ast-grep",
  "fish-lsp",
  "gh-actions-language-server",
  "lua-language-server",
  "marksman",
  "msbuild_project_tools_server",
  "roslyn",
  "sqls",
  "taplo",
  "tree-sitter-cli",
  "vtsls",
  "yaml-language-server",
  -- AI asisstent
  -- "copilot-language-server",

  -- install formatters
  "black",
  "isort",
  "markdown-toc",
  "prettierd",
  "rust-analyzer",
  "shfmt",
  "stylua",
  "csharpier",

  -- linters
  "dotenv-linter",
  "shellcheck",

  -- install debuggers
  "debugpy",
  "firefox-debug-adapter",
  "local-lua-debugger-vscode",
  "netcoredbg",

  -- other
  "gh",
}

-- File operations ============================================================
now_if_args(function()
  add { "https://github.com/antosha417/nvim-lsp-file-operations" }
  require("lsp-file-operations").setup {}
  vim.lsp.config("*", {
    capabilities = require("lsp-file-operations").default_capabilities(),
  })
  local ok_mini_files, _ = pcall(require, "mini.files")
  local log = require "lsp-file-operations.log"
  if ok_mini_files then
    log.debug "Setting up mini.files integration"

    Config.new_autocmd(
      "User",
      "MiniFilesActionCreate",
      function(args) require("lsp-file-operations.did-create").callback { fname = args.data.to } end,
      "execute `didCreateFiles` operation when creating files"
    )

    Config.new_autocmd(
      "User",
      "MiniFilesActionDelete",
      function(args) require("lsp-file-operations.did-delete").callback { fname = args.data.from } end,
      "execute `didDeleteFiles` operation when creating files"
    )

    Config.new_autocmd(
      "User",
      "MiniFilesActionRename",
      function(args)
        require("lsp-file-operations.did-rename").callback { old_name = args.data.from, new_name = args.data.to }
      end,
      "execute `didRenameFiles` operation when creating files"
    )
  end
end)

-- ╭─────────────────────────────────────────────────────────╮
-- │                        Which-key                        │
-- ╰─────────────────────────────────────────────────────────╯
later(function()
  add { "https://github.com/folke/which-key.nvim" }

  local config = {
    preset = "classic",
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
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    icons = {
      group = "",
      rules = false,
      separator = "-",
    },
  }

  if not vim.g.icons_enabled then
    config.icons.breadcrumb = ">"
    config.icons.group = "+"
    config.icons.keys = {
      Up = "Up",
      Down = "Down",
      Left = "Left",
      Right = "Right",
      C = "Ctrl+",
      M = "Alt+",
      D = "Cmd+",
      S = "Shift+",
      CR = "Enter",
      Esc = "Esc",
      ScrollWheelDown = "ScrollDown",
      ScrollWheelUp = "ScrollUp",
      NL = "Enter",
      BS = "Backspace",
      Space = "Space",
      Tab = "Tab",
      F1 = "F1",
      F2 = "F2",
      F3 = "F3",
      F4 = "F4",
      F5 = "F5",
      F6 = "F6",
      F7 = "F7",
      F8 = "F8",
      F9 = "F9",
      F10 = "F10",
      F11 = "F11",
      F12 = "F12",
    }
  end

  local wk = require "which-key"
  _G.wk = wk
  wk.add(Config.leader_group_which_key)
  wk.setup(config)
end)
-- Language servers ===========================================================

-- Language Server Protocol (LSP)  a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself  a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter')  shown after startup.
now_if_args(function()
  add { "https://github.com/neovim/nvim-lspconfig" }
  -- Enable via mason below
end)

now_if_args(function()
  Config.on_packchanged("mason.nvim", { "update" }, function() vim.cmd "MasonUpdate" end, ":MasonUpdate")
  add {
    "https://github.com/mason-org/mason.nvim",
  }
  require("mason").setup {
    registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
      "github:boydaihungst/mason-registry",
    },
    ui = {
      icons = vim.g.icons_enabled == false and {
        package_installed = "O",
        package_uninstalled = "X",
        package_pending = "0",
      } or {
        package_installed = "✓",
        package_uninstalled = "✗",
        package_pending = "⟳",
      },
    },
  }
end)

now_if_args(function()
  add {
    "https://github.com/WhoSethDaniel/mason-tool-installer.nvim",
  }
  local mason_tool_installer = require "mason-tool-installer"
  mason_tool_installer.setup {
    ensure_installed = ensure_installed_mason_packages,
    -- disable alternative name from these package, only use name from Mason.Nvim
    integrations = { ["mason-lspconfig"] = false, ["mason-null-ls"] = false, ["mason-nvim-dap"] = false },
  }
  -- Install at the startup
  mason_tool_installer.run_on_start()
end)

now_if_args(function()
  add {
    -- dependencies
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "1.x" },
    "https://github.com/mason-org/mason-lspconfig.nvim",
  }
  vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
  })

  local _ = require "mason-core.functional"
  local registry = require "mason-registry"
  local mappings = require "mason-lspconfig.mappings"

  local enabled_servers = {}
  if not mason_lsp_setup then
    _G.mason_lsp_setup = vim.schedule_wrap(function(mason_pkg)
      if type(mason_pkg) ~= "string" then mason_pkg = mason_pkg.name end
      local lspconfig_name = mappings.get_mason_map().package_to_lspconfig[mason_pkg]
      if not lspconfig_name or enabled_servers[lspconfig_name] then return end

      local ok, config = pcall(require, "mason-lspconfig.lsp." .. lspconfig_name)
      if ok then vim.lsp.config(lspconfig_name, config) end

      vim.lsp.enable(lspconfig_name)
      enabled_servers[lspconfig_name] = true
    end)
  end

  _.each(mason_lsp_setup, registry.get_installed_package_names())
  registry.refresh(vim.schedule_wrap(function(success, updated_registries)
    if success and #updated_registries > 0 then _.each(mason_lsp_setup, registry.get_installed_package_names()) end
  end))
  registry:off("package:install:success", mason_lsp_setup)
  registry:on("package:install:success", mason_lsp_setup)

  require("mason-lspconfig").setup {
    automatic_enable = true,
    ensure_installed = nil, -- because we use mason-tool-installer to install lsp severs
  }
end)

now(function()
  Config.on_packchanged(
    "lua-json5",
    { "install", "update" },
    function(data)
      vim
        .system(vim.fn.has "win32" == 1 and { "powershell", "./install.ps1" } or { "./install.sh" }, { cwd = data.path })
        :wait()
    end,
    "Install json5"
  )
  add {
    "https://github.com/Joakker/lua-json5",
  }
end)

later(function()
  add {
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/jay-babu/mason-nvim-dap.nvim",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/theHamsta/nvim-dap-virtual-text",
    "https://github.com/rcarriga/nvim-dap-ui",
    "https://github.com/Weissle/persistent-breakpoints.nvim",
    "https://github.com/Joakker/lua-json5",
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "1.x" },
  }

  local dap = require "dap"
  local dapui = require "dapui"
  local dap_persist_bp = require "persistent-breakpoints"
  require("mason-nvim-dap").setup {
    automatic_installation = true,
    handlers = {
      firefox = function(source_name)
        local dap = require "dap"
        dap.configurations.firefox = {
          {
            name = "Firefox: Debug",
            type = "firefox",
            request = "launch",
            reAttach = true,
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            firefoxExecutable = vim.fn.exepath "zen-browser",
          },
        }
      end,
    },
    -- NOTE: Use mason-installer-tools
    ensure_installed = nil,
  }
  require("nvim-dap-virtual-text").setup {
    virt_text_pos = "eol",
    virt_text_win_col = 70,
    commented = false,
    all_references = true,
  }

  dap_persist_bp.setup {
    load_breakpoints_event = { "BufReadPost" },
  }
  -- Dap UI setup
  -- For more information, see |:help nvim-dap-ui|
  ---@diagnostic disable-next-line: missing-fields
  dapui.setup {
    -- Set icons to characters that are more likely to work in every terminal.
    --    Feel free to remove or use ones that you like more! :)
    --    Don't feel like these are good choices.
    icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
    ---@diagnostic disable-next-line: missing-fields
    controls = {
      icons = {
        pause = "⏸",
        play = "▶",
        step_into = "⏎",
        step_over = "⏭",
        step_out = "⏮",
        step_back = "b",
        run_last = "▶▶",
        terminate = "⏹",
        disconnect = "⏏",
      },
    },
  }

  dap.listeners.after.event_initialized["dapui_config"] = dapui.open
  dap.listeners.before.event_terminated["dapui_config"] = dapui.close
  dap.listeners.before.event_exited["dapui_config"] = dapui.close

  -- Add source to blink.cmp
  local blink_avail, blink = pcall(require, "blink.cmp")
  if blink_avail then
    for _, dap_ft in ipairs { "dap-repl", "dapui_watches", "dapui_hover" } do
      blink.add_filetype_source(dap_ft, "dap")
    end
    blink.add_source_provider("dap", {
      name = "dap",
      module = "blink.compat.source",
      score_offset = 100,
    })
  end

  -- Use json5 to parse vscode json
  require("dap.ext.vscode").json_decode = require("json5").parse

  -- Function Key Mappings
  vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "Debugger: Start" })
  vim.keymap.set("n", "<F17>", function() dap.terminate() end, { desc = "Debugger: Stop (Shift+F5)" })
  vim.keymap.set(
    "n",
    "<F21>",
    function() dap_persist_bp.set_conditional_breakpoint() end,
    { desc = "Debugger: Conditional Breakpoint (Shift+F9)" }
  )
  vim.keymap.set("n", "<F29>", function() dap.restart_frame() end, { desc = "Debugger: Restart (Ctrl+F5)" })
  vim.keymap.set("n", "<F6>", function() dap.pause() end, { desc = "Debugger: Pause" })
  vim.keymap.set(
    "n",
    "<F9>",
    function() dap_persist_bp.toggle_breakpoint() end,
    { desc = "Debugger: Toggle Breakpoint" }
  )
  vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "Debugger: Step Over" })
  vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "Debugger: Step Into" })
  vim.keymap.set("n", "<F23>", function() dap.step_out() end, { desc = "Debugger: Step Out (Shift+F11)" })

  -- Leader Mappings
  vim.keymap.set(
    "n",
    "<Leader>db",
    function() dap_persist_bp.toggle_breakpoint() end,
    { desc = "Toggle Breakpoint (F9)" }
  )
  vim.keymap.set(
    "n",
    "<Leader>dB",
    function() dap_persist_bp.clear_all_breakpoints() end,
    { desc = "Clear Breakpoints" }
  )
  vim.keymap.set("n", "<Leader>dc", function() dap.continue() end, { desc = "Start/Continue (F5)" })
  vim.keymap.set(
    "n",
    "<Leader>dC",
    function() dap_persist_bp.set_conditional_breakpoint() end,
    { desc = "Conditional Breakpoint (S-F9)" }
  )
  vim.keymap.set("n", "<Leader>di", function() dap.step_into() end, { desc = "Step Into (F11)" })
  vim.keymap.set("n", "<Leader>do", function() dap.step_over() end, { desc = "Step Over (F10)" })
  vim.keymap.set("n", "<Leader>dO", function() dap.step_out() end, { desc = "Step Out (S-F11)" })
  vim.keymap.set("n", "<Leader>dq", function() dap.close() end, { desc = "Close Session" })
  vim.keymap.set("n", "<Leader>dQ", function() dap.terminate() end, { desc = "Terminate Session (S-F5)" })
  vim.keymap.set("n", "<Leader>dp", function() dap.pause() end, { desc = "Pause (F6)" })
  vim.keymap.set("n", "<Leader>dr", function() dap.restart_frame() end, { desc = "Restart (C-F5)" })
  vim.keymap.set("n", "<Leader>dR", function() dap.repl.toggle() end, { desc = "Toggle REPL" })
  vim.keymap.set("n", "<Leader>ds", function() dap.run_to_cursor() end, { desc = "Run To Cursor" })

  -- dap ui
  vim.keymap.set("n", "<Leader>dE", function()
    vim.ui.input({ prompt = "Expression: " }, function(expr)
      if expr then require("dapui").eval(expr, { enter = true }) end
    end)
  end, { desc = "Evaluate Input" })
  vim.keymap.set("v", "<Leader>dE", function() require("dapui").eval() end, { desc = "Evaluate Input" })
  vim.keymap.set("n", "<Leader>du", function() dapui.toggle() end, { desc = "Toggle Debugger UI" })
  vim.keymap.set("n", "<Leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "Debugger Hover" })

  vim.fn.sign_define("DapBreakpoint", {
    text = Config.get_custom_icon "DapBreakpoint",
    texthl = "DiagnosticInfo",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextInfo",
  })
  vim.fn.sign_define("DapBreakpointCondition", {
    text = Config.get_custom_icon "DapBreakpointCondition",
    texthl = "DiagnosticInfo",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextInfo",
  })
  vim.fn.sign_define("DapBreakpointRejected", {
    text = Config.get_custom_icon "DapBreakpointRejected",
    texthl = "DiagnosticError",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextError",
  })
  vim.fn.sign_define("DapLogPoint", {
    text = Config.get_custom_icon "DapLogPoint",
    texthl = "DiagnosticInfo",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextInfo",
  })
  vim.fn.sign_define("DapStopped", {
    text = Config.get_custom_icon "DapStopped",
    texthl = "DiagnosticWarn",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextWarn",
  })
end)
-- Tree-sitter ================================================================
now_if_args(function()
  -- Define hook to update tree-sitter parsers after plugin  updated
  Config.on_packchanged("nvim-treesitter", { "update" }, function() vim.cmd "TSUpdate" end, ":TSUpdate")

  add {
    "https://github.com/LiadOz/nvim-dap-repl-highlights",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
    "https://github.com/RRethy/nvim-treesitter-endwise",
    "https://github.com/andersevenrud/nvim_context_vt", -- Shows virtual text of the current context after functions, methods, statements, etc.
  }
  require("nvim-dap-repl-highlights").setup()
  require("nvim-treesitter").install(ensure_installed_treesitter)
  local available_parsers = require("nvim-treesitter").get_available()

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- check if parser exists and load it
    if not vim.treesitter.language.add(language) then return end
    -- enables syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)
    -- enables treesitter based indentation
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end

  vim.treesitter.language.register("bash", "kitty")
  vim.treesitter.language.register("xml", { "msbuild" })

  Config.new_autocmd("FileType", "*", function(args)
    local buf, filetype = args.buf, args.match
    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    if Config.is_large(buf) then
      vim.treesitter.stop(args.buf)
      return
    end

    local installed_parsers = require("nvim-treesitter").get_installed "parsers"

    if vim.tbl_contains(installed_parsers, language) then
      -- enable the parser if it is installed
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
      require("nvim-treesitter").install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
      treesitter_try_attach(buf, language)
    end
  end, "Tree-sitter auto install and start parser")

  require("nvim_context_vt").setup {
    prefix = Config.get_custom_icon "ArrowRight",
  }

  -- enable treesitter extra plugins
  require("treesitter-context").setup {
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    multiwindow = false, -- Enable multiwindow support.
    max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 5, -- Maximum number of lines to show for a single context
    trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator  set, the context will only show up when there are at least 2 lines above cursorline.
    separator = "─",
    zindex = 20, -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
  }
  --TODO: Add more text objects here
  require("nvim-treesitter-textobjects").setup {
    select = { lookahead = true },
  }

  vim.keymap.set("n", "\\T", "<Cmd>TSContext toggle<CR>", { desc = "Toggle treesitter context" })

  local ts_select = require "nvim-treesitter-textobjects.select"

  local select_maps = {
    ["ak"] = { "@block.outer", "around block" },
    ["ik"] = { "@block.inner", "inside block" },
    ["ac"] = { "@class.outer", "around class" },
    ["ic"] = { "@class.inner", "inside class" },
    ["a?"] = { "@conditional.outer", "around conditional" },
    ["i?"] = { "@conditional.inner", "inside conditional" },
    ["af"] = { "@function.outer", "around function" },
    ["if"] = { "@function.inner", "inside function" },
    ["ao"] = { "@loop.outer", "around loop" },
    ["io"] = { "@loop.inner", "inside loop" },
    ["aa"] = { "@parameter.outer", "around argument" },
    ["ia"] = { "@parameter.inner", "inside argument" },
  }

  for key, val in pairs(select_maps) do
    vim.keymap.set(
      { "x", "o" },
      key,
      function() ts_select.select_textobject(val[1], "textobjects") end,
      { desc = val[2] }
    )
  end
  local ts_move = require "nvim-treesitter-textobjects.move"

  local move_maps = {
    -- Next Start
    ["]k"] = { ts_move.goto_next_start, "@block.outer", "Next block start" },
    ["]f"] = { ts_move.goto_next_start, "@function.outer", "Next function start" },
    ["]a"] = { ts_move.goto_next_start, "@parameter.inner", "Next argument start" },
    -- Next End
    ["]K"] = { ts_move.goto_next_end, "@block.outer", "Next block end" },
    ["]F"] = { ts_move.goto_next_end, "@function.outer", "Next function end" },
    ["]A"] = { ts_move.goto_next_end, "@parameter.inner", "Next argument end" },
    -- Previous Start
    ["[k"] = { ts_move.goto_previous_start, "@block.outer", "Previous block start" },
    ["[f"] = { ts_move.goto_previous_start, "@function.outer", "Previous function start" },
    ["[a"] = { ts_move.goto_previous_start, "@parameter.inner", "Previous argument start" },
    -- Previous End
    ["[K"] = { ts_move.goto_previous_end, "@block.outer", "Previous block end" },
    ["[F"] = { ts_move.goto_previous_end, "@function.outer", "Previous function end" },
    ["[A"] = { ts_move.goto_previous_end, "@parameter.inner", "Previous argument end" },
  }

  for key, val in pairs(move_maps) do
    vim.keymap.set({ "n", "x", "o" }, key, function() val[1](val[2], "textobjects") end, { desc = val[3] })
  end
  local ts_swap = require "nvim-treesitter-textobjects.swap"

  local swap_maps = {
    -- Swap Next
    [">K"] = { ts_swap.swap_next, "@block.outer", "Swap next block" },
    [">F"] = { ts_swap.swap_next, "@function.outer", "Swap next function" },
    [">A"] = { ts_swap.swap_next, "@parameter.inner", "Swap next argument" },
    -- Swap Previous
    ["<K"] = { ts_swap.swap_previous, "@block.outer", "Swap previous block" },
    ["<F"] = { ts_swap.swap_previous, "@function.outer", "Swap previous function" },
    ["<A"] = { ts_swap.swap_previous, "@parameter.inner", "Swap previous argument" },
  }

  for key, val in pairs(swap_maps) do
    vim.keymap.set("n", key, function() val[1](val[2]) end, { desc = val[3] })
  end
end)

-- Formatting =================================================================

later(function()
  add { "https://github.com/stevearc/conform.nvim" }
  require("conform").setup {
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter  available
      lsp_format = "fallback",
    },
    format_on_save = function(bufnr)
      if vim.F.if_nil(vim.b[bufnr].autoformat, vim.g.autoformat, true) then return { lsp_format = "fallback" } end
    end,
    formatters_by_ft = {
      toml = { "taplo" },
      markdown = { "markdown-toc", "prettierd", stop_after_first = false },
      sh = { "shfmt" },
      cs = { "csharpier" },
    },
    formatters = {
      -- nginxfmt = {
      --   -- Change where to find the command
      --   command = os.getenv "HOME" .. "/.venv/bin/nginxfmt",
      -- },
      taplo = {
        -- prepend_args = { "-o", "" },
        env = {
          TAPLO_CONFIG = os.getenv "HOME" .. "/.config/.taplo.toml",
        },
      },
      ["clang-format"] = {},
      stylua = {
        prepend_args = { "--syntax", "LuaJIT" },
      },
    },
    -- Set the log level. Use `:ConformInfo` to see the location of the log file.
    log_level = vim.log.levels.OFF,
    -- Conform will notify you when a formatter errors
    notify_on_error = true,
    -- Conform will notify you when no formatters are available for the buffer
    notify_no_formatters = true,
  }

  vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = {
        start = { args.line1, 0 },
        ["end"] = { args.line2, end_line:len() },
      }
    end
    require("conform").format { async = true, range = range }
  end, { desc = "Format buffer", range = true })

  vim.keymap.set("n", "<Leader>lC", "<Cmd>ConformInfo<CR>", { desc = "Formatter information" })
  vim.keymap.set("n", "<Leader>lf", "<Cmd>Format<CR>", { desc = "Format" })
end)

-- Snippets ===================================================================
later(function() add { "https://github.com/rafamadriz/friendly-snippets" } end)

on_filetype("lua", function()
  add {
    "https://github.com/folke/lazydev.nvim",
    -- 'https://github.com/DrKJeff16/wezterm-types',
  }
  require("lazydev").setup {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = os.getenv "HOME" .. "/.config/yazi/plugins/types.yazi", words = { "ya%.", "ui%." } },
      -- { path = "wezterm-types", mods = { "wezterm" } },
    },
  }
  local blink_avail, blink = pcall(require, "blink.cmp")
  if blink_avail then
    blink.add_filetype_source("lua", "lazydev")
    blink.add_source_provider("lazydev", {
      name = "LazyDev",
      module = "lazydev.integrations.blink",
      score_offset = 100,
    })
  end
end)

-- Search and Replace with gui
later(function()
  add { "https://github.com/MagicDuck/grug-far.nvim" }
  require("grug-far").setup {
    transient = true,
  }
  local default_opts = { instanceName = "main" }
  local function grug_far_open(opts, with_visual)
    local grug_far = require "grug-far"
    opts = vim.tbl_extend("force", default_opts, opts or {})
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
    Config.new_autocmd("User", "MiniFilesBufferCreate", function(args)
      vim.keymap.set(
        "n",
        "?",
        function() grug_far_open { prefills = { paths = vim.fs.dirname(require("mini.files").get_fs_entry().path) } } end,
        { buffer = args.data.buf_id, desc = "Search/Replace in directory" }
      )
    end, "Create mapping `mini.files` for searching in directory")
  end
  local key_prefix = "<Leader>s"
  if wk then
    wk.add { { key_prefix, group = Config.get_custom_icon("GrugFar", 1, true) .. "Search/Replace", mode = { "n", "x" } } }
  end
  -- Workspace Search
  vim.keymap.set("n", key_prefix .. "s", function() grug_far_open() end, { desc = "Search/Replace workspace" })

  -- Filetype Search
  vim.keymap.set("n", key_prefix .. "e", function()
    local ext = vim.api.nvim_buf_is_valid(0) and vim.bo.buflisted and vim.fn.expand "%:e" or ""
    grug_far_open {
      prefills = { filesFilter = ext ~= "" and "*." .. ext or nil },
    }
  end, { desc = "Search/Replace filetype" })

  -- Current File Search
  vim.keymap.set("n", key_prefix .. "f", function()
    local filter = vim.api.nvim_buf_is_valid(0) and vim.bo.buflisted and vim.fn.fnameescape(vim.fn.expand "%") or nil
    grug_far_open { prefills = { paths = filter } }
  end, { desc = "Search/Replace file" })

  -- Word under cursor (Normal mode)
  vim.keymap.set("n", key_prefix .. "w", function()
    local current_word = vim.fn.expand "<cword>"
    if current_word ~= "" then
      grug_far_open {
        startCursorRow = 4,
        prefills = { search = current_word },
      }
    else
      vim.notify("No word under cursor", vim.log.levels.WARN, { title = "Grug-far" })
    end
  end, { desc = "Search/Replace word" })

  -- Selection Search (visual mode)
  vim.keymap.set("x", key_prefix .. "w", function() grug_far_open(nil, true) end, { desc = "Replace selection" })
end)
later(function()
  add { "https://github.com/LudoPinelli/comment-box.nvim" }
  require("comment-box").setup {
    comment_style = "auto",
    outer_blank_lines_above = true, -- insert a blank line above the box
    outer_blank_lines_below = true, -- insert a blank line below the box
    inner_blank_lines = true, -- insert a blank line above and below the text
    line_blank_line_above = true, -- insert a blank line above the line
    line_blank_line_below = true, -- insert a blank line below the line
  }
  local key_prefix = "<Leader>B"
  local modes = { "n", "x" }
  if wk then
    wk.add {
      { key_prefix, group = Config.get_custom_icon("CommentBox", 1, true) .. "Comment Box/Line", mode = modes },
      { key_prefix .. "b", group = "Comment Box", mode = modes },
      { key_prefix .. "l", group = "Comment Line", mode = modes },
    }
  end
  vim.keymap.set(modes, key_prefix .. "bl", "<Cmd>CBllbox<Cr>", { desc = "Comment Box Left" })
  vim.keymap.set(modes, key_prefix .. "bc", "<Cmd>CBlcbox<Cr>", { desc = "Comment Box Center" })
  vim.keymap.set(modes, key_prefix .. "br", "<Cmd>CBlrbox<Cr>", { desc = "Comment Box Right" })

  vim.keymap.set(modes, key_prefix .. "ll", "<Cmd>CBllline<Cr>", { desc = "Comment Line Left" })
  vim.keymap.set(modes, key_prefix .. "lc", "<Cmd>CBlcline<Cr>", { desc = "Comment Line Center" })
  vim.keymap.set(modes, key_prefix .. "lr", "<Cmd>CBlrline<Cr>", { desc = "Comment Line Right" })
end)

now(function()
  add { "https://github.com/j-hui/fidget.nvim" }
  require("fidget").setup {
    -- Options related to LSP progress subsystem
    progress = {
      ignore = {}, -- List of LSP servers to ignore

      -- Options related to how LSP progress messages are displayed as notifications
      display = {
        render_limit = 5, -- How many LSP messages to show at once
        done_ttl = 1, -- How long a message should perst after completion
        done_icon = "✔", -- Icon shown when all LSP progress tasks are complete
        done_style = "Constant", -- Highlight group for completed LSP tasks
        -- Icon shown when LSP progress tasks are in progress
        progress_icon = { "dots" },
        -- Highlight group for in-progress LSP tasks
        progress_style = "WarningMsg",
        group_style = "Title", -- Highlight group for group name (LSP server name)
        icon_style = "Question", -- Highlight group for group icons
        overrides = { -- Override options from the default notification config
          rust_analyzer = { name = "rust-analyzer" },
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

on_event("BufEnter", function()
  add { "https://github.com/stevearc/aerial.nvim" }
  require("aerial").setup {
    attach_mode = "global",
    backends = { "lsp", "treesitter", "markdown", "man" },
    layout = { min_width = 28 },
    filter_kind = false,
    guides = {
      mid_item = "├ ",
      last_item = "└ ",
      nested_top = "│ ",
      whitespace = "  ",
    },
    keymaps = {
      ["[y"] = "actions.prev",
      ["]y"] = "actions.next",
      ["[Y"] = "actions.prev_up",
      ["]Y"] = "actions.next_up",
      ["{"] = false,
      ["}"] = false,
      ["[["] = false,
      ["]]"] = false,
    },
    on_attach = function(bufnr)
      local aerial = require "aerial"
      vim.keymap.set("n", "]y", function() aerial.next(vim.v.count1) end, { buffer = bufnr, desc = "Next symbol" })
      vim.keymap.set("n", "[y", function() aerial.prev(vim.v.count1) end, { buffer = bufnr, desc = "Previous symbol" })
      vim.keymap.set(
        "n",
        "]Y",
        function() aerial.next_up(vim.v.count1) end,
        { buffer = bufnr, desc = "Next symbol upwards" }
      )
      vim.keymap.set(
        "n",
        "[Y",
        function() aerial.prev_up(vim.v.count1) end,
        { buffer = bufnr, desc = "Previous symbol upwards" }
      )
    end,
    close_automatic_events = { "unfocus", "unsupported" },
    highlight_on_hover = true,
    autojump = true,
    open_automatic = false,
    manage_folds = false,
    link_folds_to_tree = true,
    link_tree_to_folds = true,
    show_guides = true,
    disable_max_lines = Config.default_large_buf_opts.lines,
    -- disable aerial on files this size or larger (in bytes)
    disable_max_size = Config.default_large_buf_opts.size,
  }
end)
later(function()
  add { "https://github.com/otavioschwanck/arrow.nvim" }
  require("arrow").setup {
    show_icons = vim.g.icons_enabled,
    leader_key = "M", -- Recommended to be a single key
    buffer_leader_key = "m", -- Per Buffer Mappings
    always_show_path = false,
    separate_by_branch = true, -- Bookmarks will be separated by git branch
    hide_handbook = false, -- set to true to hide the shortcuts on menu.
    separate_save_and_remove = true, -- if true, will remove the toggle and create the save/remove keymaps.
    save_key = "cwd", -- what will be used as root to save the bookmarks. Can be also `git_root` and `git_root_bare`.
    global_bookmarks = false, -- if true, arrow will save files globally (ignores separate_by_branch)
    index_keys = "123456789zxcbnmZXVBNM,afghjklAFGHJKLwrtyuiopWRTYUIOP", -- keys mapped to bookmark index, i.e. 1st bookmark will be accessible by 1, and 12th - by c
    mappings = {
      edit = "e",
      delete_mode = "d",
      clear_all_items = "C",
      toggle = "s", -- used as save if separate_save_and_remove  true
      open_vertical = "v",
      open_horizontal = "-",
      quit = "q",
      remove = "x", -- only used if separate_save_and_remove  true
      next_item = "]",
      prev_item = "[",
    },
    window = { -- controls the appearance and position of an arrow window (see nvim_open_win() for all options)
      width = "auto",
      height = "auto",
      row = "auto",
      col = "auto",
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
      -- }, -- it can be { line_shift_down = 2 }, currently not usable, for detail see https://github.com/otavioschwanck/arrow.nvim/pull/43#sue-2236320268
    },
  }
end)
later(function()
  add { "https://github.com/monaqa/dial.nvim" }

  local augend = require "dial.augend"

  local logical_alias = augend.constant.new {
    elements = { "&&", "||" },
    word = true,
    cyclic = true,
  }

  local and_or = augend.constant.new {
    elements = {
      "and",
      "or",
    },
    word = true,
    cyclic = true,
  }

  local ordinal_numbers = augend.constant.new {
    -- elements through which we cycle. When we increment, we go down
    -- On decrement we go up
    elements = {
      "first",
      "second",
      "third",
      "fourth",
      "fifth",
      "sixth",
      "seventh",
      "eighth",
      "ninth",
      "tenth",
    },
    -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
    word = false,
    -- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
    -- otherwise nothing will happen when there are no further values
    cyclic = true,
    match_before_cursor = true,
  }

  local weekdays = augend.constant.new {
    elements = {
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    },
    word = true,
    cyclic = true,
    match_before_cursor = true,
  }

  local months = augend.constant.new {
    elements = {
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    },
    word = true,
    cyclic = true,
    match_before_cursor = true,
  }

  local capitalized_boolean = augend.constant.new {
    elements = {
      "True",
      "False",
    },
    word = true,
    cyclic = true,
  }

  local import_export = augend.constant.new {
    elements = {
      "import",
      "export",
    },
    word = true,
    cyclic = true,
    match_before_cursor = true,
  }
  local yes_no = augend.constant.new {
    elements = {
      "yes",
      "no",
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
      augend.date.alias["%Y/%m/%d"], -- date (2022/02/18, etc.)
      ordinal_numbers,
      weekdays,
      months,
      capitalized_boolean,
      augend.constant.alias.bool, -- boolean value (true <-> false)
      logical_alias,
      and_or,
      yes_no,
    },
    vue = {
      augend.constant.new { elements = { "let", "const" }, match_before_cursor = true, word = true, cyclic = true },
      import_export,
      augend.hexcolor.new { case = "lower", match_before_cursor = true },
      augend.hexcolor.new { case = "upper", match_before_cursor = true },
      augend.constant.new {
        elements = {
          "|",
          "&",
        },
        word = true,
        cyclic = true,
      },
      augend.constant.new {
        elements = {
          "!=",
          "==",
        },
        word = true,
        cyclic = true,
      },
    },
    typescript = {
      augend.constant.new { elements = { "let", "const" }, match_before_cursor = true, word = true, cyclic = true },
      import_export,
    },
    css = {
      augend.hexcolor.new {
        case = "lower",
        match_before_cursor = true,
      },
      augend.hexcolor.new {
        case = "upper",
        match_before_cursor = true,
      },
    },
    markdown = {
      augend.constant.new {
        elements = { "[ ]", "[x]" },
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
        elements = { "~=", "==" },
        word = true,
        cyclic = true,
      },
      augend.constant.new {
        elements = {
          "if",
          "else",
          "elseif",
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
          "if",
          "else",
          "elif",
        },
        word = true,
        cyclic = true,
        match_before_cursor = true,
      },
    },
  }

  local dial_config = require "dial.config"
  -- copy defaults to each group
  for name, group in pairs(groups) do
    if name ~= "default" then vim.list_extend(group, groups.default) end
  end
  dial_config.augends:register_group(groups)
  dial_config.augends:on_filetype(groups)

  vim.keymap.set("n", "<C-a>", function() require("dial.map").manipulate("increment", "normal") end)
  vim.keymap.set("n", "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end)
  vim.keymap.set("n", "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end)
  vim.keymap.set("n", "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end)
  vim.keymap.set("x", "<C-a>", function() require("dial.map").manipulate("increment", "visual") end)
  vim.keymap.set("x", "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end)
  vim.keymap.set("x", "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end)
  vim.keymap.set("x", "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end)
end)

later(function()
  add { "https://github.com/linrongbin16/gitlinker.nvim" }
  local function to_litteral(str) return str and str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") end
  require("gitlinker").setup {
    router = {
      browse = {
        -- My gitea server
        -- https://git.linuxholic.com/boydaihungst/AnimeSubtitles/src/commit/250145403bde3858562337528233b0707fdf6e86/typesetting_fonts.txt#L4-L10
        [to_litteral "ssh.linuxholic.com"] = "https://git.linuxholic.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/src/commit/"
          .. "{_A.REV}/"
          .. "{_A.FILE}"
          .. "#L{_A.LSTART}-L{_A.LEND}",
      },
      blame = {
        -- My gitea server
        -- https://git.linuxholic.com/boydaihungst/AnimeSubtitles/blame/commit/250145403bde3858562337528233b0707fdf6e86/typesetting_fonts.txt#L4-L10
        [to_litteral "ssh.linuxholic.com"] = "https://git.linuxholic.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/blame/commit/"
          .. "{_A.REV}/"
          .. "{_A.FILE}"
          .. "#L{_A.LSTART}-L{_A.LEND}",
      },
    },
  }
  local prefix = "<leader>g"

  vim.keymap.set({ "n", "x" }, prefix .. "y", "<cmd>GitLink<cr>", { desc = "Copy Git link" })
  vim.keymap.set({ "n", "x" }, prefix .. "z", "<cmd>GitLink!<cr>", { desc = "Open Git link" })
end)

later(function()
  add { "https://github.com/kevinhwang91/nvim-hlslens" }

  local hlslens = require "hlslens"
  hlslens.setup {
    -- NOTE: disable this because it makes mini.files incremental search error
    enable_incsearch = false,
    override_lens = function(render, posList, nearest, idx, _)
      local text, chunks

      local lnum, col = unpack(posList[idx])
      if nearest then
        local cnt = #posList
        text = ("[%d/%d]"):format(idx or 0, cnt or 0)
        chunks = { { " " }, { text, "HlSearchLensNear" } }
      else
        text = ("[%d]"):format(idx or 0)
        chunks = { { " " }, { text, "HlSearchLens" } }
      end
      render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
    end,
  }

  vim.api.nvim_set_hl(0, "HlSearchLens", { link = "CurSearch" })
  vim.api.nvim_set_hl(0, "HlSearchLensNear", { link = "Search" })

  local function n_with_hlslens(char)
    local count = vim.v.count1
    -- Executes the normal command (n, N, *, etc) then starts hlslens
    vim.cmd(("normal! %d%s"):format(count, char))
    hlslens.start()
  end

  -- n and N
  vim.keymap.set("n", "n", function() n_with_hlslens "n" end, { silent = true, desc = "Next search result" })
  vim.keymap.set("n", "N", function() n_with_hlslens "N" end, { silent = true, desc = "Prev search result" })

  -- * and # (Directly trigger the command then start hlslens)
  vim.keymap.set("n", "*", '*<Cmd>lua require("hlslens").start()<CR>', { silent = true, desc = "Search word forward" })
  vim.keymap.set("n", "#", '#<Cmd>lua require("hlslens").start()<CR>', { silent = true, desc = "Search word backward" })

  -- g* and g#
  vim.keymap.set(
    "n",
    "g*",
    'g*<Cmd>lua require("hlslens").start()<CR>',
    { silent = true, desc = "Search word forward (partial)" }
  )
  vim.keymap.set(
    "n",
    "g#",
    'g#<Cmd>lua require("hlslens").start()<CR>',
    { silent = true, desc = "Search word backward (partial)" }
  )
end)

on_filetype("vue,typescript,javascript,typescriptreact,javascriptreact,tsx,jsx,java,json,yaml", function()
  add { "https://github.com/yelog/i18n.nvim" }
  local original_sig_help = vim.lsp.buf.signature_help

  local i18n = require "i18n"
  i18n.setup {
    activation = "lazy",
    show_mode = "both",
    diagnostic = true,
    -- Locales to parse; first  the default locale
    -- Use I18nNextLocale command to switch the default locale in real time
    locales = { "en", "vn", "jp", "zh", "en_US", "vi_VN", "ja_JP", "zh_CN" },
    usage = {
      -- Popup provider used when choosing between multiple usage locations
      -- Available values: 'vim_ui', 'telescope', 'fzf-lua', 'snacks'
      popup_type = "vim_ui",
      notify_no_key = false,
      max_file_size = 0, -- 0 = no limit
      scan_on_startup = true,
    },
    func_pattern = { "t", "$t" },
    -- sources can be string or table { pattern = "...", prefix = "..." }
    -- Project-level configuration files
    -- .i18nrc.json
    -- i18n.config.json
    -- .i18nrc.lua
    sources = {
      "src/locales/{locales}.json",
      "src/lang/{locales}.json",
      -- { pattern = "src/locales/lang/{locales}/{module}.ts",            prefix = "{module}." },
      -- { pattern = "src/views/{bu}/locales/lang/{locales}/{module}.ts", prefix = "{bu}.{module}." },
    },
    i18n_keys = {
      popup_type = "vim_ui",
    },

    -- Enable namespace resolution
    -- false: disabled, no namespace resolution
    -- 'auto': Auto-detect framework based on filetype (tsx/jsx → react_i18next, vue → vue_i18n)
    -- 'react_i18next': Detect useTranslation('namespace') calls in React components
    -- 'vue_i18n': Detect useI18n({ namespace: '...' }) in Vue components
    namespace_resolver = "auto", -- or 'react_i18next', 'vue_i18n', custom function, or table
    -- Separator between namespace and key
    namespace_separator = ".", -- set ':' for i18next standard
  }
  vim.lsp.buf.signature_help = function(opts)
    if require("i18n.display").get_key_under_cursor() then
      require("i18n").show_popup()
    else
      opts = vim.tbl_extend("force", opts, {
        anchor_bias = "above",
      })
      return original_sig_help(opts)
    end
  end
  vim.g.changed_sign_helper = true

  Config.new_autocmd("DirChanged", "*", function()
    if vim.fn.exists ":I18nReload" == 2 and i18n._activated then vim.cmd "I18nReload" end
  end, "Reload i18n on cwd/workspace changed")
end)

later(function()
  local original_sig_help = vim.lsp.buf.signature_help
  if not vim.g.changed_sign_helper then
    vim.lsp.buf.signature_help = function(opts)
      opts = vim.tbl_extend("force", opts, {
        anchor_bias = "above",
      })
      return original_sig_help(opts)
    end
    vim.g.changed_sign_helper = true
  end
end)

on_event("LspAttach", function()
  add {
    "https://github.com/Fildo7525/pretty_hover",
  }
  require("pretty_hover").setup {}
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.buf.hover = function(opts)
    local _, i18n = pcall(require, "i18n")
    if not i18n or not i18n._activated then return require("pretty_hover").hover(opts) end
    if require("i18n.display").get_key_under_cursor() then
      require("i18n").show_popup()
      return
    end
    require("pretty_hover").hover()
  end
end)

on_event("InsertEnter,CmdlineEnter", function()
  add {
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/xzbdmw/colorful-menu.nvim",
    "https://github.com/Fildo7525/pretty_hover",
    -- sources
    "https://github.com/Kaer-Yang/blink-cmp-git",
    "https://github.com/drupted/blink-cmp-conventional-commits",
    "https://github.com/yelog/i18n.nvim",

    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "1.x" },
  }

  local function has_words_before()
    local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
  end

  -- Check if there  any autopair fastwrap extmarks
  local function has_fastwrap_extmarks(bufnr)
    bufnr = bufnr or 0 -- Default to current buffer
    local fastwarp_ext, fastwarp = pcall(require, "nvim-autopairs.fastwrap")
    if not fastwarp_ext then return false end
    local line_num = vim.api.nvim_win_get_cursor(0)[1] - 1
    local extmarks = vim.api.nvim_buf_get_extmarks(
      bufnr,
      fastwarp.ns_fast_wrap,
      { line_num, 0 },
      { line_num, -1 },
      { details = false, limit = 1 }
    )

    return #extmarks > 0
  end

  ---@type function?, function?
  local icon_provider, hl_provider

  local function get_kind_icon(CTX)
    -- Evaluate icon provider
    if not icon_provider then
      local _, mini_icons = pcall(require, "mini.icons")
      if _G.MiniIcons then
        icon_provider = function(ctx)
          local is_specific_color = ctx.kind_hl and ctx.kind_hl:match "^HexColor" ~= nil
          if ctx.item.source_name == "LSP" then
            local icon, hl = mini_icons.get("lsp", ctx.kind or "")
            if icon then
              ctx.kind_icon = icon
              if not is_specific_color then ctx.kind_hl = hl end
            end
          elseif ctx.item.source_name == "Path" then
            ctx.kind_icon, ctx.kind_hl = mini_icons.get(ctx.kind == "Folder" and "directory" or "file", ctx.label)
          elseif ctx.item.source_name == "Snippets" then
            ctx.kind_icon, ctx.kind_hl = mini_icons.get("lsp", "snippet")
          end
        end
      end
      if not icon_provider then
        local lspkind_avail, lspkind = pcall(require, "lspkind")
        if lspkind_avail then
          icon_provider = function(ctx)
            if ctx.item.source_name == "LSP" then
              local icon = lspkind.symbol_map[ctx.kind]
              if icon then ctx.kind_icon = icon end
            elseif ctx.item.source_name == "Snippets" then
              local icon = lspkind.symbol_map["Snippet"]
              if icon then ctx.kind_icon = icon end
            end
          end
        end
      end
      if not icon_provider then icon_provider = function() end end
    end
    -- Evaluate highlight provider
    if not hl_provider then
      local highlight_colors_avail, highlight_colors = pcall(require, "nvim-highlight-colors")
      if highlight_colors_avail then
        local kinds
        hl_provider = function(ctx)
          if not kinds then kinds = require("blink.cmp.types").CompletionItemKind end
          if ctx.item.kind == kinds.Color then
            local doc = vim.tbl_get(ctx, "item", "documentation")
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

  require("blink.cmp").setup {
    enabled = function()
      local dap_prompt = pcall(require, "cmp-dap") -- add interoperability with cmp-dap
        and vim.tbl_contains({ "dap-repl", "dapui_watches", "dapui_hover" }, vim.bo.filetype)
      if vim.bo.buftype == "prompt" and not dap_prompt then return false end
      return vim.b.completion ~= false
    end,
    snippets = { preset = "mini_snippets" },
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "i18n", "conventional_commits", "git" },
      providers = {
        git = {
          module = "blink-cmp-git",
          name = "Git",
          -- only enable th source when filetype is gitcommit, markdown, or 'octo'
          enabled = function() return vim.tbl_contains({ "octo", "gitcommit", "markdown" }, vim.bo.filetype) end,
          --- @module 'blink-cmp-git'
          --- @type blink-cmp-git.Options
          opts = {
            commit = {
              -- You may want to customize when it should be enabled
              -- The default will enable th when `git` is found and `cwd` is in a git repository
              -- enable = function() end
              -- You may want to change the triggers
              -- triggers = { ':' },
            },
            git_centers = {
              github = {
                -- Those below have the same fields with `commit`
                -- Those features will be enabled when `git` and `gh` (or `curl`) are found and
                -- remote contains `github.com`
                -- sue = {
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
                -- sue = {
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
          name = "Conventional Commits",
          module = "blink-cmp-conventional-commits",
          enabled = function() return vim.bo.filetype == "gitcommit" end,
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
          name = "i18n",
          module = "i18n.integration.blink_source",
        },
      },
    },
    fuzzy = { implementation = "prefer_rust" },
    completion = {
      trigger = {
        show_on_backspace_in_keyword = true,
        show_on_insert = true,
      },
      ghost_text = {
        enabled = false,
        show_with_menu = true,
      },
      list = { selection = { preselect = false, auto_insert = true } },
      menu = {
        -- NOTE: Fix autopairs fastwrap overlapping menu
        auto_show = function(_, _) return not has_fastwrap_extmarks() end,
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        draw = {
          treesitter = { "lsp" },
          components = {
            kind_icon = {
              text = function(ctx) return get_kind_icon(ctx).text end,
              highlight = function(ctx) return get_kind_icon(ctx).highlight end,
            },
            label = {
              text = function(ctx) return require("colorful-menu").blink_components_text(ctx) end,
              highlight = function(ctx) return require("colorful-menu").blink_components_highlight(ctx) end,
            },
            source_name = {
              width = { max = 100 },
              text = function(ctx) return "(" .. ctx.source_name .. ")" end,
              highlight = "BlinkCmpSource",
            },
          },
          columns = {
            { "kind_icon" },
            { "label", gap = 1 },
            { "source_name" },
          },
        },
        ---@diagnostic disable-next-line: assign-type-mismatch
        direction_priority = function()
          local ctx = require("blink.cmp").get_context()
          local item = require("blink.cmp").get_selected_item()
          if ctx == nil or item == nil then return { "s", "n" } end

          local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
          local _multi_line = item_text:find "\n" ~= nil

          -- after showing the menu upwards, we want to maintain that direction
          -- until we re-open the menu, so store the context id in a global variable
          if _multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
            vim.g.blink_cmp_upwards_ctx_id = ctx.id
            return { "n", "s" }
          end
          return { "s", "n" }
        end,
      },
      accept = {
        auto_brackets = { enabled = true },
      },
      documentation = {
        draw = function(opts)
          if opts.item and opts.item.documentation and opts.item.documentation.value then
            local out = require("pretty_hover.parser").parse(opts.item.documentation.value)
            opts.item.documentation.value = out:string()
          end

          ---@diagnostic disable-next-line: param-type-mismatch
          opts.default_implementation(opts)
        end,
        auto_show = true,
        auto_show_delay_ms = 0,
        window = {
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        },
      },
    },
    cmdline = {
      -- NOTE: use mini.cmdline instead
      enabled = false,
      keymap = {
        ["<End>"] = { "hide", "fallback" },
      },
      completion = {
        ghost_text = { enabled = false },
        menu = {
          auto_show = true,
          draw = {
            columns = {
              { "kind_icon" },
              { "label", gap = 1 },
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
    -- NOTE: Use default nvim instead
    signature = {
      enabled = false,
      window = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },
    keymap = {
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-N>"] = { "select_next", "show" },
      ["<C-P>"] = { "select_prev", "show" },
      ["<C-J>"] = { "select_next", "fallback" },
      ["<C-K>"] = { "select_prev", "fallback" },
      ["<C-U>"] = { "scroll_documentation_up", "fallback" },
      ["<C-D>"] = { "scroll_documentation_down", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },

      ["<Tab>"] = {
        function(cmp)
          return cmp.select_next {
            auto_insert = not vim.g.Vm or vim.g.Vm.mappings_enabled == 0,
          }
        end,
        "snippet_forward",
        function(cmp)
          if has_words_before() or vim.api.nvim_get_mode().mode == "c" then cmp.show() end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        function(cmp)
          return cmp.select_prev {
            auto_insert = not vim.g.Vm or vim.g.Vm.mappings_enabled == 0,
          }
        end,
        "snippet_backward",
        function(cmp)
          if vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
        end,
        "fallback",
      },
      ["<C-j>"] = {
        "snippet_forward",
        "fallback",
      },
      ["<C-k>"] = {
        "snippet_backward",
        "fallback",
      },
      ["<CR>"] = {
        "accept",
        "fallback",
      },
    },
  }
  require("blink.cmp").setup()
end)

later(function()
  add { "https://github.com/HakonHarnes/img-clip.nvim" }
  require("img-clip").setup {
    default = {
      prompt_for_file_name = false,
      drag_and_drop = {
        insert_mode = true,
      },
      use_absolute_path = vim.fn.has "win32" == 1, -- default to absolute path for windows users
    },
    filetypes = {
      codecompanion = {
        prompt_for_file_name = false,
        template = "[Image]($FILE_PATH)",
        use_absolute_path = true,
      },
    },
  }
  vim.keymap.set("n", "<Leader>P", "<CMD>PasteImage<CR>", { desc = "Paste image" })
end)

later(function()
  add {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    { src = "https://github.com/boydaihungst/lspsaga.nvim", version = "main" },
  }
  if vim.version().minor < 12 then return end
  local opts = {}
  local get_icon = function(icon) return Config.get_custom_icon(icon, 0, true) end
  opts.request_timeout = 2000
  opts.finder = {
    layout = "float",
    keys = {
      -- Switch between preview and lt result windows
      shuttle = { "<BS>" },
      edit = "<C-c>o",
      vsplit = "<C-c>v",
      split = "<C-c>i",
      tabe = "<C-c>t",
      close = "<C-C>",
      quit = { "q", "<ESC>" },
      go_peek = { "l", "h" },
      toggle_or_open = "<CR>",
    },
    default = "ref+imp+tyd",
    filter = {},
    methods = {
      ["tyd"] = "textDocument/typeDefinition",
      ["dec"] = "textDocument/declaration",
    },
  }
  opts.definition = {
    width = 0.8,
    height = 0.7,
    keys = {
      edit = "<C-c>o",
      vsplit = "<C-c>v",
      split = "<C-c>i",
      tabe = "<C-c>t",
      quit = "q",
    },
  }
  opts.code_action = {
    num_shortcut = true,
    show_server_name = true,
    max_width = 0.8,
    max_height = 0.6,
    extend_gitsigns = pcall(require, "gitsigns.nvim"),
    wrap_around = true,
    keys = {
      -- string | table type
      quit = { "q", "<ESC>" },
      exec = "<CR>",
    },
    -- code action will display from high > low priority
    server_priority = {
      default = 1000,
      gitsigns = 100,
      ["dev-tools"] = 400,
      eslint = 500,
      eslint_d = 500,
    },
  }
  opts.lightbulb = {
    enable = true,
    enable_in_insert = true,
    sign = true,
    sign_priority = 40,
    virtual_text = false,
    ignore = {
      clients = {
        "dev-tools",
      },
      ft = { "nvim-undotree" },
    },
  }
  opts.diagnostic = {
    show_code_action = true,
    show_source = true,
    jump_num_shortcut = true,
    auto_preview = true,
    show_layout = "float",
    show_normal_height = 10,
    max_width = 0.8,
    max_height = 0.6,
    max_show_width = 0.9,
    max_show_height = 0.6,
    wrap_long_lines = true,
    diagnostic_only_current = false,
    extend_relatedInformation = true,
    keys = {
      focus_code_action = "<C-c>o",
      exec_action = "o",
      quit = "q",
      send_to_quickfix = "<C-q>",
      toggle_or_jump = "<CR>",
      quit_in_show = { "q", "<ESC>" },
    },
  }
  -- NOTE: Need to set symbols_in_winbar.enable = true
  opts.implement = {
    enable = true,
    sign = true,
    -- code language/filetype
    -- lang = { "typescript" },
    virtual_text = false,
    priority = 100,
  }
  opts.callhierarchy = {
    layout = "float",
    left_width = 0.2,
    keys = {
      edit = "e",
      vsplit = "s",
      split = "i",
      tabe = "t",
      close = "<C-c>k",
      quit = { "q", "<ESC>" },
      shuttle = "[w",
      toggle_or_req = "u",
    },
  }
  opts.typehierarchy = {
    layout = "float",
    left_width = 0.2,
    keys = {
      edit = "e",
      vsplit = "s",
      split = "i",
      tabe = "t",
      close = "<C-c>k",
      quit = { "q", "<ESC>" },
      shuttle = "[w",
      toggle_or_req = "u",
    },
  }

  opts.rename = {
    keys = {
      quit = "<C-k>",
      exec = "<CR>",
      select = "x",
      confirm = "<CR>",
    },
    in_select = false,
  }
  opts.outline = {
    win_position = "right",
    detail = false,

    auto_preview = true,
    auto_close = true,
    -- float or normal
    layout = "normal",
    keys = {
      quit = "q",
      toggle_or_jump = { "<CR>", "l" },
      jump = "o",
    },
  }
  opts.symbol_in_winbar = {
    enable = true,
    separator = "  ",
    ignore_patterns = {
      "^oil$",
    },
    hide_keyword = true,
    show_file = false,
    folder_level = 0,
    -- respect_root = true,
    color_mode = true,
  }
  -- Blink highlight after jump
  opts.beacon = {
    enable = true,
    -- Higher value means shorter blink, 1-10
    frequency = 8,
  }
  opts.ui = {
    title = true,
    border = "rounded",
    winblend = 0,
    code_action = get_icon "DiagnosticHint",
    expand = get_icon "FoldClosed",
    collapse = get_icon "FoldOpened",
    lines = { "┗", "┣", "┃", "━", "┏" },
    -- imp_sign = get_icon "",
  }
  opts.scroll_preview = {
    scroll_down = "<C-d>",
    scroll_up = "<C-u>",
  }

  require("lspsaga").setup(opts)

  vim.lsp.buf.incoming_calls = function() vim.cmd "Lspsaga incoming_calls" end
  vim.lsp.buf.outgoing_calls = function() vim.cmd "Lspsaga outgoing_calls" end
  vim.lsp.buf.code_action = function() vim.cmd "Lspsaga code_action" end
  local original_rename = vim.lsp.buf.rename
  vim.lsp.buf.rename = function(new_name, ...)
    if not new_name then
      require("lspsaga.rename"):lsp_rename(...)
    else
      original_rename(new_name, ...)
    end
  end
  vim.lsp.buf.definition = function()
    local _, i18n = pcall(require, "i18n")
    if i18n and i18n._activated then
      if i18n.i18n_definition() or i18n.i18n_definition_next_locale() then return end
    end
    vim.cmd "Lspsaga peek_definition"
  end
  vim.lsp.buf.implementation = function() vim.cmd "Lspsaga finder imp" end
  vim.lsp.buf.references = function()
    local _, i18n = pcall(require, "i18n")
    if i18n and i18n._activated and i18n.i18n_key_usages() then return end
    vim.cmd "Lspsaga finder ref"
  end
  vim.lsp.buf.type_definition = function() vim.cmd "Lspsaga peek_type_definition" end
  vim.lsp.buf.typehierarchy = function(kind)
    if kind == "subtypes" then
      vim.cmd "Lspsaga subtypes"
    else
      vim.cmd "Lspsaga supertypes"
    end
  end
  vim.lsp.buf.declaration = function() vim.cmd "Lspsaga peek_declaration" end
end)

on_filetype("markdown,markdown.mdx", function()
  vim.g.mkdp_filetypes = { "markdown", "markdown.mdx" }
  vim.g.mkdp_auto_start = false

  Config.on_packchanged(
    "markdown-preview.nvim",
    { "update" },
    function() vim.cmd "call mkdp#util#install()" end,
    ":call mkdp#util#install()"
  )
  add { "https://github.com/iamcco/markdown-preview.nvim" }
  vim.cmd "call mkdp#util#install()"

  local prefix = "<leader>M"

  if wk then wk.add { { prefix, group = Config.get_custom_icon("Markdown", 1, true) .. "Markdown" } } end

  vim.keymap.set("n", prefix .. "p", "<cmd>MarkdownPreview<cr>", { desc = "Preview" })
  vim.keymap.set("n", prefix .. "s", "<cmd>MarkdownPreviewStop<cr>", { desc = "Stop preview" })
  vim.keymap.set("n", prefix .. "t", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle preview" })
end)

later(function()
  vim.g.markview_alpha = 0.4
  add { "https://github.com/OXY2DEV/markview.nvim" }

  local allowed_hybrid_modes_ft = { "Avante", "codecompanion", "help" }
  local disabled_buftypes = { "sagacodeaction", "sagadiagnostic", "sagatypehierarchy" }
  local allowed_ft = {
    "markdown",
    "markdown_inline",
    "quarto",
    "rmd",
    "Avante",
    "codecompanion",
    "help",
    "checkhealth",
  }
  ---@type markview.config
  local opts = {
    experimental = {
      fancy_comments = true,
    },
    preview = {
      debounce = 100,
      -- Prefer mini
      map_gx = false,
      hybrid_modes = { "n" },
      enable_hybrid_mode = false,
      headings = { shift_width = 0 },
      icon_provider = "mini", -- "mini" or "devicons"
      -- Use disabled_buftypes list above instead
      ignore_buftypes = {},
      condition = function(bufnr)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
        if vim.tbl_contains(disabled_buftypes, buftype) then return false end
        return nil
      end,
      filetypes = allowed_ft,
    },
    markdown = {
      reference_definitions = {
        enable = true,
        -- Setting website here
        -- ["github%.com/[%a%d%-%_%.]+%/?$"] = {
        --   --- github.com/<user>
        --
        --   icon = " ",
        --   hl = "MarkviewPalette0Fg",
        -- },
      },
      code_blocks = {
        -- disable to prevent hover window shifting
        sign = false,
        label_direction = "right",
        enable = true,
      },

      list_items = {
        shift_width = function(buffer, item)
          ---@type integer Parent list items indent. Must be at least 1.
          local parent_indent = math.max(1, item.indent - vim.bo[buffer].shiftwidth)
          return item.indent * (1 / (parent_indent * 2))
        end,
        marker_minus = {
          add_padding = function(_, item) return item.indent > 1 end,
        },
      },
    },
  }

  opts.markdown.headings = require("markview.presets").headings.arrowed
  opts.markdown.horizontal_rules = require("markview.presets").horizontal_rules.thin
  opts.markdown.tables = require("markview.presets").tables.single
  require("markview.extras.headings").setup()
  -- require("markview.extras.editor").setup()
  require("markview.extras.checkboxes").setup {
    --- Default checkbox state(used when adding checkboxes).
    ---@type string
    default = "x",

    --- Changes how checkboxes are removed.
    ---@type
    ---| "disable" Disables the checkbox.
    ---| "checkbox" Removes the checkbox.
    ---| "list_item" Removes the list item markers too.
    remove_style = "list_item",

    --- Various checkbox states.
    ---
    --- States are in sets to quickly change between them
    --- when there are a lot of states.
    ---@type string[][]
    states = {
      { " ", "x" },
      { "<", ">" },
      { "?", "!", "*" },
      { '"' },
      { "l", "b", "i" },
      { "S", "I" },
      { "p", "c" },
      { "f", "k", "w" },
      { "u", "d" },
    },
  }

  require("markview").setup(opts)
  -- Enable hybrid mode for real markdown file only
  vim.api.nvim_create_autocmd("User", {
    pattern = "MarkviewAttach",
    callback = function(event)
      local data = event.data
      if data and vim.api.nvim_buf_is_valid(data.buffer) then
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = data.buffer })
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = data.buffer })
        if buftype ~= "nofile" or vim.tbl_contains(allowed_hybrid_modes_ft, filetype) then
          require("markview.actions").hybridEnable(data.buffer)
        end
      end
    end,
  })
end)
later(function()
  add { "https://github.com/danymat/neogen" }
  local neogeo = require "neogen"
  neogeo.setup {
    languages = {
      lua = { template = { annotation_convention = "emmylua" } },
      typescript = { template = { annotation_convention = "tsdoc" } },
      typescriptreact = { template = { annotation_convention = "tsdoc" } },
      vue = { template = { annotation_convention = "tsdoc" } },
      javascript = { template = { annotation_convention = "jsdoc" } },
      javascriptreact = { template = { annotation_convention = "jsdoc" } },
      ruby = { template = { annotation_convention = "yard" } },
    },
    snippet_engine = MiniSnippets and "mini" or "luasnip",
  }

  if wk then
    wk.add {
      {
        "<leader>a",
        group = Config.get_custom_icon("Neogen", 1, true) .. "Annotation",
      },
    }
  end
  local function gen(type)
    return function() require("neogen").generate { type = type } end
  end
  local prefix = "<leader>a"
  vim.keymap.set("n", prefix .. "<CR>", gen "any", { desc = "Current" })
  vim.keymap.set("n", prefix .. "c", gen "class", { desc = "Class" })
  vim.keymap.set("n", prefix .. "f", gen "func", { desc = "Function" })
  vim.keymap.set("n", prefix .. "t", gen "type", { desc = "Type" })
  vim.keymap.set("n", prefix .. "F", gen "file", { desc = "File" })
end)

later(function()
  vim.g.neotest_vstest = {
    build_opts = {
      -- Arguments that will be added to all `dotnet build` and `dotnet msbuild` commands
      additional_args = {},
    },
    -- If project contains directories which are not supposed to be searched for solution files
    discovery_directory_filter = function(search_path)
      -- ignore hidden directories
      return search_path:match "/%."
    end,
    -- if no obvious parent solution is found, broadly scan downward for solution files from current path. This can freeze Neovim when started from broad directories.
    broad_recursive_discovery = true,
    timeout_ms = 30 * 5 * 1000, -- number of milliseconds to wait before timeout while communicating with adapter client
  }

  add {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/antoinemadec/FixCursorHold.nvim",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/marilari88/neotest-vitest",
    "https://github.com/nvim-neotest/neotest-jest",
    "https://github.com/Nsidorenco/neotest-vstest",
    "https://github.com/nvim-neotest/neotest",
  }
  local neotest = require "neotest"
  -- NOTE: We don't use virtual text (init.lua)
  -- vim.diagnostic.config({
  --   virtual_text = {
  --     format = function(diagnostic)
  --       local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
  --       return message
  --     end,
  --   },
  -- }, vim.api.nvim_create_namespace 'neotest')

  local opts = {
    floating = { border = vim.o.winborder },
    adapters = {
      require "neotest-vstest",
    },
  }

  if vim.pack.is_available "overseer" then
    opts.consumers = opts.consumers or {}
    opts.consumers.overseer = require "neotest.consumers.overseer"
  end

  if vim.g.icons_enabled == false then
    opts.icons = {
      failed = "X",
      notify = "!",
      passed = "O",
      running = "*",
      skipped = "-",
      unknown = "?",
      watching = "W",
    }
  end

  neotest.setup(opts)
  local prefix = "<Leader>T"
  local watch_prefix = prefix .. "W"
  local get_file_path = function() return vim.fn.expand "%" end
  local get_project_path = function() return vim.fn.getcwd() end

  -- Neotest Main Mappings
  vim.keymap.set("n", prefix .. "t", function() neotest.run.run() end, { desc = "Run test" })
  ---@diagnostic disable-next-line: missing-fields
  vim.keymap.set("n", prefix .. "d", function() neotest.run.run { strategy = "dap" } end, { desc = "Debug test" })
  vim.keymap.set(
    "n",
    prefix .. "f",
    function() neotest.run.run(get_file_path()) end,
    { desc = "Run all tests in file" }
  )
  vim.keymap.set(
    "n",
    prefix .. "p",
    function() neotest.run.run(get_project_path()) end,
    { desc = "Run all tests in project" }
  )
  vim.keymap.set("n", prefix .. "<CR>", function() neotest.summary.toggle() end, { desc = "Test Summary" })
  vim.keymap.set("n", prefix .. "o", function() neotest.output.open() end, { desc = "Output hovered test" })
  vim.keymap.set("n", prefix .. "O", function() neotest.output_panel.toggle() end, { desc = "Toggle Output window" })

  -- Navigation
  vim.keymap.set("n", "]T", function() neotest.jump.next() end, { desc = "Next test" })
  vim.keymap.set("n", "[T", function() neotest.jump.prev() end, { desc = "Prev test" })

  -- Watch Mappings
  vim.keymap.set("n", watch_prefix .. "t", function() neotest.watch.toggle() end, { desc = "Toggle watch test" })
  vim.keymap.set(
    "n",
    watch_prefix .. "f",
    function() neotest.watch.toggle(get_file_path()) end,
    { desc = "Toggle watch all test in file" }
  )
  vim.keymap.set(
    "n",
    watch_prefix .. "p",
    function() neotest.watch.toggle(get_project_path()) end,
    { desc = "Toggle watch all tests in project" }
  )
  ---@diagnostic disable-next-line: missing-parameter
  vim.keymap.set("n", watch_prefix .. "S", function() neotest.watch.stop() end, { desc = "Stop all watches" })

  if wk then
    wk.add {
      { prefix, group = Config.get_custom_icon("Tests", 1, true) .. "Tests" },
      { watch_prefix, group = Config.get_custom_icon("Watch", 1, true) .. "Watch" },
    }
  end
end)

later(function()
  add {
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/mfussenegger/nvim-lint",
  }
  local lint = require "lint"
  local opts = {
    linters_by_ft = {},
    linters = {},
  }

  lint.linters_by_ft = opts.linters_by_ft or {}
  for name, linter in pairs(opts.linters or {}) do
    local base = lint.linters[name]
    lint.linters[name] = (type(linter) == "table" and type(base) == "table")
        and vim.tbl_deep_extend("force", base, linter)
      or linter
  end

  local valid_linters = function(ctx, linters)
    if not linters then return {} end
    return vim.tbl_filter(function(name)
      local linter = lint.linters[name]
      return linter
        and vim.fn.executable(linter.cmd) == 1
        and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
    end, linters)
  end

  ---@param orig? function the original function to override, if `nil`  provided then an empty function is passed
  ---@param override fun(orig:function, ...):... the override function
  ---@return function patched the new function with the patch applied
  local function patch_func(orig, override)
    if not orig then orig = function() end end
    return function(...) return override(orig, ...) end
  end
  lint._resolve_linter_by_ft = patch_func(lint._resolve_linter_by_ft, function(orig, ...)
    local ctx = { filename = vim.api.nvim_buf_get_name(0) }
    ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")

    local linters = valid_linters(ctx, orig(...))
    if not linters[1] then linters = valid_linters(ctx, lint.linters_by_ft["_"]) end -- fallback

    linters = vim.tbl_unique_extend(linters, valid_linters(ctx, lint.linters_by_ft["*"])) -- global

    return linters
  end)

  lint.try_lint()

  local timer = (vim.uv or vim.loop).new_timer()
  Config.new_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, nil, function()
    -- only run autocommand when nvim-lint  loaded
    if lint and timer then
      timer:start(100, 0, function()
        timer:stop()
        vim.schedule(lint.try_lint)
      end)
    end
  end)
end)

later(function()
  add {
    "https://github.com/pwntester/octo.nvim",
  }
  local opts = {
    use_local_fs = false, -- use local files on right side of reviews
    enable_builtin = true, -- shows a list of builtin actions when no action is provided
    ssh_aliases = {},
    github_hostname = "", -- GitHub Enterprise host
    gh_cmd = "gh", -- Command to use when calling Github CLI
    gh_env = {}, -- extra environment variables to pass on to GitHub CLI, can be a table or function returning a table
    default_to_projects_v2 = false, -- use projects v2 for the `Octo card ...` command by default. Both legacy and v2 commands are available under `Octo cardlegacy ...` and `Octo cardv2 ...` respectively.
    use_diagnostic_signs = true,
    mappings = {},
    picker = (vim.pack.is_available "telescope" and "telescope")
      or (vim.pack.is_available "fzf-lua" and "fzf-lua")
      or (vim.pack.is_available "snacks" and "snacks")
      or "default",
  }

  if vim.fn.executable(opts.gh_cmd) == 0 then return end
  require("octo").setup(opts)
  local prefix = "<Leader>O"

  -- Assignee/Reviewer
  vim.keymap.set("n", prefix .. "aa", "<Cmd>Octo assignee add<CR>", { desc = "Assign a user" })
  vim.keymap.set("n", prefix .. "ap", "<Cmd>Octo reviewer add<CR>", { desc = "Assign a PR reviewer" })
  vim.keymap.set("n", prefix .. "ar", "<Cmd>Octo assignee remove<CR>", { desc = "Remove a user" })

  -- Comments
  vim.keymap.set("n", prefix .. "ca", "<Cmd>Octo comment add<CR>", { desc = "Add a new comment" })
  vim.keymap.set("n", prefix .. "cd", "<Cmd>Octo comment delete<CR>", { desc = "Delete a comment" })

  -- Reaction
  vim.keymap.set("n", prefix .. "e1", "<Cmd>Octo reaction thumbs_up<CR>", { desc = "Add 👍 reaction" })
  vim.keymap.set("n", prefix .. "e2", "<Cmd>Octo reaction thumbs_down<CR>", { desc = "Add 👎 reaction" })
  vim.keymap.set("n", prefix .. "e3", "<Cmd>Octo reaction eyes<CR>", { desc = "Add 👀 reaction" })
  vim.keymap.set("n", prefix .. "e4", "<Cmd>Octo reaction laugh<CR>", { desc = "Add 😄 reaction" })
  vim.keymap.set("n", prefix .. "e5", "<Cmd>Octo reaction confused<CR>", { desc = "Add 😕 reaction" })
  vim.keymap.set("n", prefix .. "e6", "<Cmd>Octo reaction rocket<CR>", { desc = "Add 🚀 reaction" })
  vim.keymap.set("n", prefix .. "e7", "<Cmd>Octo reaction heart<CR>", { desc = "Add ❤️ reaction" })
  vim.keymap.set("n", prefix .. "e8", "<Cmd>Octo reaction party<CR>", { desc = "Add 🎉 reaction" })

  -- sues
  vim.keymap.set("n", prefix .. "ic", "<Cmd>Octo issue close<CR>", { desc = "Close current issue" })
  vim.keymap.set("n", prefix .. "il", "<Cmd>Octo issue list<CR>", { desc = "List open issues" })
  vim.keymap.set("n", prefix .. "io", "<Cmd>Octo issue browser<CR>", { desc = "Open current issue in browser" })
  vim.keymap.set("n", prefix .. "ir", "<Cmd>Octo issue reopen<CR>", { desc = "Reopen current issue" })
  vim.keymap.set("n", prefix .. "iu", "<Cmd>Octo issue url<CR>", { desc = "Copies URL of current issue" })

  -- Label
  vim.keymap.set("n", prefix .. "la", "<Cmd>Octo label add<CR>", { desc = "Assign a label" })
  vim.keymap.set("n", prefix .. "lc", "<Cmd>Octo label create<CR>", { desc = "Create a label" })
  vim.keymap.set("n", prefix .. "lr", "<Cmd>Octo label remove<CR>", { desc = "Remove a label" })

  -- Pull requests
  vim.keymap.set("n", prefix .. "pc", "<Cmd>Octo pr close<CR>", { desc = "Close current PR" })
  vim.keymap.set("n", prefix .. "pd", "<Cmd>Octo pr diff<CR>", { desc = "Show PR diff" })
  vim.keymap.set("n", prefix .. "pl", "<Cmd>Octo pr changes<CR>", { desc = "List changed files in PR" })
  vim.keymap.set("n", prefix .. "pmd", "<Cmd>Octo pr merge delete<CR>", { desc = "Delete merge PR" })
  vim.keymap.set("n", prefix .. "pmm", "<Cmd>Octo pr merge commit<CR>", { desc = "Merge commit PR" })
  vim.keymap.set("n", prefix .. "pmr", "<Cmd>Octo pr merge rebase<CR>", { desc = "Rebase merge PR" })
  vim.keymap.set("n", prefix .. "pms", "<Cmd>Octo pr merge squash<CR>", { desc = "Squash merge PR" })
  vim.keymap.set("n", prefix .. "pn", "<Cmd>Octo pr create<CR>", { desc = "Create PR for current branch" })
  vim.keymap.set("n", prefix .. "po", "<Cmd>Octo pr browser<CR>", { desc = "Open current PR in browser" })
  vim.keymap.set("n", prefix .. "pp", "<Cmd>Octo pr checkout<CR>", { desc = "Checkout PR" })
  vim.keymap.set("n", prefix .. "pr", "<Cmd>Octo pr ready<CR>", { desc = "Mark draft as ready for review" })
  vim.keymap.set("n", prefix .. "ps", "<Cmd>Octo pr list<CR>", { desc = "List open PRs" })
  vim.keymap.set("n", prefix .. "pt", "<Cmd>Octo pr commits<CR>", { desc = "List PR commits" })
  vim.keymap.set("n", prefix .. "pu", "<Cmd>Octo pr url<CR>", { desc = "Copies URL of current PR" })

  -- Repo
  vim.keymap.set("n", prefix .. "rf", "<Cmd>Octo repo fork<CR>", { desc = "Fork repo" })
  vim.keymap.set("n", prefix .. "rl", "<Cmd>Octo repo list<CR>", { desc = "List repo user stats" })
  vim.keymap.set("n", prefix .. "ro", "<Cmd>Octo repo open<CR>", { desc = "Open current repo in browser" })
  vim.keymap.set("n", prefix .. "ru", "<Cmd>Octo repo url<CR>", { desc = "Copies URL of current repo" })

  -- Review
  vim.keymap.set("n", prefix .. "sc", "<Cmd>Octo review comments<CR>", { desc = "View pending comments" })
  vim.keymap.set("n", prefix .. "sd", "<Cmd>Octo review dcard<CR>", { desc = "Delete pending review" })
  vim.keymap.set("n", prefix .. "sf", "<Cmd>Octo review submit<CR>", { desc = "Submit review" })
  vim.keymap.set("n", prefix .. "sp", "<Cmd>Octo review commit<CR>", { desc = "Select commit to review" })
  vim.keymap.set("n", prefix .. "sr", "<Cmd>Octo review resume<CR>", { desc = "Resume review" })
  vim.keymap.set("n", prefix .. "ss", "<Cmd>Octo review start<CR>", { desc = "Start review" })

  -- Threads
  vim.keymap.set("n", prefix .. "ta", "<Cmd>Octo thread resolve<CR>", { desc = "Mark thread as resolved" })
  vim.keymap.set("n", prefix .. "td", "<Cmd>Octo thread unresolve<CR>", { desc = "Mark thread as unresolved" })

  -- Misc
  vim.keymap.set("n", prefix .. "x", "<Cmd>Octo actions<CR>", { desc = "Run an action" })

  --- Which-key Group
  if wk then
    wk.add {
      { prefix, group = Config.get_custom_icon("Octo", 1, true) .. "Octo" },
      { prefix .. "a", group = "Assignee/Reviewer" },
      { prefix .. "c", group = "Comments" },
      { prefix .. "e", group = "Reaction" },
      { prefix .. "i", group = "Issues" },
      { prefix .. "l", group = "Label" },
      { prefix .. "p", group = "Pull requests" },
      { prefix .. "pm", group = "Merge current PR" },
      { prefix .. "r", group = "Repo" },
      { prefix .. "s", group = "Review" },
      { prefix .. "t", group = "Threads" },
    }
  end
end)

later(function()
  add { "https://github.com/stevearc/overseer.nvim" }
  local overseer = require "overseer"

  require("overseer").setup {
    dap = false,
    strategy = vim.pack.is_available "toggleterm" and "toggleterm",
    task_list = {
      bindings = {
        ["<C-l>"] = false,
        ["<C-h>"] = false,
        ["<C-k>"] = false,
        ["<C-j>"] = false,
        q = "<Cmd>close<CR>",
        K = "IncreaseDetail",
        J = "DecreaseDetail",
        ["<C-p>"] = "ScrollOutputUp",
        ["<C-n>"] = "ScrollOutputDown",
      },
    },
  }
  if vim.pack.is_available "dap" then overseer.enable_dap() end

  local prefix = "<Leader>r"
  vim.keymap.set("n", prefix .. "t", "<Cmd>OverseerToggle!<CR>", { desc = "Toggle Overseer" })
  vim.keymap.set("n", prefix .. "c", "<Cmd>OverseerRunCmd<CR>", { desc = "Run Command" })
  vim.keymap.set("n", prefix .. "r", "<Cmd>OverseerRun<CR>", { desc = "Run Task" })
  vim.keymap.set("n", prefix .. "q", "<Cmd>OverseerQuickAction<CR>", { desc = "Quick Action" })
  vim.keymap.set("n", prefix .. "a", "<Cmd>OverseerTaskAction<CR>", { desc = "Task Action" })
  vim.keymap.set("n", prefix .. "i", "<Cmd>OverseerInfo<CR>", { desc = "Overseer Info" })

  if wk then wk.add {
    { prefix, group = Config.get_custom_icon("Overseer", 1, true) .. "Overseer" },
  } end
end)

on_event("BufRead~package.json", function()
  add {
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/vuki656/package-info.nvim",
  }
  require("package-info").setup {
    highlights = {
      up_to_date = {
        fg = "#3C4048",
        ctermfg = 237,
      },
      outdated = {
        fg = "#d19a66",
        bold = true,
      },
      invalid = {
        fg = "#ee4b2b",
        bold = true,
      },
    },
    icons = {
      enable = true,
      style = {
        up_to_date = " ", -- Icon for up to date dependencies
        outdated = " ", -- Icon for outdated dependencies
        invalid = " ", -- Icon for invalid dependencies
      },
    },
    notifications = false, -- Whether to display notifications when running commands
    autostart = true, -- Whether to autostart when `package.json`  opened
    hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
    hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
    -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
    -- The plugin will try to auto-detect the package manager based on
    -- `yarn.lock` or `package-lock.json`. If none are found it will use the
    -- provided one, if nothing  provided it will use `yarn`
    package_manager = "npm",
  }
end)

later(function()
  add {
    "https://github.com/stevearc/quicker.nvim",
  }
  local quicker = require "quicker"
  quicker.setup {
    keys = {
      {
        ">",
        function() quicker.expand { before = 2, after = 2, add_to_existing = true } end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function() quicker.collapse() end,
        desc = "Collapse quickfix context",
      },
    },
    follow = {
      -- When quickfix window  open, scroll to closest item to the cursor
      enabled = true,
    },
  }
  -- Quicker.nvim Keymaps
  vim.keymap.set("n", "<C-q>", function() quicker.toggle { focus = true } end, { desc = "Toggle quickfix" })

  vim.keymap.set("n", "<Leader>eq", function() quicker.toggle { focus = true } end, { desc = "Toggle quickfix" })

  vim.keymap.set(
    "n",
    "<Leader>eQ",
    function() quicker.toggle { focus = true, loclist = true } end,
    { desc = "Toggle loclist" }
  )
end)

on_filetype("sql,mysql", function()
  add {
    "https://github.com/nanotee/sqls.nvim",
  }
end)

later(function()
  vim.g["suda#prompt"] = "Enter root password to save:"
  add {
    "https://github.com/lambdalue/suda.vim",
  }

  local function smart_save()
    if vim.bo.buftype ~= "" then return end
    local filepath = vim.fn.expand "%:p"
    local _writable = vim.fn.filewritable(filepath) == 1

    if vim.bo.readonly or not _writable then
      if vim.fn.exists ":SudaWrite" > 0 then
        vim.cmd "SudaWrite"
      else
        vim.notify("File  readonly and suda.vim is not installed", vim.log.levels.ERROR)
      end
    else
      -- Standard save
      vim.cmd "silent! update | redraw"
    end
  end
  vim.keymap.set({ "n" }, "<C-S>", smart_save, { desc = "Smart Save (Sudo if needed)" })
end)

later(function()
  add {
    "https://github.com/supermaven-inc/supermaven-nvim",
  }

  require("supermaven-nvim").setup {
    ignore_filetypes = { "sql", "grug-far", "snacks_picker_input", "neo-tree-popup" },
    --return true -> disable
    condition = function() return Config.is_large(nil, { lines = 5000 }) end,
    keymaps = {
      accept_suggestion = "<C-l>",
      clear_suggestion = "<C-h>",
      accept_word = "<C-w>",
    },
    log_level = "off",
    disable_inline_completion = false, -- disables inline completion for use with cmp
    disable_keymaps = false, -- disables built in keymaps for more manual control
    -- color = {
    --   suggestion_color = "#ffffff",
    --   cterm = 244,
    -- },
  }
end)

later(function()
  add {
    "https://github.com/rachartier/tiny-inline-diagnostic.nvim",
  }
  -- disable diagnostics virtual text to prevent duplicates
  vim.diagnostic.config { virtual_text = false }

  require("tiny-inline-diagnostic").setup {
    preset = "minimal",
    signs = {
      -- left = "",
      -- right = "",
      left = "",
      right = "",
      diag = "ඞ",
      arrow = "    ",
      up_arrow = "    ",
      vertical = " │",
      vertical_end = " └",
    },
    hi = {
      error = "DiagnosticError",
      warn = "DiagnosticWarn",
      info = "DiagnosticInfo",
      hint = "DiagnosticHint",
      arrow = "NonText",
      background = "CursorLine", -- Can be a highlight or a hexadecimal color (#RRGGBB)
      mixing_color = "None", -- Can be None or a hexadecimal color (#RRGGBB). Used to blend the background color with the diagnostic background color with another color.
    },
    blend = {
      factor = 0.27,
    },
    options = {
      -- Show the source of the diagnostic.
      show_source = false,

      -- Throttle the update of the diagnostic when moving cursor, in milliseconds.
      -- You can increase it if you have performance issues.
      -- Or set it to 0 to have better visuals.
      -- 20
      throttle = 20,

      -- The minimum length of the message, otherwise it will be on a new line.
      softwrap = 15,

      -- If multiple diagnostics are under the cursor, display all of them.
      multiple_diag_under_cursor = true,

      -- Configuration for multiline diagnostics
      -- Can be a boolean or a table with detailed options
      multilines = {
        -- Enable multiline diagnostic messages
        enabled = false,

        -- Always show messages on all lines for multiline diagnostics
        always_show = false,

        -- Trim whitespaces from the start/end of each line
        trim_whitespaces = false,

        -- Replace tabs with this many spaces in multiline diagnostics
        tabstop = 4,
      },

      -- Show all diagnostics on the cursor line.
      show_all_diags_on_cursorline = false,

      -- Enable diagnostics on Insert mode. You should also set the `throttle` option to 0, as some artifacts may appear.
      enable_on_insert = false,

      -- Enable diagnostics in Select mode (e.g., when auto-completing with Blink)
      enable_on_select = false,

      overflow = {
        -- Manage the overflow of the message.
        --    - wrap: when the message  too long, it is then displayed on multiple lines.
        --    - none: the message will not be truncated.
        --    - oneline: message will be displayed entirely on one line.
        mode = "wrap",

        -- Trigger wrapping this many characters earlier when mode == "wrap"
        -- Increase if the last few characters of wrapped diagnostics are obscured
        padding = 0,
      },

      -- Format the diagnostic message.
      -- Example:
      -- format = function(diagnostic)
      --     return diagnostic.message .. " [" .. diagnostic.source .. "]"
      -- end,
      format = nil,

      --- Enable it if you want to always have message with `after` characters length.
      break_line = {
        enabled = false,
        after = 30,
      },

      virt_texts = {
        priority = 2048,
      },

      -- Filter by severity.
      severity = {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
        vim.diagnostic.severity.INFO,
        vim.diagnostic.severity.HINT,
      },

      -- Overwrite events to attach to a buffer. You should not change it, but if the plugin
      -- does not works in your configuration, you may try to tweak it.
      overwrite_events = nil,
      disabled_ft = { "ssa" },
    },
  }
end)

later(function()
  add {
    "https://github.com/folke/ts-comments.nvim",
  }
  require("ts-comments").setup {
    lang = {
      kitty = "# %s",
      mpvconfig = "# %s",
    },
  }
end)

later(function()
  vim.g.undotree_WindowLayout = 3
  vim.g.undotree_SplitWidth = 50
  vim.g.undotree_DiffpanelHeight = 25
  vim.g.undotree_DiffAutoOpen = 0
  vim.g.undotree_SetFocusWhenToggle = 1
  vim.g.undotree_HighlightChangedText = 1
  vim.g.undotree_ShortIndicators = 0
  vim.g.undotree_SignAdded = Config.get_custom_icon("GitAdd", 1, true)
  vim.g.undotree_SignModified = Config.get_custom_icon("GitChange", 1, true)
  vim.g.undotree_SignDeleted = Config.get_custom_icon("GitDelete", 1, true)

  add {
    "https://github.com/mbbill/undotree",
  }

  vim.keymap.set("n", "<Leader>fu", "<Cmd>UndotreeToggle<CR>", { desc = "Undotree" })
end)

later(function()
  local prefix = "<leader>m"
  vim.g.VM_leader = vim.g.VM_leader or prefix
  vim.g.VM_silent_exit = 1
  vim.g.VM_show_warnings = 0

  -- Remap <cr> to fix enter to select in blink
  -- Source: https://github.com/Saghen/blink.cmp/sues/406#issuecomment-2537184121
  -- Check th if you use VM_custom_motions: https://github.com/Saghen/blink.cmp/issues/406#issuecomment-3239199356
  vim.g.VM_maps = {
    ["I BS"] = "",
    ["Goto Next"] = "]v",
    ["Goto Prev"] = "[v",
    ["I CtrlB"] = "<M-b>",
    ["I CtrlF"] = "<M-f>",
    ["I Return"] = "<S-CR>",
    ["I Down Arrow"] = "",
    ["I Up Arrow"] = "",

    ["Add Cursor Down"] = "<M-Down>",
    ["Add Cursor Up"] = "<M-Up>",
  }
  -- To use the same highlight as search
  vim.g.VM_highlight_matches = ""

  add { "https://github.com/mg979/vim-visual-multi" }
  vim.api.nvim_set_hl(0, "VM_Cursor", { link = "Cursor" })
  vim.api.nvim_set_hl(0, "VM_mono", { link = "Cursor" })
  Config.new_autocmd("User", "visual_multi_mappings", function()
    -- Remap p and P to paste (from + or * register) because `opt.clipboard = "unnamedplus"`
    -- Source: https://github.com/mg979/vim-visual-multi/issues/116
    if vim.tbl_contains(vim.opt.clipboard:get(), "unnamedplus") then
      vim.keymap.set("n", "p", '"+<Plug>(VM-p-Paste)', { buffer = true })
      vim.keymap.set("n", "P", '"+<Plug>(VM-P-Paste)', { buffer = true })
    elseif vim.tbl_contains(vim.opt.clipboard:get(), "unnamed") then
      vim.keymap.set("n", "p", '"*<Plug>(VM-p-Paste)', { buffer = true })
      vim.keymap.set("n", "P", '"*<Plug>(VM-P-Paste)', { buffer = true })
    end
  end, "p and P to paste from system clipboard")

  if wk then
    wk.add {
      {
        prefix,
        group = Config.get_custom_icon("VimVisualMulti", 1, true) .. "Multi Cursors",
        mode = { "n", "v" },
      },
      { prefix .. "A", desc = "Select all occurrences word under cursor", mode = "n" },
      { prefix .. "/", desc = "Start regex search", mode = "n" },
      { prefix .. "\\", desc = "Add a single cursor at current position", mode = "n" },
      { prefix .. "gS", desc = "Reselect last visual selection", mode = "n" },

      -- visual mode groups
      { prefix, group = "Multi Cursors", mode = "v" },
      { prefix .. "a", desc = "Convert a visual selection to a VM selection", mode = "v" },
      { prefix .. "A", desc = "Select all occurrences of selection text", mode = "v" },
      { prefix .. "c", desc = "Add cursors downwards from start of visual block", mode = "v" },
      { prefix .. "/", desc = "Start regex search within selected text", mode = "v" },
    }
  end
end)

later(function()
  add { "https://github.com/svban/YankAssassin.nvim" }
  require("YankAssassin").setup {
    auto_normal = true, -- if true, autocmds are used. Whenever y  used in normal mode, the cursor doesn't move to start
    auto_visual = true, -- if true, autocmds are used. Whenever y is used in visual mode, the cursor doesn't move to start
  }
end)

later(function()
  add { "https://github.com/windwp/nvim-autopairs" }
  require("nvim-autopairs").setup {
    check_ts = true,
    enabled = function(bufnr) return Config.is_valid_buf(bufnr) end,
    ts_config = { java = false },
    fast_wrap = {
      avoid_move_to_end = false,
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = ([[ [%'%"%)%>%]%)%}%,] ]]):gsub("%s+", ""),
      offset = 0,
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "PmenuSel",
      highlight_grey = "LineNr",
    },
  }

  vim.keymap.set("n", "\\a", function()
    local ok, autopairs = pcall(require, "nvim-autopairs")
    if ok then
      if autopairs.state.disabled then
        autopairs.enable()
      else
        autopairs.disable()
      end
    end
  end, { desc = "Toggle autopair" })
end)

later(function()
  add { "https://github.com/windwp/nvim-ts-autotag" }
  require("nvim-ts-autotag").setup {}
end)

later(function()
  add { "https://github.com/akinsho/toggleterm.nvim" }
  require("toggleterm").setup {
    float_opts = {
      border = vim.o.winborder,
    },
    highlights = {
      Normal = { link = "Normal" },
      NormalNC = { link = "NormalNC" },
      NormalFloat = { link = "NormalFloat" },
      FloatBorder = { link = "FloatBorder" },
      StatusLine = { link = "StatusLine" },
      StatusLineNC = { link = "StatusLineNC" },
      WinBar = { link = "WinBar" },
      WinBarNC = { link = "WinBarNC" },
    },
    size = function(term)
      if term.direction == "horizontal" then
        return 10
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.3
      end
    end,
    ---@param t Terminal
    on_create = function(t)
      vim.opt_local.foldcolumn = "0"
      vim.opt_local.signcolumn = "no"
      if t.hidden then
        local function toggle() t:toggle() end
        vim.keymap.set({ "n", "t", "i" }, "<C-'>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
        vim.keymap.set({ "n", "t", "i" }, "<F7>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
      end
      vim.keymap.set({ "n", "t", "i" }, "<C-q>", "<cmd>close<CR>", { desc = "Close terminal", buffer = t.bufnr })

      vim.keymap.set({ "n", "t", "i" }, "<C-n>", function()
        vim.cmd "TermNew" -- or your custom toggle logic
      end, { desc = "Split terminal window", buffer = t.bufnr })
    end,
    shading_factor = 2,
  }

  --- A table to manage ToggleTerm terminals created by the user, indexed by the command run and then the instance number
  ---@type table<string,table<integer,table>>
  local user_terminals = {}

  --- Toggle a user terminal if it exists, if not then create a new one and save it
  ---@param opts string|table A terminal command string or a table of options for Terminal:new() (Check toggleterm.nvim documentation for table format)
  _G.toggleterm = {}
  _G.toggleterm.toggle_term_cmd = function(opts)
    local terms = user_terminals
    -- if a command string  provided, create a basic table for Terminal:new() options
    if type(opts) == "string" then opts = { cmd = opts } end
    opts = vim.tbl_deep_extend("force", { hidden = true }, opts)
    local num = vim.v.count > 0 and vim.v.count or 1
    -- if terminal doesn't exist yet, create it
    if not terms[opts.cmd] then terms[opts.cmd] = {} end
    if not terms[opts.cmd][num] then
      if not opts.count then opts.count = vim.tbl_count(terms) * 100 + num end
      local on_exit = opts.on_exit
      opts.on_exit = function(...)
        terms[opts.cmd][num] = nil
        if on_exit then on_exit(...) end
      end
      terms[opts.cmd][num] = require("toggleterm.terminal").Terminal:new(opts)
    end
    -- toggle the terminal
    terms[opts.cmd][num]:toggle()
  end

  local prefix = "<leader>t"
  if vim.fn.executable "git" == 1 and vim.fn.executable "lazygit" == 1 then
    local lazygit = {
      callback = function()
        local git_data = MiniGit and MiniGit.get_buf_data()
        local root = ""
        local git_dir = ""
        if git_data then
          root = git_data.root or ""
          git_dir = git_data.repo or ""
        end
        local flags = root ~= "" and (" --work-tree=%s --git-dir=%s"):format(root, git_dir) or ""
        _G.toggleterm.toggle_term_cmd { cmd = "lazygit " .. flags, direction = "float" }
      end,
      desc = "ToggleTerm lazygit",
    }
    vim.keymap.set({ "n" }, "<Leader>gg", lazygit.callback, { desc = lazygit.desc })
    vim.keymap.set({ "n" }, prefix .. "l", lazygit.callback, { desc = lazygit.desc })
  end

  if vim.fn.executable "lazydocker" == 1 then
    vim.keymap.set(
      { "n" },
      prefix .. "d",
      function() _G.toggleterm.toggle_term_cmd { cmd = "lazydocker", direction = "float" } end,
      { desc = "ToggleTerm lazydocker" }
    )
  end

  if vim.fn.executable "node" == 1 then
    vim.keymap.set(
      { "n" },
      prefix .. "n",
      function() _G.toggleterm.toggle_term_cmd "node" end,
      { desc = "ToggleTerm node" }
    )
  end

  local python = vim.fn.executable "python" == 1 and "python" or vim.fn.executable "python3" == 1 and "python3"
  if python then
    vim.keymap.set(
      { "n" },
      prefix .. "p",
      function() _G.toggleterm.toggle_term_cmd(python) end,
      { desc = "ToggleTerm python" }
    )
  end

  -- ToggleTerm Layouts
  vim.keymap.set("n", prefix .. "f", "<Cmd>ToggleTerm direction=float<CR>", { desc = "ToggleTerm float" })
  vim.keymap.set(
    "n",
    prefix .. "h",
    "<Cmd>ToggleTerm direction=horizontal<CR>",
    { desc = "ToggleTerm horizontal split" }
  )
  vim.keymap.set("n", prefix .. "v", "<Cmd>ToggleTerm direction=vertical<CR>", { desc = "ToggleTerm vertical split" })

  -- F7 Toggle (Normal, Terminal, Insert)
  vim.keymap.set("n", "<F7>", '<Cmd>execute v:count . "ToggleTerm"<CR>', { desc = "Toggle terminal" })
  vim.keymap.set("t", "<F7>", "<Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
  vim.keymap.set("i", "<F7>", "<Esc><Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

  -- Ctrl + ' Toggle (Normal, Terminal, Insert)
  -- Note: Terminal emulator support for <C-'> varies
  vim.keymap.set("n", "<C-'>", '<Cmd>execute v:count . "ToggleTerm"<CR>', { desc = "Toggle terminal" })
  vim.keymap.set("t", "<C-'>", "<Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
  vim.keymap.set("i", "<C-'>", "<Esc><Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

  -- F8 toggle visual mode in terminal buffer
  vim.keymap.set("t", "<F8>", "<C-\\><C-n>", { desc = "Toggle visual mode" })
  vim.keymap.set("n", "<F8>", "i", { desc = "Exit terminal visual mode" })

  -- F19  = Shift + F7 (Shift == 12 -> F12 + F7)
  vim.keymap.set("n", "<F19>", "<Cmd>TermNew<CR>", { desc = "Split terminal window" })

  if wk then wk.add {
    { prefix, group = Config.get_custom_icon("Terminal", 1, true) .. "Terminal" },
  } end

  -- MiniFiles mappings
  if MiniFiles then
    local function toggleterm_in_direction(fs_entry, direction)
      local path = fs_entry.fs_type == "file" and vim.fs.dirname(fs_entry.path) or fs_entry.path
      local term = require("toggleterm.terminal").Terminal:new { dir = path, direction = direction }
      term:open()
      term:focus()
      -- Auto type cursor file name to terminal
      if fs_entry.fs_type == "file" then
        vim.api.nvim_feedkeys(fs_entry.name, "t", true)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Home>", true, false, true), "t", true)
      end
    end

    Config.new_autocmd("User", "MiniFilesBufferCreate", function(args)
      local buf_id = args.data.buf_id
      for suffix, direction in pairs { f = "float", h = "horizontal", v = "vertical" } do
        vim.keymap.set("n", prefix .. suffix, function()
          local cur_fs_entry = MiniFiles.get_fs_entry(buf_id)
          if cur_fs_entry == nil then return vim.notify "Cursor not on valid entry" end
          MiniFiles.close()
          toggleterm_in_direction(cur_fs_entry, direction)
        end, { buffer = buf_id, desc = "Open terminal (" .. direction .. ")" })
      end
    end, "Toggle terminal in MiniFiles buffer")
  end
end)

now(function()
  add { "https://github.com/folke/snacks.nvim" }
  local get_icon = Config.get_custom_icon
  ---@type snacks.Config
  local opts = {
    bigfile = {
      notify = true, -- show notification when big file detected
      size = Config.default_large_buf_opts.size,
      line_length = Config.default_large_buf_opts.line_length, -- average line length (useful for minified files)
      -- Enable or disable features when big file detected
      ---@param ctx {buf: number, ft:string}
      setup = function(ctx)
        if vim.fn.exists ":NoMatchParen" ~= 0 then vim.cmd [[NoMatchParen]] end
        Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
        vim.bo.undorefer = false
        vim.bo.swapfile = false
        vim.b.completion = false
        vim.b.minianimate_disable = true
        vim.b.minihipatterns_disable = true
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then vim.bo[ctx.buf].syntax = ctx.ft end
        end)
      end,
    },
    statuscolumn = {
      left = { "mark", "sign" }, -- priority of signs on the left (high to low)
      right = { "fold", "git" }, -- priority of signs on the right (high to low)
      folds = {
        open = false, -- show open fold icons
        git_hl = false, -- use Git Signs hl for fold icons
      },
      git = {
        -- patterns to match Git signs
        patterns = { "GitSign", "MiniDiffSign" },
      },
      refresh = 50, -- refresh at most every 50ms
    },
    dashboard = {
      enabled = false,
    },
    -- configure `vim.ui.input`
    input = {},
    -- render image support
    image = {
      force = true,
      doc = { enabled = true },
      formats = {
        "png",
        "jpg",
        "jpeg",
        "gif",
        "bmp",
        "webp",
        "tiff",
        "heic",
        "avif",
        "mp4",
        "mov",
        "avi",
        "mkv",
        "webm",
        "pdf",
        "svg",
      },
      img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },

      -- Support 3 types.
      -- img_src_maps = { ["^@assets"] = { "src/assets", "src/assets2" } },
      -- This use string:gsub(src_map), so make sure to escape if you need litteral string.
      img_src_maps = { ["^@assets"] = "src/assets" },
      -- img_src_maps = function(buf_path, img_src) end

      -- The 3rd type can return 2 types above or string. If return string = "XXX" -> img_src = "XXX".
      -- img_src  relative source of the image.
      -- In the example of vue above img_src  src attribute in <img> tag = "@assets/logo.svg"

      -- img_src_maps = function(buf_path, img_src) return { ["^@assets"] = "src/assets" } end,
      -- img_src_maps = function(buf_path, img_src) return "src/assets/logo.svg" end,
      env = {
        placeholders = true,
      },
      ---@param buf_path string
      ---@param img_src string
      resolve = function(buf_path, img_src)
        local Snacks = require "snacks"
        if not img_src:find "^%w%w+://" then
          local img_src_maps = Snacks.image.config.img_src_maps
          local cwd = vim.uv.cwd() or "."
          local checks = { [img_src] = true }
          local srcs = { img_src }

          if type(Snacks.image.config.img_src_maps) == "function" then
            img_src_maps = Snacks.image.config.img_src_maps(buf_path, img_src)
            if type(img_src_maps) == "string" then
              img_src = img_src_maps
              checks[img_src] = true
            end
          end
          if type(img_src_maps) == "table" then
            for pattern, replacement in pairs(img_src_maps) do
              if type(replacement) == "string" then
                srcs[#srcs + 1] = img_src:gsub(pattern, replacement)
                checks[srcs[#srcs]] = true
              elseif type(replacement) == "table" then
                for _, r in ipairs(replacement) do
                  srcs[#srcs + 1] = img_src:gsub(pattern, r)
                  checks[srcs[#srcs]] = true
                end
              end
            end
          end

          for _, root in ipairs { cwd, vim.fs.dirname(buf_path) } do
            for _, new_src in ipairs(srcs) do
              checks[root .. "/" .. new_src] = true
              for _, dir in ipairs(Snacks.image.config.img_dirs) do
                dir = root .. "/" .. dir
                if Snacks.image.doc.is_dir(dir) then checks[dir .. "/" .. new_src] = true end
              end
            end
          end
          for f in pairs(checks) do
            if vim.fn.filereadable(f) == 1 then
              img_src = vim.uv.fs_realpath(f) or f
              break
            end
          end
        end
        img_src = vim.fs.normalize(img_src)
        return img_src
      end,
      max_height = 20,
    },
    -- configure `vim.notify`
    notifier = {
      icons = {
        debug = get_icon "Debugger",
        error = get_icon "DiagnosticError",
        info = get_icon "DiagnosticInfo",
        trace = get_icon "DiagnosticHint",
        warn = get_icon "DiagnosticWarn",
      },
    },
    -- Load file as quickly as possible if run `nvim somefile`
    quickfile = {},
    -- configure picker and `vim.ui.select`
    picker = {
      ui_select = true,
      win = {
        input = {
          keys = {
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<Tab>"] = { "list_down", mode = { "i", "n" } },
            ["<c-j>"] = { "select_and_next", mode = { "i", "n" } },
            ["<c-k>"] = { "select_and_prev", mode = { "i", "n" } },
          },
        },
      },
    },
    -- indent line
    indent = {
      indent = { char = "▏" },
      filter = function(bufnr)
        return Config.is_valid_buf(bufnr)
          and not Config.is_large(bufnr)
          and vim.g.snacks_indent ~= false
          and vim.b[bufnr].snacks_indent ~= false
      end,
      animate = {
        enabled = true,
        style = "out",
        easing = "linear",
        duration = {
          step = 20, -- ms per step
          total = 200, -- maximum duration
        },
      },
      ---@class snacks.indent.Scope.Config: snacks.scope.Config
      scope = {
        enabled = true, -- enable highlighting the current scope
        priority = 200,
        char = "▏",
        underline = false, -- underline the start of the scope
        only_current = false, -- only show scope in the current window
        hl = "SnacksIndentScope", ---@type string|string[] hl group for scopes
      },
      chunk = {
        -- when enabled, scopes will be rendered as chunks, except for the
        -- top-level scope which will be rendered as a scope.
        enabled = true,
        -- only show chunk scopes in the current window
        only_current = false,
        priority = 200,
        hl = "SnacksIndentChunk", ---@type string|string[] hl group for chunk scopes
        char = {
          corner_top = "┌",
          corner_bottom = "└",
          -- corner_top = "╭",
          -- corner_bottom = "╰",
          horizontal = "─",
          vertical = "│",
          arrow = ">",
        },
      },
    },
    scope = {
      filter = function(bufnr)
        return Config.is_valid_buf(bufnr)
          and not Config.is_large(bufnr)
          and vim.g.snacks_scope ~= false
          and vim.b[bufnr].snacks_scope ~= false
      end,
    },
    words = {
      enabled = true,
      filter = function(bufnr)
        return Config.is_valid_buf(bufnr)
          and not Config.is_large(bufnr)
          and vim.g.snacks_words ~= false
          and vim.b[bufnr].snacks_words ~= false
      end,
    },
  }

  local snacks = require "snacks"
  snacks.setup(opts)

  if vim.tbl_get(opts, "indent", "enabled") ~= false then
    vim.keymap.set("n", "\\i", function() snacks.toggle.indent():toggle() end, { desc = "Toggle indent" })
  end

  if vim.tbl_get(opts, "notifier", "enabled") ~= false then
    vim.keymap.set("n", "\\n", function() snacks.notifier.hide() end, { desc = "Dismiss notifications" })
  end
  -- Snacks.gitbrowse
  if vim.tbl_get(opts, "gitbrowse", "enabled") ~= false and vim.fn.executable "git" == 1 then
    vim.keymap.set({ "n", "x" }, "<Leader>go", function() snacks.gitbrowse() end, { desc = "Git browse (open)" })
  end
  if vim.tbl_get(opts, "picker", "enabled") ~= false then
    -- Git Pickers
    if vim.fn.executable "git" == 1 then
      vim.keymap.set("n", "<Leader>gb", function() snacks.picker.git_branches() end, { desc = "Git branches" })
      vim.keymap.set("n", "<Leader>gc", function() snacks.picker.git_log() end, { desc = "Git commits (repository)" })
      vim.keymap.set(
        "n",
        "<Leader>gC",
        function() snacks.picker.git_log { current_file = true, follow = true } end,
        { desc = "Git commits (current file)" }
      )
      vim.keymap.set("n", "<Leader>gt", function() snacks.picker.git_status() end, { desc = "Git status" })
      vim.keymap.set("n", "<Leader>gT", function() snacks.picker.git_stash() end, { desc = "Git stash" })
      vim.keymap.set("n", "<Leader>gh", function() snacks.picker.git_diff() end, { desc = "Git hunks" })
      vim.keymap.set("n", "<Leader>fg", function() snacks.picker.git_files() end, { desc = "Find git files" })
    end
    -- General Pickers
    vim.keymap.set("n", "<Leader>f<CR>", function() snacks.picker.resume() end, { desc = "Resume previous search" })
    vim.keymap.set("n", "<Leader>f'", function() snacks.picker.marks() end, { desc = "Find marks" })
    vim.keymap.set("n", "<Leader>fl", function()
      local filetypes = {}
      for _, ft in ipairs(vim.fn.getcompletion("", "filetype")) do
        table.insert(filetypes, { text = ft, name = ft })
      end

      require("snacks").picker {
        items = filetypes,
        source = "filetypes",
        layout = {
          layout = {
            backdrop = false,
            row = 1,
            width = 0.4,
            min_width = 30,
            height = 0.9,
            border = "none",
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = "rounded",
              title = "{title} {live} {flags}",
              title_pos = "center",
            },
            { win = "list", border = "rounded" },
          },
        },
        format = function(item)
          local icon, icon_hl = require("snacks.util").icon(item.text, "filetype")
          return {
            { icon .. " ", icon_hl },
            { item.text },
          }
        end,
        confirm = function(picker, item)
          picker:close()
          vim.cmd.set("ft=" .. item.text)
          local icon, _ = require("snacks.util").icon(item.text, "filetype")
          require("snacks").notify(("Set filetype to `%s %s`"):format(icon, item.text), { title = "Snacks Picker" })
        end,
      }
    end, { desc = "Find & Set language (filetype)" })
    vim.keymap.set(
      "n",
      "<Leader>fa",
      function() snacks.picker.files { dirs = { vim.fn.stdpath "config" }, desc = "Config Files" } end,
      { desc = "Find config files" }
    )
    vim.keymap.set("n", "<Leader>fb", function() snacks.picker.buffers() end, { desc = "Find buffers" })
    vim.keymap.set("n", "<Leader>fc", function() snacks.picker.grep_word() end, { desc = "Find word under cursor" })
    vim.keymap.set("n", "<Leader>fC", function() snacks.picker.commands() end, { desc = "Find commands" })
    vim.keymap.set(
      "n",
      "<Leader>ff",
      function()
        snacks.picker.files {
          hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
        }
      end,
      { desc = "Find files" }
    )
    vim.keymap.set(
      "n",
      "<Leader>fF",
      function() snacks.picker.files { hidden = true, ignored = true } end,
      { desc = "Find all files" }
    )
    vim.keymap.set("n", "<Leader>fh", function()
      require("snacks").picker.help {
        confirm = function(picker, item) require("snacks").picker.actions.help(picker, item, { cmd = "vsplit" }) end,
      }
    end, { desc = "Find help" })
    vim.keymap.set("n", "<Leader>fH", function()
      require("snacks").picker.highlights {
        confirm = function(picker, item)
          vim.fn.setreg("+", item.hl_group)
          require("snacks").notify(
            ("Yanked to register `%s`:\n`%s`"):format("+", item.hl_group),
            { title = "Snacks Picker" }
          )
          picker:close()
        end,
      }
    end, { desc = "Find highlight colors" })
    vim.keymap.set("n", "<Leader>fk", function()
      require("snacks").picker.keymaps {
        layout = {
          layout = {
            backdrop = false,
            row = 1,
            width = 0,
            min_width = 30,
            height = 0.9,
            border = "none",
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = "rounded",
              title = "{title} {live} {flags}",
              title_pos = "center",
            },
            { win = "list", height = 0.8, border = "rounded" },
            { win = "preview", height = 0.2, border = "rounded" },
          },
        },
        confirm = function(picker, item)
          picker:close()
          if item.info and item.info.linedefined then
            vim.api.nvim_command("edit +" .. item.info.linedefined .. " " .. item.file)
          elseif item.item and item.item.rhs then
            vim.fn.setreg("+", item.item.rhs)
            require("snacks").notify(
              ("Yanked to register `%s`:\n`%s`"):format("+", item.item.rhs),
              { title = "Snacks Picker" }
            )
          end
        end,
      }
    end, { desc = "Find keymaps" })
    vim.keymap.set("n", "<Leader>fm", function() snacks.picker.man() end, { desc = "Find man" })
    vim.keymap.set("n", "<Leader>fn", function()
      require("snacks").picker.notifications {
        confirm = function(picker, item)
          vim.fn.setreg("+", item.item.msg)
          require("snacks").notify(("Yanked to register `%s`"):format "+", { title = "Snacks Picker" })
          picker:close()
        end,
      }
    end, { desc = "Find notifications" })
    vim.keymap.set(
      "n",
      "<Leader>fi",
      function()
        require("snacks").picker.icons {
          icon_sources = { "nerd_fonts", "emoji" },
          finder = "icons",
          format = "icon",
          layout = {
            layout = {
              backdrop = false,
              row = 1,
              width = 0.4,
              min_width = 30,
              height = 0.9,
              border = "none",
              box = "vertical",
              {
                win = "input",
                height = 1,
                border = "rounded",
                title = "{title} {live} {flags}",
                title_pos = "center",
              },
              { win = "list", border = "rounded" },
            },
          },
          confirm = { "copy", "close" },
        }
      end,
      { desc = "Find icons" }
    )
    vim.keymap.set("n", "<Leader>fI", function()
      local icons = {}
      for kind, icon in pairs(Config.icons.icons) do
        if type(icon) == "string" then table.insert(icons, { text = kind, glyph = icon, cat = "Custom" }) end
      end
      if MiniIcons then
        local function add_cat(categories)
          for _, cat in ipairs(categories) do
            for _, kind in ipairs(MiniIcons.list(cat)) do
              table.insert(icons, { text = kind, cat = cat, is_mini_icon = true })
            end
          end
        end
        add_cat { "directory", "extension", "file", "filetype", "lsp", "os" }
      end

      require("snacks").picker {
        items = icons,
        source = "All Icons",
        layout = {
          layout = {
            backdrop = false,
            row = 1,
            width = 0.4,
            min_width = 30,
            height = 0.9,
            border = "none",
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = "rounded",
              title = "{title} {live} {flags}",
              title_pos = "center",
            },
            { win = "list", border = "rounded" },
          },
        },
        format = function(item)
          local icon, icon_hl
          local text_hl = "SnacksPickerIconName"
          if item.is_mini_icon then
            icon, icon_hl = require("snacks.util").icon(item.text, item.cat)
            text_hl = icon_hl or "SnacksPickerIconName"
          else
            icon, icon_hl = item.glyph, "SnacksPickerIcon"
          end
          local a = require("snacks").picker.util.align
          local ret = {} ---@type snacks.picker.Highlight[]
          ret[#ret + 1] = { a(icon, 2), icon_hl }
          ret[#ret + 1] = { " " }
          ret[#ret + 1] = { a(item.text, 30), text_hl }
          ret[#ret + 1] = { " " }
          ret[#ret + 1] = { a(item.cat, 20), "SnacksPickerIconCategory" }
          return ret
        end,
        -- Paste selected icon to cursor and icon + icon text to clipboard
        confirm = {
          "copy",
          function(picker, item)
            -- Copy icon
            local icon = item.glyph
            if item.is_mini_icon then
              icon, _ = snacks.util.icon(item.text, item.cat)
            end
            vim.fn.setreg("+", icon)
            local buf = item.buf or vim.api.nvim_win_get_buf(picker.main)
            local ft = vim.bo[buf].filetype
            snacks.notify(
              ("Yanked to register `%s`:\n```%s\n%s\n```"):format("+", ft, icon),
              { title = "Snacks Picker" }
            )
          end,
          "close",
        },
      }
    end, { desc = "Find custom icons" })
    vim.keymap.set("n", "<Leader>fo", function()
      require("snacks").picker.smart {
        multi = { "recent" },
        format = "file", -- use `file` format for all sources
        matcher = {
          cwd_bonus = false, -- boost cwd matches
          frecency = true, -- use frecency boosting
          sort_empty = false, -- sort even when the filter is empty
          history_bonus = true,
        },
        transform = "unique_file",
        sort_lastused = true,
      }
    end, { desc = "Find old files" })
    vim.keymap.set(
      "n",
      "<Leader>fO",
      function() snacks.picker.recent { filter = { cwd = true } } end,
      { desc = "Find old files (cwd)" }
    )
    vim.keymap.set("n", "<Leader>fp", function() snacks.picker.projects() end, { desc = "Find projects" })
    vim.keymap.set("n", "<Leader>fr", function() snacks.picker.registers() end, { desc = "Find registers" })
    vim.keymap.set("n", "<Leader>fs", function() snacks.picker.smart() end, { desc = "Find buffers/recent/files" })
    vim.keymap.set("n", "<Leader>ft", function() snacks.picker.colorschemes() end, { desc = "Find themes" })
    vim.keymap.set("n", "<Leader>fu", function() snacks.picker.undo() end, { desc = "Find undo history" })
  end
  -- Grep (requires ripgrep)
  if vim.fn.executable "rg" == 1 then
    vim.keymap.set("n", "<Leader>fw", function() snacks.picker.grep() end, { desc = "Find words" })
    vim.keymap.set(
      "n",
      "<Leader>fW",
      function() snacks.picker.grep { hidden = true, ignored = true } end,
      { desc = "Find words in all files" }
    )
  end

  -- LSP Pickers
  vim.keymap.set("n", "<Leader>lD", function() snacks.picker.diagnostics() end, { desc = "Search diagnostics" })
  vim.keymap.set("n", "<Leader>ls", function()
    local aerial_avail, aerial = pcall(require, "aerial")
    if aerial_avail and aerial.snacks_picker then
      aerial.snacks_picker()
    else
      snacks.picker.lsp_symbols()
    end
  end, { desc = "Search symbols" })

  if vim.tbl_get(opts, "words", "enabled") ~= false then
    vim.keymap.set(
      "n",
      "\\r",
      function() snacks.toggle.words():toggle() end,
      { desc = "Toggle reference highlighting" }
    )
    vim.keymap.set("n", "]r", function() snacks.words.jump(vim.v.count1) end, { desc = "Next reference" })
    vim.keymap.set("n", "[r", function() snacks.words.jump(-vim.v.count1) end, { desc = "Previous reference" })
  end
end)

later(function()
  if not vim.fn.executable "git" == 1 then return end
  add { "https://github.com/lewis6991/gitsigns.nvim" }

  local get_icon = Config.get_custom_icon
  local gitsigns = require "gitsigns"
  local opts = {
    gh = true,
    signs = {
      add = { text = get_icon "GitSign" },
      change = { text = get_icon "GitSign" },
      delete = { text = get_icon "GitSign" },
      topdelete = { text = get_icon "GitSign" },
      changedelete = { text = get_icon "GitSign" },
      untracked = { text = get_icon "GitSign" },
    },
    signs_staged = {
      add = { text = get_icon "GitSign" },
      change = { text = get_icon "GitSign" },
      delete = { text = get_icon "GitSign" },
      topdelete = { text = get_icon "GitSign" },
      changedelete = { text = get_icon "GitSign" },
      untracked = { text = get_icon "GitSign" },
    },
    on_attach = function(bufnr)
      local prefix = "<Leader>g"
      -- Normal Mode Mappings
      vim.keymap.set("n", prefix .. "l", function() gitsigns.blame_line() end, { buf = bufnr, desc = "View Git blame" })
      vim.keymap.set(
        "n",
        prefix .. "L",
        function() gitsigns.blame_line { full = true } end,
        { buf = bufnr, desc = "View full Git blame" }
      )
      vim.keymap.set(
        "n",
        prefix .. "p",
        function() gitsigns.preview_hunk_inline() end,
        { buf = bufnr, desc = "Preview Git hunk" }
      )
      vim.keymap.set("n", prefix .. "r", function() gitsigns.reset_hunk() end, { buf = bufnr, desc = "Reset Git hunk" })
      vim.keymap.set(
        "n",
        prefix .. "R",
        function() gitsigns.reset_buffer() end,
        { buf = bufnr, desc = "Reset Git buffer" }
      )
      vim.keymap.set(
        "n",
        prefix .. "s",
        function() gitsigns.stage_hunk() end,
        { buf = bufnr, desc = "Stage/Unstage Git hunk" }
      )
      vim.keymap.set(
        "n",
        prefix .. "S",
        function() gitsigns.stage_buffer() end,
        { buf = bufnr, desc = "Stage Git buffer" }
      )
      vim.keymap.set("n", prefix .. "d", function() gitsigns.diffthis() end, { buf = bufnr, desc = "View Git diff" })

      -- Visual Mode Mappings (Range specific)
      vim.keymap.set(
        "v",
        prefix .. "r",
        function() gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        { buf = bufnr, desc = "Reset Git hunk" }
      )

      vim.keymap.set(
        "v",
        prefix .. "s",
        function() gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        { buf = bufnr, desc = "Stage Git hunk" }
      )

      -- Navigation Mappings
      vim.keymap.set("n", "[G", function() gitsigns.nav_hunk "first" end, { buf = bufnr, desc = "First Git hunk" })
      vim.keymap.set("n", "]G", function() gitsigns.nav_hunk "last" end, { buf = bufnr, desc = "Last Git hunk" })
      vim.keymap.set("n", "]g", function() gitsigns.nav_hunk "next" end, { buf = bufnr, desc = "Next Git hunk" })
      vim.keymap.set("n", "[g", function() gitsigns.nav_hunk "prev" end, { buf = bufnr, desc = "Previous Git hunk" })

      vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { buf = bufnr, desc = "inside Git hunk" })
    end,
    worktrees = nil,
  }
  gitsigns.setup(opts)
end)

later(function()
  add { "https://github.com/mikavilpas/yazi.nvim", "https://github.com/folke/snacks.nvim" }
  require("yazi").setup {
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-s>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-f>",
      replace_in_directory = "<c-g>",
      cycle_open_buffers = "<C-l>",
      copy_relative_path_to_selected_files = "<c-y>",
      send_to_quickfix_list = "<c-q>",
      change_working_directory = "<c-\\>",
    },
    floating_window_scaling_factor = 0.7,
    -- open visible splits as yazi tabs for easy navigation. Requires a yazi
    -- version more recent than 2024-08-11
    -- https://github.com/mikavilpas/yazi.nvim/pull/359
    open_multiple_tabs = true,
    -- use_ya_for_events_reading = true,
    highlight_groups = {
      -- See https://github.com/mikavilpas/yazi.nvim/pull/180
      hovered_buffer = { link = "CursorLine" },
      -- See https://github.com/mikavilpas/yazi.nvim/pull/351
      hovered_buffer_in_same_directory = nil,
    },
  }
  vim.keymap.set({ "n" }, "<Leader>y", "<cmd>Yazi<cr>", { desc = "Open yazi " })
end)

later(function()
  Config.on_packchanged("VectorCode", { "install", "update" }, function()
    if vim.fn.executable "uv" ~= 1 then
      return vim.notify("The VectorCode pack requires uv installed", vim.log.levels.DEBUG)
    end
    vim
      .system({ "uv", "tool", "install", "vectorcode[lsp,mcp]" }, { text = true }, function(obj)
        if obj.code == 0 then
          vim.notify("Installed successfully: vectorcode\n" .. obj.stdout)
        else
          vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
        end
      end)
      :wait()
    vim
      .system({ "uv", "tool", "upgrade", "vectorcode[lsp,mcp]" }, { text = true }, function(obj)
        if obj.code == 0 then
          vim.notify("Updated successfully: vectorcode\n" .. obj.stdout)
        else
          vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
        end
      end)
      :wait()
  end, "VectorCode install/update")

  add {
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/ravitemer/codecompanion-history.nvim",
    "https://github.com/franco-ruggeri/codecompanion-spinner.nvim",
    "https://github.com/Davidyz/VectorCode",
    "https://github.com/olimorris/codecompanion.nvim",
  }
  require("codecompanion").setup {
    extensions = {
      history = {
        enabled = true,
        opts = {
          -- Keymap to open history from chat buffer (default: gh)
          keymap = "gh",
          -- Keymap to save the current chat manually (when auto_save is disabled)
          save_chat_keymap = "sc",
          -- Save all chats by default (disable to save only manually using 'sc')
          auto_save = true,
          -- Number of days after which chats are automatically deleted (0 to disable)
          expiration_days = 0,
          -- Picker interface (auto resolved to a valid picker)
          picker = "default", --- ("telescope", "snacks", "fzf-lua", or "default")
          ---Optional filter function to control which chats are shown when browsing
          chat_filter = nil, -- function(chat_data) return boolean end
          -- Customize picker keymaps (optional)
          -- picker_keymaps = {
          --   rename = { n = "r", i = "<M-r>" },
          --   delete = { n = "d", i = "<M-d>" },
          --   duplicate = { n = "<C-y>", i = "<C-y>" },
          -- },

          auto_generate_title = true,
          ---On exiting and entering neovim, loads the last chat on opening chat
          continue_last_chat = false,
          ---When chat is cleared with `gx` delete the chat from history
          delete_on_clearing_chat = false,
          ---Directory path to save the chats
          dir_to_save = vim.fn.stdpath "data" .. "/codecompanion-history",
          title_generation_opts = {
            adapter = "nvidia",
            model = "qwen/qwen3.5-397b-a17b",
          },

          -- Summary system
          summary = {
            -- Keymap to generate summary for current chat (default: "gcs")
            create_summary_keymap = "gcs",
            -- Keymap to browse summaries (default: "gbs")
            browse_summaries_keymap = "gbs",

            generation_opts = {
              adapter = "nvidia",
              model = "qwen/qwen3.5-397b-a17b",
              context_size = 260000, -- max tokens that the model supports
              include_references = true, -- include slash command content
              include_tool_outputs = true, -- include tool execution results
              -- system_prompt = nil, -- custom system prompt (string or function)
              -- format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
            },
          },

          -- Memory system (requires VectorCode CLI)
          memory = {
            -- Automatically index summaries when they are generated
            auto_create_memories_on_summary_generation = true,
            -- Path to the VectorCode executable
            vectorcode_exe = "vectorcode",
            -- Tool configuration
            tool_opts = {
              -- Default number of memories to retrieve
              default_num = 10,
            },
            -- Enable notifications for indexing progress
            notify = false,
            -- Index all existing memories on startup
            -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
            index_on_startup = true,
          },
        },
      },
      spinner = {},
      vectorcode = vim.fn.executable "vectorcode" == 1 and {
        opts = {
          -- prompt_library = {
          -- },
          tool_group = {
            -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
            enabled = true,
            -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
            -- if you use @vectorcode_vectorise, it'll be very handy to include
            -- `file_search` here.
            extras = {},
            collapse = false, -- whether the individual tools should be shown in the chat
          },
          tool_opts = {
            ls = {},
            vectorise = {},
            query = {
              max_num = { chunk = -1, document = -1 },
              default_num = { chunk = 50, document = 10 },
              include_stderr = false,
              use_lsp = false,
              no_duplicate = true,
              chunk_mode = false,
              summarise = {
                enabled = false,
                -- adapter = "gemini_cli",
                query_augmented = true,
              },
            },
          },
          on_setup = {
            update = true, -- set to true to enable update when `setup` is called.
            -- lsp = false,
          },
        },
      },
    },
    language = "English",
    adapters = {
      acp = {
        gemini_cli = function()
          return require("codecompanion.adapters").extend("gemini_cli", {
            defaults = {
              auth_method = "oauth-personal",
              -- mcpServers = mcpServers,
              timeout = 20000, -- 20 seconds
            },
            env = {
              GEMINI_API_KEY = (function()
                if vim.env.GEMINI_API_KEY then return "GEMINI_API_KEY" end
                if vim.fn.executable "pass" == 1 then
                  local encrypted_file = vim.fn.expand "~/.password-store/llm/GEMINI_API_KEY.gpg"
                  if vim.fn.filereadable(encrypted_file) == 1 then return "cmd: pass llm/GEMINI_API_KEY" end
                end
                return "GEMINI_API_KEY"
              end)(),
            },
          })
        end,
      },
      http = {
        nvidia = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "nvidia",
            formatted_name = "Nvidia",
            roles = {
              llm = "assistant",
              user = "user",
              tool = "tool",
            },
            env = {
              url = "https://integrate.api.nvidia.com",
              api_key = (function()
                if vim.env.NVIDIA_API_KEY then return "NVIDIA_API_KEY" end
                if vim.fn.executable "pass" == 1 then
                  local encrypted_file = vim.fn.expand "~/.password-store/llm/NVIDIA_API_KEY.gpg"
                  if vim.fn.filereadable(encrypted_file) == 1 then return "cmd: pass llm/NVIDIA_API_KEY" end
                end
                return "NVIDIA_API_KEY"
              end)(),
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            schema = {
              model = {
                default = "qwen/qwen3.5-397b-a17b",
              },
              temperature = {
                order = 2,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0.6,
                validate = function(n) return n >= 0 and n <= 1, "Must be between 0 and 1" end,
              },
              top_p = {
                order = 3,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0.95,
                validate = function(n) return n >= 0 and n <= 1, "Must be between 0 and 1" end,
              },
              top_k = {
                order = 4,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 20,
              },
              presence_penalty = {
                order = 5,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0,
                validate = function(n) return n >= 0 and n <= 2, "Must be between 0 and 2" end,
              },
              repetition_penalty = {
                order = 6,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 1,
                validate = function(n) return n >= -2 and n <= 2, "Must be between -2 and 2" end,
              },
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            schema = {
              model = {
                default = "gemini-3-pro-preview",
              },
            },
          })
        end,
      },
    },
    interactions = {
      chat = {
        adapter = "nvidia",
        auto_scroll = false,
        icons = {
          chat_context = "📎️",
        },
        fold_context = true,
        variables = {
          ["buffer"] = {
            opts = {
              -- Always sync the buffer by sharing its "diff"
              -- Or choose "all" to share the entire buffer
              default_params = "diff",
            },
          },
        },
        default_rules = "default",
      },
      inline = {
        adapter = "nvidia",
        default_rules = "default",
      },
      cmd = {
        adapter = "nvidia",
      },
    },
    display = {
      chat = {
        intro_message = "Welcome to CodeCompanion ✨!\n Press ? for options",
        separator = "─", -- The separator between the different messages in the chat buffer
        show_context = true, -- Show context (from slash commands and variables) in the chat buffer?
        show_header_separator = true, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
        show_settings = false, -- Show LLM settings at the top of the chat buffer?
        show_token_count = true, -- Show the token count for each response?
        show_tools_processing = true, -- Show the loading message when tools are being executed?
        start_in_insert_mode = false, -- Open the chat buffer in insert mode?
      },
    },
  }
  local prefix = "<Leader>A" -- or whatever your prefix variable is set to

  if wk then
    wk.add {
      { prefix, group = Config.get_custom_icon("CodeCompanion", 1, true) .. "CodeCompanion", mode = { "n", "v" } },
    }
  end

  -- Normal Mode Mappings
  vim.keymap.set("n", prefix .. "h", "<cmd>CodeCompanionHistory<cr>", { desc = "Open history" })
  vim.keymap.set("n", prefix .. "c", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle chat" })
  vim.keymap.set("n", prefix .. "p", "<cmd>CodeCompanionActions<cr>", { desc = "Open action palette" })
  vim.keymap.set("n", prefix .. "q", "<cmd>CodeCompanion<cr>", { desc = "Open inline assistant" })

  -- Visual Mode Mappings
  vim.keymap.set("v", prefix .. "s", "<cmd>CodeCompanionSummaries<cr>", { desc = "Browse summaries" })
  vim.keymap.set("v", prefix .. "a", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to chat" })
  vim.keymap.set("v", prefix .. "c", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle chat" })
  vim.keymap.set("v", prefix .. "p", "<cmd>CodeCompanionActions<cr>", { desc = "Open action palette" })
  vim.keymap.set("v", prefix .. "q", "<cmd>CodeCompanion<cr>", { desc = "Open inline assistant" })
end)

later(function()
  add {
    "https://github.com/yarospace/dev-tools.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/ThePrimeagen/refactoring.nvim",
  }
  require("refactoring").setup()
  require("dev-tools").setup {
    -- Custom actions: https://github.com/yarospace/dev-tools.nvim?tab=readme-ov-file#adding-code-actions
    actions = {},

    filetypes = { -- filetypes for which to attach the LSP
      include = {}, -- {} to include all, except for special buftypes, e.g. nofile|help|terminal|prompt
      exclude = {},
    },

    builtin_actions = {
      include = {}, -- filetype/group/name of actions to include or {} to include all
      exclude = {
        "Debugging",
        "Specs",
        "Convert JSON->Lua table",
        "Extract variable",
        "Extract function",
      }, -- filetype/group/name of actions to exclude or "true" to exclude all
    },

    action_opts = { -- override default options for actions
      {
        group = "Debugging",
        name = "Log vars under cursor",
        opts = {
          logger = nil, ---@type function to log debug info, default dev-tools.log
          keymap = nil, ---@type Keymap action keymap spec, e.g.
        },
      },
    },

    ui = {
      -- Use lspsaga code action
      override = false, -- override vim.ui.select, requires `snacks.nvim` to be included in dependencies or installed separately
    },

    debug = false, -- extra debug info
    cache = true, -- cache the actions on start
  }
end)

later(function()
  local is_dev_tools_available
  local is_ef_available = vim.fn.executable "dotnet-ef" == 1

  Config.on_packchanged("easy-dotnet.nvim", { "install", "update" }, function()
    if not vim.fn.executable "dotnet" then error "Easy-dotnet requires dotnet installed" end
    if not is_ef_available then
      vim
        .system({ "dotnet", "tool", "install", "-g", "dotnet-ef" }, { text = true }, function(obj)
          vim.schedule(function()
            if obj.code == 0 then
              vim.notify "Installed successfully: dotnet entity framework"
              is_ef_available = true
            else
              vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
            end
          end)
        end)
        :wait()
    else
      vim
        .system({ "dotnet", "tool", "update", "-g", "dotnet-ef" }, { text = true }, function(obj)
          vim.schedule(function()
            if obj.code == 0 then
              vim.notify "Updated successfully: dotnet entity framework"
            else
              vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
            end
          end)
        end)
        :wait()
    end
    if vim.fn.executable "dotnet-easydotnet" ~= 1 then
      vim
        .system({ "dotnet", "tool", "install", "-g", "EasyDotnet" }, { text = true }, function(obj)
          vim.schedule(function()
            if obj.code == 0 then
              vim.notify "Installed successfully: EasyDotnet"
              is_ef_available = true
            else
              vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
            end
          end)
        end)
        :wait()
    else
      vim
        .system({ "dotnet", "tool", "update", "-g", "EasyDotnet" }, { text = true }, function(obj)
          vim.schedule(function()
            if obj.code == 0 then
              vim.notify "Updated successfully: EasyDotnet"
            else
              vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
            end
          end)
        end)
        :wait()
    end
  end, "Easy-dotnet install/update")

  add {
    "https://github.com/GustavEikaas/easy-dotnet.nvim",
    "https://github.com/seblyng/roslyn.nvim",
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "1.x" },
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/mfussenegger/nvim-dap",
  }

  require("roslyn").setup {
    silent = true,
  }
  require("easy-dotnet").setup {
    managed_terminal = {
      auto_hide = true, -- auto hides terminal if exit code is 0
      auto_hide_delay = 1000, -- delay before auto hiding, 0 = instant
    },
    -- Optional configuration for external terminals (matches nvim-dap structure)
    external_terminal = nil,
    lsp = {
      enabled = (function() return not vim.pack.is_available "roslyn" end)(), -- Enable builtin roslyn lsp
      preload_roslyn = true, -- Start loading roslyn before any buffer is opened
      roslynator_enabled = true, -- Automatically enable roslynator analyzer
      easy_dotnet_analyzer_enabled = true, -- Enable roslyn analyzer from easy-dotnet-server
      auto_refresh_codelens = true,
      analyzer_assemblies = {}, -- Any additional roslyn analyzers you might use like SonarAnalyzer.CSharp
      config = {},
    },
    debugger = {
      -- Path to custom coreclr DAP adapter
      -- easy-dotnet-server falls back to its own netcoredbg binary if bin_path is nil
      bin_path = vim.fn.executable "netcoredbg" == 1 and vim.fn.exepath "netcoredbg",
      console = "integratedTerminal", -- Controls where the target app runs: "integratedTerminal" (Neovim buffer) or "externalTerminal" (OS window)
      apply_value_converters = true,
      auto_register_dap = true,
      mappings = {
        open_variable_viewer = { lhs = "T", desc = "open variable viewer" },
      },
    },
    ---@type TestRunnerOptions
    test_runner = {
      auto_start_testrunner = false,
      mappings = {
        run_test_from_buffer = { lhs = "<leader>Tc", desc = "Run test under cursor" },
        get_build_errors = { lhs = "<leader>e", desc = "get build errors" },
        peek_stack_trace_from_buffer = { lhs = "<leader>TT", desc = "peek stack trace from buffer" },
        debug_test_from_buffer = { lhs = "<leader>d", desc = "run test from buffer" },
        debug_test = { lhs = "<leader>Td", desc = "debug test" },
        go_to_file = { lhs = "g", desc = "go to file" },
        run_all = { lhs = "<leader>R", desc = "run all tests" },
        run = { lhs = "<leader>r", desc = "run test" },
        peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
        expand = { lhs = "o", desc = "expand" },
        expand_node = { lhs = "E", desc = "expand node" },
        collapse_all = { lhs = "W", desc = "collapse all" },
        close = { lhs = "q", desc = "close testrunner" },
        refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
        cancel = { lhs = "<C-c>", desc = "cancel in-flight operation" },
      },
    },
    ---@param action "test" | "restore" | "build" | "run"
    terminal = function(path, action, args)
      args = args or ""
      local commands = {
        run = function() return string.format("dotnet run --project %s %s", path, args) end,
        test = function() return string.format("dotnet test %s %s", path, args) end,
        restore = function() return string.format("dotnet restore %s %s", path, args) end,
        build = function() return string.format("dotnet build %s %s", path, args) end,
        watch = function() return string.format("dotnet watch --project %s %s", path, args) end,
      }
      local command = commands[action]()
      if require("easy-dotnet.extensions").isWindows() == true then command = command .. "\r" end
      if vim.pack.is_available "toggleterm" and _G.toggleterm then
        _G.toggleterm.toggle_term_cmd { cmd = command, direction = "float" }
        return
      end
      vim.cmd "vsplit"
      vim.cmd("term " .. command)
    end,
    -- Disable mappings for csproj and fsproj, when use dev-tools custom actions instead
    csproj_mappings = (function()
      if is_dev_tools_available ~= nil then return not is_dev_tools_available end
      is_dev_tools_available = vim.pack.is_available "dev-tools"
      return not is_dev_tools_available
    end)(),
    fsproj_mappings = (function()
      if is_dev_tools_available ~= nil then return not is_dev_tools_available end
      is_dev_tools_available = vim.pack.is_available "dev-tools"
      return not is_dev_tools_available
    end)(),
    auto_bootstrap_namespace = {
      --block_scoped, file_scoped
      type = "block_scoped",
      enabled = true,
      use_clipboard_json = {
        behavior = "prompt", --'auto' | 'prompt' | 'never',
        register = "+", -- which register to check
      },
    },
    -- choose which picker to use with the plugin
    -- possible values are "telescope" | "fzf" | "snacks" | "basic"
    -- if no picker is specified, the plugin will determine
    -- the available one automatically with this priority:
    -- telescope -> fzf -> snacks ->  basic
    picker = vim.pack.is_available "telescope" and "telescope"
      or vim.pack.is_available "fzf-lua" and "fzf"
      or vim.pack.is_available "snacks" and "snacks"
      or "basic",
  }
  local prefix = "<leader>le"
  if MiniFiles then
    Config.new_autocmd("User", "MiniFilesBufferCreate", function(args)
      local buf_id = args.data.buf_id
      vim.keymap.set("n", prefix .. "n", function()
        local fs_entry = MiniFiles.get_fs_entry(buf_id)
        if fs_entry == nil then return vim.notify "Cursor not on valid entry" end
        local path = vim.fs.dirname(fs_entry.path)

        MiniFiles.close()
        require("easy-dotnet").create_new_item(path, function() MiniFiles.open(path) end)
      end, { buffer = buf_id, desc = "Create file via .NET" })
    end, "Create file via .NET in minifiles")
  end

  local blink_avail, blink = pcall(require, "blink.cmp")
  if blink_avail then
    blink.add_filetype_source("msbuild", "easy-dotnet")
    blink.add_source_provider("easy-dotnet", {
      name = "easy-dotnet",
      enabled = true,
      module = "easy-dotnet.completion.blink",
      score_offset = 10000,
      async = true,
    })
  end

  if wk and MiniIcons then
    wk.add {
      { prefix, group = MiniIcons.get_icon("filetype", "cs") .. " Dotnet", mode = { "n" } },
    }
  end

  Config.new_autocmd("BufReadPost", "*.fsproj", function(args)
    local bufnr = args.buf
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    ---@type vim.keymap.set.Opts
    local key_opts = { buffer = bufnr, silent = true }
    -- Entity framework
    vim.keymap.set("n", prefix .. "r", function()
      local easy_dotnet_proj = require "easy-dotnet.fsproj-mappings"
      coroutine.wrap(function() easy_dotnet_proj.add_project_reference(bufname) end)()
    end, vim.tbl_extend("force", key_opts, { desc = "Add project reference" }))
  end, ".NET mappings fsproj")

  Config.new_autocmd("BufReadPost", "*.csproj", function(args)
    local bufnr = args.buf
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    ---@type vim.keymap.set.Opts
    local key_opts = { buffer = bufnr, silent = true }
    -- Entity framework
    vim.keymap.set("n", prefix .. "r", function()
      local easy_dotnet_proj = require "easy-dotnet.csproj-mappings"
      coroutine.wrap(function() easy_dotnet_proj.add_project_reference(bufname) end)()
    end, vim.tbl_extend("force", key_opts, { desc = "Add project reference" }))
  end, ".NET mappings csproj")

  Config.new_autocmd("LspAttach", nil, function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Only apply if the server is Roslyn
    if client and (client.name == "roslyn" or client.name == "easy_dotnet") then
      local bufnr = args.buf
      -- local bufname = vim.api.nvim_buf_get_name(bufnr)
      ---@type vim.keymap.set.Opts
      local key_opts = { buffer = bufnr, silent = true }

      -- Add Package
      vim.keymap.set(
        "n",
        prefix .. "a",
        "<cmd>Dotnet add package<cr>",
        vim.tbl_extend("force", key_opts, { desc = "Nuget packages (add)" })
      )

      -- Remove Package
      vim.keymap.set(
        "n",
        prefix .. "r",
        "<cmd>Dotnet remove package<cr>",
        vim.tbl_extend("force", key_opts, { desc = "Nuget packages (remove)" })
      )

      -- Secrets
      vim.keymap.set(
        "n",
        prefix .. "s",
        "<cmd>Dotnet secrets<cr>",
        vim.tbl_extend("force", key_opts, { desc = "Dotnet secrets" })
      )

      if is_ef_available then
        -- Entity framework
        vim.keymap.set(
          "n",
          prefix .. "d",
          function() vim.api.nvim_feedkeys(":Dotnet ef database ", "nit", true) end,
          vim.tbl_extend("force", key_opts, { desc = "Entity Framework database" })
        )
        vim.keymap.set(
          "n",
          prefix .. "m",
          function() vim.api.nvim_feedkeys(":Dotnet ef migrations ", "nit", true) end,
          vim.tbl_extend("force", key_opts, { desc = "Entity Framework migration" })
        )
      end
    end
  end, ".NET mappings csproj")
end)
