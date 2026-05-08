---@diagnostic disable: duplicate-set-field
-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘
--
-- This file contains configuration of the MINI parts of the config.
-- It contains only configs for the 'mini.nvim' plugin (installed in 'init.lua').
--
-- 'mini.nvim' is a library of modules. Each is enabled independently via
-- `require('mini.xxx').setup()` convention. It creates all intended side effects:
-- mappings, autocommands, highlight groups, etc. It also creates a global
-- `MiniXxx` table that can be later used to access module's features.
--
-- Every module's `setup()` function accepts an optional `config` table to
-- adjust its behavior. See the structure of this table at `:h MiniXxx.config`.
--
-- See `:h mini.nvim-general-principles` for more general principles.
--
-- Here each module's `setup()` has a brief explanation of what the module is for,
-- its usage examples (uses Leader mappings from 'plugin/20_keymaps.lua'), and
-- possible directions for more info.
-- For more info about a module see its help page (`:h mini.xxx` for 'mini.xxx').

-- To minimize the time until first screen draw, modules are enabled in two steps:
-- - Step one enables everything that is needed for first draw with `now()`.
--   Sometimes needed only if Neovim is started as `nvim -- path/to/file`.
-- - Everything else is delayed until the first draw with `later()`.
---@diagnostic disable-next-line: unused-local

-- Step one ===================================================================
-- Enable 'miniwinter' color scheme. It comes with 'mini.nvim' and uses 'mini.hues'.
--
-- See also:
-- - `:h mini.nvim-color-schemes` - list of other color schemes
-- - `:h MiniHues-examples` - how to define highlighting with 'mini.hues'
-- - 'plugin/40_plugins.lua' honorable mentions - other good color schemes
-- now(function() vim.cmd 'colorscheme miniwinter' end)
now(function()
  require("mini.base16").setup {
    palette = {
      -- UI / Backgrounds
      base00 = "#080A0E", -- base (background)
      base01 = "#080A0E", -- tool / float / prompt
      base02 = "#26343F", -- inactive_base, tab, status bg, visual selection
      base03 = "#3A3E47", -- split / subtle fg, inactive line number
      base04 = "#ADB0BB", -- active line number
      base05 = "#BCC4C9", -- main text
      base06 = "#3A3E47", -- dimmed fg for mini jump2d
      base07 = "#FFFFFF", -- brightest fg (fallback)
      -- Syntax
      base08 = "#e55561", -- Red (Variables, XML tags)
      base09 = "#cc9057", -- Orange (Integers, Booleans)
      base0A = "#e2b86b", -- Yellow (Classes)
      base0B = "#8ebd6b", -- Green (Strings)
      base0C = "#48b0bd", -- Cyan (Regex, Escape chars)
      base0D = "#4fa6ed", -- Blue (Functions, Methods)
      base0E = "#bf68d9", -- Purple (Keywords)
      base0F = "#61afef", -- Accent (Deprecated, HTML tags)
    },
    use_cterm = true,
    plugins = {
      default = true,
      ["nvim-mini/mini.nvim"] = true,
    },
  }
  Config.extend_hl("Comment", { italic = true })
  Config.extend_hl("StatusLine", { bg = "NONE" })
  Config.extend_hl("WinSeparator", { bg = "#080A0E", fg = "#BCC4C9" })
  Config.extend_hl("FloatBorder", { bg = "#080A0E", fg = "#BCC4C9" })
  Config.extend_hl("Folded", { bg = "#282C34", fg = "#BCC4C9" })
  Config.extend_hl("Search", { fg = "#111317", bg = "#4fa6ed" })
  Config.extend_hl("CurSearch", { fg = "#111317", bg = "#5C88B0" })
  vim.api.nvim_set_hl(0, "IncSearch", { link = "Search" })
  -- vim.api.nvim_set_hl(0, 'CurSearch', { link = 'Search' })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1E222A" })
  vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#1E222A" })
  vim.api.nvim_set_hl(0, "NonText", { fg = "#3A3E47" })
  vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine" })
  vim.api.nvim_set_hl(0, "WinBar", { fg = "#797D87" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "#080A0E", fg = "#BCC4C9" })
end)

-- You can try these other 'mini.hues'-based color schemes (uncomment with `gcc`):
-- now(function() vim.cmd('colorscheme minispring') end)
-- now(function() vim.cmd('colorscheme minisummer') end)
-- now(function() vim.cmd('colorscheme miniautumn') end)
-- now(function() vim.cmd('colorscheme randomhue') end)

-- Common configuration presets. Example usage:
-- - `<C-s>` in Insert mode - save and go to Normal mode
-- - `go` / `gO` - insert empty line before/after in Normal mode
-- - `gy` / `gp` - copy / paste from system clipboard
-- - `\` + key - toggle common options. Like `\h` toggles highlighting search.
-- - `<C-hjkl>` (four combos) - navigate between windows.
-- - `<M-hjkl>` in Insert/Command mode - navigate in that mode.
--
-- See also:
-- - `:h MiniBasics.config.options` - list of adjusted options
-- - `:h MiniBasics.config.mappings` - list of created mappings
-- - `:h MiniBasics.config.autocommands` - list of created autocommands
now(function()
  require("mini.basics").setup {
    -- Manage options in 'plugin/10_options.lua' for didactic purposes
    options = { basic = false },
    mappings = {
      -- Create `<C-hjkl>` mappings for window navigation
      windows = true,
      -- Create `<M-hjkl>` mappings for navigation in Insert and Command modes
      move_with_alt = true,
      -- Disable
      option_toggle_prefix = "",
    },
  }
end)

-- Icon provider. Usually no need to use manually. It is used by plugins like
-- 'mini.pick', 'mini.files', 'mini.statusline', and others.
now(function()
  -- Set up to not prefer extension-based icon for some extensions
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  require("mini.icons").setup {
    use_file_extension = function(ext, _) return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)]) end,
    style = vim.g.icons_enabled and "glyph" or "ascii",
    filetype = {
      cs = { glyph = "", hl = "MiniIconsGreen" },
      postcss = { glyph = "󰌜", hl = "MiniIconsOrange" },
    },
    file = {
      [".nvmrc"] = { glyph = "", hl = "MiniIconsGreen" },
      [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
      ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
      ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
      ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
      ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },

      [".eslintignore"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      [".eslintrc"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      [".eslintrc.cjs"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      [".eslintrc.json"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      [".eslintrc.yaml"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      [".eslintrc.yml"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      ["eslint.config.cjs"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      ["eslint.config.cts"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      ["eslint.config.mjs"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      ["eslint.config.mts"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
      ["eslint.config.ts"] = { glyph = "󰱺", hl = "MiniIconsYellow" },

      [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.cjs"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.cts"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.js"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.json"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.json5"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.mjs"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.mts"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.toml"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.ts"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.yaml"] = { glyph = "", hl = "MiniIconsPurple" },
      [".prettierrc.yml"] = { glyph = "", hl = "MiniIconsPurple" },
      ["prettier.config.cjs"] = { glyph = "", hl = "MiniIconsPurple" },
      ["prettier.config.js"] = { glyph = "", hl = "MiniIconsPurple" },
      ["prettier.config.mjs"] = { glyph = "", hl = "MiniIconsPurple" },
      ["prettier.config.mts"] = { glyph = "", hl = "MiniIconsPurple" },
      ["prettier.config.ts"] = { glyph = "", hl = "MiniIconsPurple" },
    },
    extension = {
      csproj = { glyph = "", hl = "MiniIconsBlue" },
    },
    -- VSCode-like icons
    lsp = {
      array = { glyph = "" },
      boolean = { glyph = "" },
      key = { glyph = "" },
      namespace = { glyph = "" },
      null = { glyph = "" },
      number = { glyph = "" },
      object = { glyph = "" },
      package = { glyph = "" },
      string = { glyph = "" },
      class = { glyph = "" },
      color = { glyph = "" },
      constant = { glyph = "" },
      constructor = { glyph = "" },
      enum = { glyph = "" },
      enummember = { glyph = "" },
      event = { glyph = "" },
      field = { glyph = "" },
      file = { glyph = "" },
      folder = { glyph = "" },
      ["function"] = { glyph = "" },
      interface = { glyph = "" },
      keyword = { glyph = "" },
      method = { glyph = "" },
      module = { glyph = "" },
      operator = { glyph = "" },
      property = { glyph = "" },
      reference = { glyph = "" },
      snippet = { glyph = "" },
      struct = { glyph = "" },
      text = { glyph = "" },
      typeparameter = { glyph = "" },
      unit = { glyph = "" },
      value = { glyph = "" },
      variable = { glyph = "" },
    },
  }

  function MiniIcons.get_icon(category, kind)
    if not category then category = "default" end
    return MiniIcons.get(category, kind)
  end

  -- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
  -- Not needed for 'mini.nvim' or MiniMax, but might be useful for others.
  later(MiniIcons.mock_nvim_web_devicons)
end)

-- Session management. A thin wrapper around `:h mksession` that consistently
-- manages session files. Example usage:
-- - `<Leader>sn` - start new session
-- - `<Leader>sr` - read previously started session
-- - `<Leader>sd` - delete previously started session
local global_session_name = "latest"
now(function()
  require("mini.sessions").setup {
    -- Whether to read default session if Neovim opened without file arguments
    autoread = false,

    -- Whether to write currently read session before leaving it
    autowrite = true,

    -- Directory where global sessions are stored (use `''` to disable)
    directory = vim.fs.joinpath(vim.fn.stdpath "data", "session"), --<"session" subdir of user data directory from |stdpath()|>,

    -- File for local session (use `''` to disable)
    file = "Session.vim",

    -- Whether to force possibly harmful actions (meaning depends on function)
    force = { read = false, write = true, delete = true },

    -- Hook functions for actions. Default `nil` means 'do nothing'.
    -- Takes table with active session data as argument.
    hooks = {
      -- Before successful action
      -- pre = { read = nil, write = nil, delete = nil },
      -- After successful action
      -- post = { read = nil, write = nil, delete = nil },
      -- Before saving a session
      pre = {
        write = function()
          -- Terminate and close all dap
          if vim.pack.is_available "nvim-dap" then
            require("dap").terminate { all = true }
            require("dap").close()
          end
          if vim.pack.is_available "nvim-dap-ui" then require("dapui").close() end
          -- Terminate and close all toggleterm buffers
          if vim.pack.is_available "toggleterm.nvim" then
            local terminal_list = require("toggleterm.terminal").get_all()
            for _, term in ipairs(terminal_list) do
              term:shutdown() -- Kills the process and closes the buffer
            end
          end

          -- Close all unlisted buffers
          local bufs = vim.api.nvim_list_bufs()
          for _, bufnr in ipairs(bufs) do
            if vim.api.nvim_buf_is_valid(bufnr) and not vim.bo[bufnr].buflisted then
              -- Exclude terminals to prevent breaking plugins like ToggleTerm
              if
                not vim.tbl_contains({ "terminal" }, vim.bo[bufnr].buftype)
                and not vim.tbl_contains({ "help" }, vim.bo[bufnr].filetype)
              then
                vim.api.nvim_buf_delete(bufnr, { force = true })
              end
            end
          end
        end,
        read = function() end,
      },
      -- After reading a session
      post = {
        read = function() end,
      },
    },

    -- Whether to print session path after action
    verbose = { read = false, write = false, delete = true },
  }
end)

-- Auto save local and global sessions before leaving
later(function()
  Config.new_autocmd("BufEnter", nil, function(args)
    local bufnr = args.buf

    if vim.bo[bufnr].buflisted then
      vim.g.allow_save_global_session = true
      vim.api.nvim_del_autocmd(args.id)
    end
  end, "Allow to save global session only after opened a buffer")

  Config.new_autocmd("VimLeavePre", nil, function()
    local global_session_path = vim.fs.joinpath(MiniSessions.config.directory, global_session_name)
    -- Save local session first
    if
      vim.v.this_session ~= nil
      and vim.v.this_session ~= ""
      and vim.v.this_session ~= global_session_path
      and MiniSessions
    then
      MiniSessions.write(vim.v.this_session, { force = true })
    end
    -- This saves to your global directory with the name 'latest'
    if vim.g.allow_save_global_session then MiniSessions.write(global_session_name, { force = true }) end
  end, "Auto save global session before leaving")
end)

-- Start screen. This is what is shown when you open Neovim like `nvim`.
-- Example usage:
-- - Type prefix keys to limit available candidates
-- - Navigate down/up with `<C-n>` and `<C-p>`
-- - Press `<CR>` to select an entry
--
-- See also:
-- - `:h MiniStarter-example-config` - non-default config examples
-- - `:h MiniStarter-lifecycle` - how to work with Starter buffer
now(function()
  local MiniStarter = require "mini.starter"
  MiniStarter.setup {
    -- Whether to open Starter buffer on VimEnter. Not opened if Neovim was
    -- started with intent to show something else.
    autoopen = true,

    evaluate_single = true,
    -- funny cowsay
    header = function()
      if vim.g.cowsay ~= nil then return vim.g.cowsay end
      local cmd = "fortune -s | cowsay"
      if vim.fn.executable "cowsay" == 0 and vim.fn.executable "fortune" == 0 then
        vim.g.cowsay = ""
        return vim.g.cowsay
      end
      if vim.fn.executable "cowsay" == 0 then cmd = "fortune -s" end
      vim.g.cowsay = vim.fn.system(cmd)
      return vim.g.cowsay
    end,

    items = {
      {
        { name = "New buffer", action = "enew", section = "Actions" },
        { name = "Recents", action = "lua require('snacks').picker.recent()", section = "Actions" },
        -- { name = 'Files', action = 'lua require("snacks").picker.files()', section = 'Actions' },
        { name = "Projects", action = 'lua require("snacks").picker.projects()', section = "Actions" },
        { name = "Quit Neovim", action = "qall", section = "Actions" },
      },
      -- Modified MiniStarter.sections.sessions to always showing "latest" session
      function()
        -- Number of session items. Default: 5.
        local n = 5
        -- Whether to show recent sessions (instead of alphabetically by name). Default: true.
        local recent = true

        if _G.MiniSessions == nil then
          return { { name = [['mini.sessions' is not set up]], action = "", section = "Sessions" } }
        end

        local items = {}
        for session_name, session in pairs(_G.MiniSessions.detected) do
          if session_name ~= global_session_name then
            table.insert(items, {
              _session = session,
              name = ("%s%s"):format(session_name, session.type == "local" and " (local)" or ""),
              action = ([[lua _G.MiniSessions.read('%s')]]):format(session_name),
              section = "Sessions",
            })
          end
        end

        local sort_fun
        if recent then
          sort_fun = function(a, b)
            local a_time = a._session.type == "local" and math.huge or a._session.modify_time
            local b_time = b._session.type == "local" and math.huge or b._session.modify_time
            return a_time > b_time
          end
        else
          sort_fun = function(a, b)
            local a_name = a._session.type == "local" and "" or a.name
            local b_name = b._session.type == "local" and "" or b.name
            return a_name < b_name
          end
        end
        table.sort(items, sort_fun)

        -- Add "latest" session
        table.insert(items, 1, {
          _session = vim.v.this_session,
          name = global_session_name,
          action = ([[lua _G.MiniSessions.read('%s')]]):format(global_session_name),
          section = "Sessions",
        })
        if vim.tbl_count(items) == 0 then
          return { { name = [[There are no detected sessions in 'mini.sessions']], action = "", section = "Sessions" } }
        end
        -- Take only first `n` elements and remove helper fields
        return vim.tbl_map(function(x)
          x._session = nil
          return x
        end, vim.list_slice(items, 1, n))
      end,
      -- MiniStarter.sections.pick(),
      MiniStarter.sections.recent_files(5, false),
    },
    content_hooks = {
      MiniStarter.gen_hook.adding_bullet(),
      MiniStarter.gen_hook.indexing("all", { "Builtin actions", "Sessions", "Pick", "Actions" }),
      MiniStarter.gen_hook.aligning("center", "center"),
    },
    footer = function()
      -- Calculate difference in nanoseconds, convert to milliseconds
      if vim.g.startup_time then return vim.g.startup_time end
      local total_ms = (vim.uv.hrtime() - _G.STARTUP_TIME) / 1e6
      vim.g.startup_time = string.format("🚀 Started in %.2f ms", total_ms)
      return vim.g.startup_time
    end,
    silent = false,
  }
end)

-- Statusline. Sets `:h 'statusline'` to show more info in a line below window.
-- Example usage:
-- - Left most section indicates current mode (text + highlighting).
-- - Second from left section shows "developer info": Git, diff, diagnostics, LSP.
-- - Center section shows the name of displayed buffer.
-- - Second to right section shows more buffer info.
-- - Right most section shows current cursor coordinates and search results.
--
-- See also:
-- - `:h MiniStatusline-example-content` - example of default content. Use it to
--   configure a custom statusline by setting `config.content.active` function.
now(function()
  local MiniStatusline = require "mini.statusline"
  MiniStatusline.combine_groups = function(groups)
    local parts = vim.tbl_map(function(s)
      if type(s) == "string" then return s end
      if type(s) ~= "table" then return "" end

      local string_arr = vim.tbl_filter(function(x) return type(x) == "string" and x ~= "" end, s.strings or {})
      local str = table.concat(string_arr, "")

      -- Use previous highlight group
      if s.hl == nil then return "" .. str .. "" end

      -- Allow using this highlight group later
      if str:len() == 0 then return "%#" .. s.hl .. "#" end

      return string.format("%%#%s#%s", s.hl, str)
    end, groups)

    return table.concat(parts, "")
  end
  local H = {}
  H.ensure_get_icon = function()
    if not MiniStatusline.config.use_icons then
      -- Show no icon
      H.get_icon = nil
    elseif H.get_icon ~= nil then
      -- Cache only once
      return
    elseif _G.MiniIcons ~= nil then
      -- Prefer 'mini.icons'
      H.get_icon = function(filetype) return (_G.MiniIcons.get("filetype", filetype)) end
    else
      -- Try falling back to 'nvim-web-devicons'
      local has_devicons, devicons = pcall(require, "nvim-web-devicons")
      if not has_devicons then return end
      H.get_icon = function() return (devicons.get_icon(vim.fn.expand "%:t", nil, { default = true })) end
    end
  end
  MiniStatusline.section_location = function(args)
    local ln_width = #tostring(vim.api.nvim_buf_line_count(0))
    if MiniStatusline.is_truncated(args.trunc_width) then return string.format("%%%dl/%%%dv", ln_width, 3) end
    -- Use `virtcol()` to correctly handle multi-byte characters
    -- return '%l/%-1L│%1v/%-2{virtcol("$") - 1}'
    return string.format('%%%dl/%%-%dL│%%%dv/%%-%d{virtcol("$") - 1}', ln_width, ln_width, 3, 3)
  end
  local old_mode_hl = {}
  -- Cache these outside the function so they only run ONCE
  MiniStatusline.section_filename = function(args)
    local pattern = ""
    -- In terminal, and nofile always show 'filename'
    if vim.bo.buftype == "terminal" or vim.bo.buftype == "nofile" then
      pattern = "%t"
    elseif MiniStatusline.is_truncated(args.trunc_width) then
      -- File name with 'truncate', 'modified', 'readonly' flags
      -- Use relative path if truncated
      pattern = "%f%m%r"
    else
      -- Use fullpath if not truncated
      pattern = "%F%m%r"
    end
    -- Show minifiles hidden status
    return pattern
      .. (
        (
            (vim.bo.filetype == "minifiles" or vim.bo.filetype == "minifiles-help")
            and (MiniFiles and not MiniFiles.show_hidden)
          )
          and " (hidden)"
        or ""
      )
  end
  MiniStatusline.section_extra_plugins = {}

  MiniStatusline.setup {
    use_icons = vim.g.icons_enabled,
    content = {
      active = function()
        -- Prevent statusline flickering during cmd mode
        if vim.o.cmdheight <= 0 and vim.fn.getcmdtype() == "/" then return "" end
        local mode, mode_hl = MiniStatusline.section_mode {}

        if not old_mode_hl[mode_hl] then
          local hl = Config.get_hlgroup(mode_hl)
          vim.api.nvim_set_hl(0, mode_hl .. "Separator1", { fg = hl.bg, bg = "#BCC4C9" })
          old_mode_hl[mode_hl] = true
        end
        H.ensure_get_icon()
        local file_icon = H.get_icon ~= nil and vim.bo.filetype ~= "" and H.get_icon(vim.bo.filetype) or ""
        local git = MiniStatusline.section_git { trunc_width = 40 }
        local diff = vim.b.minidiff_summary_string_obj or MiniStatusline.section_diff { trunc_width = 75 }
        local diagnostics = MiniStatusline.section_diagnostics {
          trunc_width = 75,
          icon = "",
          signs = {
            ERROR = Config.get_custom_icon "DiagnosticError",
            HINT = Config.get_custom_icon "DiagnosticHint",
            WARN = Config.get_custom_icon "DiagnosticWarn",
            INFO = Config.get_custom_icon "DiagnosticInfo",
          },
        }
        local lsp = MiniStatusline.section_lsp { trunc_width = 75, icon = Config.get_custom_icon "ActiveLSP" }
        local filename = MiniStatusline.section_filename { trunc_width = 140 }
        local location = MiniStatusline.section_location { trunc_width = 75 }
        local search = MiniStatusline.section_searchcount { trunc_width = 75 }

        local groups = {
          { hl = mode_hl, strings = { " ", Config.get_custom_icon "VimIcon", " ", mode } },
          { hl = mode_hl .. "Separator1", strings = { "" } },
          { hl = "MiniStatuslineModeSeparator2", strings = { "" } },
          { hl = "MiniStatuslineFilename", strings = { " ", file_icon, " ", filename, " " } },
          { hl = "MiniStatuslineModeSeparator3", strings = { "" } },
          "%<",
          { hl = "MiniStatuslineGit", strings = { " ", git } },
        }

        if type(diff) == "table" then
          if diff.add then
            table.insert(groups, { hl = "DiffAdd", strings = { " ", diff.add_icon, " ", tostring(diff.add) } })
          end
          if diff.change then
            table.insert(groups, { hl = "DiffChange", strings = { " ", diff.change_icon, " ", tostring(diff.change) } })
          end
          if diff.delete then
            table.insert(groups, { hl = "DiffDelete", strings = { " ", diff.delete_icon, " ", tostring(diff.delete) } })
          end
        else
          table.insert(groups, { hl = "MiniStatuslineDevinfo", strings = { " ", diff } })
        end

        table.insert(groups, "%=")
        if diagnostics then
          local segments = vim.split(diagnostics, "%s+", { trimempty = true })
          for _, segment in ipairs(segments) do
            local count = segment:match "%d+"
            local icon = segment:match "%D+"
            if icon == Config.get_custom_icon "DiagnosticError" then
              table.insert(groups, { hl = "DiagnosticError", strings = { " ", tostring(icon), " ", tostring(count) } })
            end
            if icon == Config.get_custom_icon "DiagnosticInfo" then
              table.insert(groups, { hl = "DiagnosticInfo", strings = { " ", tostring(icon), " ", tostring(count) } })
            end
            if icon == Config.get_custom_icon "DiagnosticHint" then
              table.insert(groups, { hl = "DiagnosticHint", strings = { " ", tostring(icon), " ", tostring(count) } })
            end
            if icon == Config.get_custom_icon "DiagnosticWarn" then
              table.insert(groups, { hl = "DiagnosticWarn", strings = { " ", tostring(icon), " ", tostring(count) } })
            end
          end
        end
        local right_side = {
          { hl = "MiniStatuslineDevinfo", strings = { " ", lsp, " " } },
          { hl = "MiniStatuslineSearch", strings = search ~= "" and { " ", search, " " } or {} },
          { hl = "MiniStatuslineFiletype", strings = { " ", file_icon .. " " .. vim.bo.filetype } },
          { hl = "MiniStatuslineLocation", strings = { " ", location } },
        }
        for _, section in ipairs(MiniStatusline.section_extra_plugins) do
          local display_text
          if type(section) == "function" then
            display_text = section { trunc_width = 75 }
          elseif type(section) == "string" then
            display_text = section
          end
          if display_text then
            -- Insert extra plugins section after LSP section
            table.insert(right_side, 2, { hl = "MiniStatuslineExtras", strings = { " ", display_text, " " } })
          end
        end

        for _, section in ipairs(right_side) do
          table.insert(groups, section)
        end
        return MiniStatusline.combine_groups(groups)
      end,
    },
  }
  vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { bg = "#4FA6ED", fg = "#111317", bold = true })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { bg = "#8EBD6B", fg = "#111317", bold = true })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { bg = "#BF68D9", fg = "#111317", bold = true })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { bg = "#E2B86B", fg = "#111317", bold = true })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { bg = "#E55561", fg = "#111317", bold = true })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { link = "MiniStatuslineModeInsert" })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeSeparator2", { bg = "#202c36", fg = "#BCC4C9" })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeSeparator3", { fg = "#202c36", bg = "NONE" })
  vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { bg = "#202c36", fg = "#BCC4C9" })
  vim.api.nvim_set_hl(0, "MiniStatuslineGit", { fg = "#696C76" })
  vim.api.nvim_set_hl(0, "MiniStatuslineSearch", { link = "Search" })
  vim.api.nvim_set_hl(0, "MiniStatuslineLocation", { bg = "NONE" })
  Config.extend_hl("MiniStatuslineDevinfo", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "MiniStatuslineExtras", { fg = "#E2B86B", bold = true })
end)

-- Tabline. Sets `:h 'tabline'` to show all listed buffers in a line at the top.
-- Buffers are ordered as they were created. Navigate with `[b` and `]b`.
now(function()
  Config.extend_hl("MiniTablineCurrent", { bold = false, fg = "#4FA6ED" })
  Config.extend_hl("MiniTablineVisible", { bold = false, fg = "#4FA6ED" })
  Config.extend_hl("MiniTablineHidden", { bold = false, fg = "#696C76" })
  local MiniTablineCurrent = Config.get_hlgroup "MiniTablineCurrent"
  local MiniTablineHidden = Config.get_hlgroup "MiniTablineHidden"
  local MiniTablineVisible = Config.get_hlgroup "MiniTablineVisible"

  Config.extend_hl(
    "MiniTablineModifiedCurrent",
    { bold = false, bg = MiniTablineCurrent.bg, fg = MiniTablineCurrent.fg }
  )
  Config.extend_hl(
    "MiniTablineModifiedVisible",
    { bold = false, bg = MiniTablineVisible.bg, fg = MiniTablineVisible.fg }
  )
  Config.extend_hl("MiniTablineModifiedHidden", { bold = false, bg = MiniTablineHidden.bg, fg = MiniTablineHidden.fg })
  -- vim.api.nvim_set_hl(0, 'MiniTablineTrunc', { fg = '#BCC4C9', bg = 'NONE', italic = true, bold = true })

  require("mini.tabline").setup {
    format = function(buf_id, label)
      local suffix = vim.bo[buf_id].modified and " " or ""
      return MiniTabline.default_format(buf_id, label) .. suffix
    end,
  }
  -- vim.api.nvim_set_hl(0, 'MiniStatuslineLocation', { bg = 'NONE' })
end)

now_if_args(function()
  local show_hidden = true
  local dim_hidden = true

  local hide_dotfiles = true
  local hide_by_name = { ".git" }
  local hide_by_pattern = { "%.git/" }
  local search_pattern = ""

  -- local always_show = { '.env', '__pycache__' }
  -- local always_show_by_pattern = { '%.env.*' }
  -- Never show, even if show_hidden = true
  local never_show = { ".DS_Store", "thumbs.db" }
  local never_show_by_pattern = {}

  -- always_show = vim.tbl_to_set(always_show)
  never_show = vim.tbl_to_set(never_show)
  hide_by_name = vim.tbl_to_set(hide_by_name)

  local smart_hlsearch = function(fs_entries)
    local valid_entry = {}
    local is_in_searchmode = vim.v.hlsearch
    if is_in_searchmode == 0 or (not search_pattern or search_pattern == "") or #fs_entries == 0 then
      return fs_entries
    end
    local ft = vim.bo.filetype
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local explorer_state = ((ft == "minifiles" and row >= 1 and MiniFiles) and MiniFiles.get_explorer_state())
    local cur_focused_path = explorer_state and explorer_state.branch[explorer_state.depth_focus]
    local is_focused_pane = nil
    for _, entry in ipairs(fs_entries) do
      if is_focused_pane == nil then
        is_focused_pane = cur_focused_path and vim.fs.dirname(entry.path) == cur_focused_path
      end
      if vim.fn.match(entry.name, search_pattern) >= 0 or not is_focused_pane then table.insert(valid_entry, entry) end
    end
    return valid_entry
  end

  local filter_show = function(fs_entry)
    local name = fs_entry.name
    local path = fs_entry.path

    -- Never show, even if toggled
    if never_show[name] then return false end

    for _, pattern in ipairs(never_show_by_pattern) do
      if string.match(path, pattern) then return false end
    end

    return true
  end
  local filter_hide = function(fs_entry)
    local name = fs_entry.name
    local path = fs_entry.path

    -- Never show, even if toggled
    if never_show[name] then return false end

    for _, pattern in ipairs(never_show_by_pattern) do
      if string.match(path, pattern) then return false end
    end

    -- -- Always show, overrides dotfile/git hide
    -- if always_show[name] then return true end
    --
    -- -- Always show, overrides dotfile/git hide
    -- for _, pattern in ipairs(always_show_by_pattern) do
    --   if string.match(path, pattern) then return true end
    -- end

    -- Node modules, etc.
    if hide_by_name[name] then return false end

    -- dotfile hide
    if hide_dotfiles and vim.startswith(name, ".") then return false end

    -- hide by pattern
    for _, pattern in ipairs(hide_by_pattern) do
      if string.match(path, pattern) then return false end
    end

    return true
  end

  -- Enable directory/file preview
  require "mini.files"

  local clear_search = function()
    vim.schedule(function()
      search_pattern = ""
      MiniFiles.refresh { content = { force = true } }
      vim.cmd "redraw"
    end)
  end

  local toggle_hidden = function()
    show_hidden = not show_hidden
    MiniFiles.gitignore.state = show_hidden
    MiniFiles.show_hidden = show_hidden
    MiniFiles.refresh { content = { force = true } }
  end

  local toggle_dim = function()
    dim_hidden = not dim_hidden
    MiniFiles.refresh { content = { force = true } }
  end

  -- Set focused directory as current working directory
  local set_cwd = function()
    local path = (MiniFiles.get_fs_entry() or {}).path
    if path == nil then return vim.notify "Cursor is not on valid entry" end
    local p = vim.fs.dirname(path)
    vim.fn.chdir(p)
    vim.notify(string.format("Root:\n %s", p))
  end

  -- Display yanked indicators
  local ns = vim.api.nvim_create_namespace "minifiles_yank_status"
  local function normalize_yank_data(line)
    if line then
      local yanked_entry_parts = vim.split(line, "/", { trimempty = true })
      if #yanked_entry_parts < 3 then return end
      yanked_entry_parts[1] = yanked_entry_parts[1]:gsub("^0+(%d)", "%1")
      return "/" .. table.concat(yanked_entry_parts, "/")
    end
    return line
  end

  local function draw_yank_extmarks(buf_id)
    -- local buf_id = args.data.buf_id
    local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)

    local yank_data = vim.fn.getreg "0"
    if yank_data == "" then
      vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
      return
    end

    local yanked_lines = {}
    for line in string.gmatch(yank_data, "[^\r\n]+") do
      ---@diagnostic disable-next-line: redefined-local
      local line = normalize_yank_data(line)
      if line then yanked_lines[line] = true end
    end

    vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)

    for line_num, line_content in ipairs(lines) do
      if line_content then
        ---@diagnostic disable-next-line: redefined-local
        local line_content = normalize_yank_data(line_content)
        if line_content then
          if yanked_lines[normalize_yank_data(line_content)] then
            vim.api.nvim_buf_set_extmark(buf_id, ns, line_num - 1, 0, {
              virt_text = { { "+ ", "Added" } },
              virt_text_pos = "inline",
            })
          end
        end
      end
    end
  end

  -- Yank in register full path of entry under cursor
  local yank_path = function()
    local path = (MiniFiles.get_fs_entry() or {}).path
    if path == nil then return vim.notify "Cursor is not on valid entry" end
    vim.fn.setreg('"', path)
    if vim.v.register ~= '"' then vim.fn.setreg(vim.v.register, path) end
    draw_yank_extmarks(vim.api.nvim_get_current_buf())
    vim.notify(string.format("Yanked:\n%s", path))
  end

  local yank_basename = function()
    local name = (MiniFiles.get_fs_entry() or {}).name
    if name == nil then return vim.notify "Cursor is not on valid entry" end
    vim.fn.setreg(vim.v.register, name)
    vim.fn.setreg('"', name)
    if vim.v.register ~= '"' then vim.fn.setreg(vim.v.register, name) end
    draw_yank_extmarks(vim.api.nvim_get_current_buf())
    vim.notify(string.format("Yanked:\n%s", name))
  end
  -- Open path with system default handler (useful for non-text files)
  local ui_open = function() vim.ui.open(MiniFiles.get_fs_entry().path) end
  -- Add common bookmarks for every explorer. Example usage inside explorer:
  -- - `'c` to navigate into your config directory
  -- - `g?` to see available bookmarks
  local home = vim.fn.expand "~"
  local add_bookmarks = function()
    local function setbookmark(key, path, desc)
      local p = path
      if vim.is_callable(path) then p = path() end
      if vim.uv.fs_stat(p) then MiniFiles.set_bookmark(key, p, { desc }) end
    end
    setbookmark("c", vim.fn.stdpath "config", { desc = "~/.config" })
    local vimpack_plugins = vim.fs.joinpath(vim.fn.stdpath "data", "site", "pack", "core", "opt")
    setbookmark("p", vimpack_plugins, { desc = "Nvim Plugins" })
    setbookmark("w", vim.fn.getcwd, { desc = "CWD" })
    setbookmark("l", vim.fs.joinpath(home, ".local", "share"), { desc = "~/.local/share/" })
    setbookmark("h", home, { desc = "~/" })
    setbookmark("g", vim.fs.joinpath(home, "git"), { desc = "~/git/" })
  end

  -- ╭─────────────────────────────────────────────────────────╮
  -- │                   Autocmd mini.files                    │
  -- ╰─────────────────────────────────────────────────────────╯

  Config.new_autocmd("User", "MiniFilesExplorerOpen", function()
    local minifiles_group = vim.api.nvim_create_augroup("minifiles-custom-group", { clear = true })
    add_bookmarks()
    Config.new_autocmd("BufEnter", nil, function(args2)
      local ft = vim.bo[args2.buf].filetype
      if ft == "minifiles" and search_pattern ~= "" then
        vim.defer_fn(function()
          vim.cmd "nohlsearch"
          clear_search()
          vim.api.nvim_del_autocmd(args2.id)
        end, 20)
      end
    end, "BufEnter minifiles clear search pattern at the start", minifiles_group)

    ---@type uv.uv_timer_t|nil
    local cmdchange_timer = nil
    Config.new_autocmd("CmdlineChanged", nil, function()
      local cmd_type = vim.fn.getcmdtype()
      if cmd_type == "/" or cmd_type == "?" then
        if cmdchange_timer then cmdchange_timer:stop() end
        cmdchange_timer = vim.defer_fn(function()
          search_pattern = vim.fn.getcmdline() or ""
          MiniFiles.refresh { content = { force = true } }
          vim.cmd "redraw"
        end, 100)
      end
    end, "CmdlineChanged minifiles search pattern", minifiles_group)

    Config.new_autocmd(
      "User",
      "Nohlsearch",
      function() clear_search() end,
      "Nohlsearch minifiles clear search pattern",
      minifiles_group
    )
    -- Trigger MiniFiles refresh on `TextYankPost` event to redraw +/added marks
    Config.new_autocmd("TextYankPost", nil, function(args)
      local event = vim.v.event
      vim.schedule(function()
        if event.operator == "y" and vim.api.nvim_buf_is_valid(args.buf) then draw_yank_extmarks(args.buf) end
      end)
    end, "Trigger MiniFiles refresh", minifiles_group)
  end, "Nohlsearch minifiles clear search pattern")

  Config.new_autocmd(
    "User",
    "MiniFilesExplorerClose",
    function() vim.api.nvim_del_augroup_by_name "minifiles-custom-group" end,
    "MiniFilesExplorerClose"
  )

  Config.new_autocmd(
    "User",
    "MiniFilesBufferUpdate",
    function(args) draw_yank_extmarks(args.data.buf_id) end,
    "MiniFilesBufferUpdate"
  )

  -- Mappings
  Config.new_autocmd("User", "MiniFilesBufferCreate", function(args)
    local buf_id = args.data.buf_id
    -- Tweak left-hand side of mapping to your liking
    vim.keymap.set("n", "<F2>", toggle_hidden, { buf = buf_id, desc = "Toggle hidden" })
    vim.keymap.set("n", "<F3>", toggle_dim, { buf = buf_id, desc = "Toggle dim" })
    vim.keymap.set("n", ".", set_cwd, { buf = buf_id, desc = "Set cwd" })
    vim.keymap.set("n", "gx", ui_open, { buf = buf_id, desc = "OS open" })
    vim.keymap.set("n", "yp", yank_path, { buf = buf_id, desc = "Yank path" })
    vim.keymap.set("n", "yn", yank_basename, { buf = buf_id, desc = "Yank name" })
    vim.keymap.set("n", "<M-h>", "<Left>", { buf = buf_id })
    vim.keymap.set("n", "<M-l>", "<Right>", { buf = buf_id })
    -- Remove swap line up/down mappings
    vim.keymap.set("n", "<M-j>", "j", { buf = buf_id })
    vim.keymap.set("n", "<M-k>", "k", { buf = buf_id })

    vim.keymap.set("n", "<Esc>", function()
      if search_pattern ~= "" then
        vim.cmd "nohlsearch"
        clear_search()
      else
        MiniFiles.close()
      end
    end, { buf = buf_id, desc = "Clear filter/search or close minifiles" })

    vim.keymap.set("n", "<CR>", function()
      MiniFiles.synchronize()
      MiniFiles.go_in { close_on_file = true }
    end, { buf = buf_id, desc = "Go to entry" })

    vim.keymap.set("n", "<C-a>", "ggVG", { buf = buf_id, desc = "Select all" })
    vim.keymap.set(
      { "n", "i" },
      "<C-S>",
      function() MiniFiles.synchronize() end,
      { buf = buf_id, desc = "Save changes" }
    )
    vim.keymap.set("n", "yA", "ggVGyy", { buf = buf_id, desc = "Yank all" })
    vim.keymap.set("n", "<C-v>", "p", { buf = buf_id, desc = "Paste" })
  end, "Create mappings for mini files window")

  Config.new_autocmd("VimLeavePre", nil, function()
    if MiniFiles.gitignore then MiniFiles.gitignore:cleanup() end
  end)

  -- autochdir
  Config.new_autocmd("DirChanged", "*", function()
    if MiniFiles.get_explorer_state() then -- check if we have an open explorer
      MiniFiles.open(vim.fn.getcwd()) -- re-open for changed cwd
    end
  end, "Auto change cwd")

  require("mini.files").setup {
    options = {
      use_as_default_explorer = true,
      permanant_delete = false,
    },
    windows = {
      max_number = 3,
      preview = true,
      width_focus = 30,
      width_nofocus = 15,
      width_preview = vim.o.columns - 30 - 15 - 6, -- 6 is border width of all 3 windows
    },
    -- Module mappings created only inside explorer.
    -- Use `''` (empty string) to not create one.
    mappings = {
      close = "q",
      go_in = "L",
      go_in_plus = "l",
      go_out = "h",
      go_out_plus = "H",
      mark_goto = "'",
      mark_set = "m",
      reset = "<BS>",
      reveal_cwd = "@",
      show_help = "g?",
      synchronize = "=",
      trim_left = "<",
      trim_right = ">",
    },
    -- Gitignore-specific configuration
    gitignore = {
      max_cache_size = 200,
      max_concurrent_jobs = 10,
      prefetch_depth = 1,
      enable_metrics = false,
      enable_logging = false, -- Set to true to enable debug logs
      log_level = vim.log.levels.DEBUG, -- Only matters when enable_logging = true
    },
    content = {
      filter = function(fs_entry) return show_hidden and filter_show(fs_entry) or filter_hide(fs_entry) end,
      sort = function(fs_entries) return MiniFiles.gitignore:sort_entries(smart_hlsearch(fs_entries)) end,
      highlight = function(fs_entry)
        local path = fs_entry.path
        -- If dimming is off, use default highlighting
        if not dim_hidden then return MiniFiles.default_highlight(fs_entry) end
        -- If filter_hide returns false, it means this is a "hidden" file
        -- return 'Comment' to dim it.
        if
          (not filter_hide(fs_entry))
          or (MiniFiles.gitignore and MiniFiles.gitignore:is_file_ignored(vim.fs.dirname(path), path))
        then
          return "Comment"
        end

        -- Otherwise use standard highlighting
        return MiniFiles.default_highlight(fs_entry)
      end,
    },
  }
  MiniFiles.gitignore = MiniFilesGitignore.new(MiniFiles.config, MiniFiles.config.gitignore)
  MiniFiles.show_hidden = show_hidden
end)

-- Miscellaneous small but useful functions. Example usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
-- - `<Leader>or` - resize window to its "editable width"
-- - `:lua put_text(vim.lsp.get_clients())` - put output of a function below
--   cursor in current buffer. Useful for a detailed exploration.
-- - `:lua put(MiniMisc.stat_summary(MiniMisc.bench_time(f, 100)))` - run
--   function `f` 100 times and report statistical summary of execution times
now_if_args(function()
  -- Makes `:h MiniMisc.put()` and `:h MiniMisc.put_text()` public
  require("mini.misc").setup()

  -- Change current working directory based on the current file path. It
  -- searches up the file tree until the first root marker ('.git' or 'Makefile')
  -- and sets their parent directory as a current directory.
  -- This is helpful when simultaneously dealing with files from several projects.
  -- NOTE: Don't use this, already added a better version in 'plugin/00_autocmd.lua'
  -- MiniMisc.setup_auto_root {
  --   "nvim-pack-lock.json",
  --   ".git",
  --   "_darcs",
  --   ".hg",
  --   ".bzr",
  --   ".svn",
  -- }

  -- Restore latest cursor position on file open
  MiniMisc.setup_restore_cursor()

  -- Synchronize terminal emulator background with Neovim's background to remove
  -- possibly different color padding around Neovim instance
  MiniMisc.setup_termbg_sync()
end)

-- Step two ===================================================================

-- Extra 'mini.nvim' functionality.
--
-- See also:
-- - `:h MiniExtra.pickers` - pickers. Most are mapped in `<Leader>f` group.
--   Calling `setup()` makes 'mini.pick' respect 'mini.extra' pickers.
-- - `:h MiniExtra.gen_ai_spec` - 'mini.ai' textobject specifications
-- - `:h MiniExtra.gen_highlighter` - 'mini.hipatterns' highlighters
later(function() require("mini.extra").setup() end)

-- Extend and create a/i textobjects, like `:h a(`, `:h a'`, and more).
-- Contains not only `a` and `i` type of textobjects, but also their "next" and
-- "last" variants that will explicitly search for textobjects after and before
-- cursor. Example usage:
-- - `ci)` - *c*hange *i*inside parenthesis (`)`)
-- - `di(` - *d*elete *i*inside padded parenthesis (`(`)
-- - `yaq` - *y*ank *a*round *q*uote (any of "", '', or ``)
-- - `vif` - *v*isually select *i*inside *f*unction call
-- - `cina` - *c*hange *i*nside *n*ext *a*rgument
-- - `valaala` - *v*isually select *a*round *l*ast (i.e. previous) *a*rgument
--   and then again reselect *a*round new *l*ast *a*rgument
--
-- See also:
-- - `:h text-objects` - general info about what textobjects are
-- - `:h MiniAi-builtin-textobjects` - list of all supported textobjects
-- - `:h MiniAi-textobject-specification` - examples of custom textobjects
later(function()
  local ai = require "mini.ai"
  ai.setup {
    -- 'mini.ai' can be extended with custom textobjects
    custom_textobjects = {
      -- Make `aB` / `iB` act on around/inside whole *b*uffer
      B = MiniExtra.gen_ai_spec.buffer(),
      D = MiniExtra.gen_ai_spec.diagnostic(),

      -- I = MiniExtra.gen_ai_spec.indent(),
      L = MiniExtra.gen_ai_spec.line(),
      N = MiniExtra.gen_ai_spec.number(),
      -- For more complicated textobjects that require structural awareness,
      -- use tree-sitter. This example makes `aF`/`iF` mean around/inside function
      -- definition (not call). See `:h MiniAi.gen_spec.treesitter()` for details.
      F = ai.gen_spec.treesitter { a = "@function.outer", i = "@function.inner" },
    },
    mappings = {
      -- Next/last textobjects
      -- NOTE: These override built-in LSP selection mappings on Neovim>=0.12
      -- Map LSP selection manually to use it (see `:h MiniAi.config`)
      around_next = "an",
      inside_next = "in",
      around_last = "al",
      inside_last = "il",
    },

    -- Number of lines within which textobject is searched
    n_lines = 10000,
    -- 'mini.ai' by default mostly mimics built-in search behavior: first try
    -- to find textobject covering cursor, then try to find to the right.
    -- Although this works in most cases, some are confusing. It is more robust to
    -- always try to search only covering textobject and explicitly ask to search
    -- for next (`an`/`in`) or last (`al`/`il`).
    -- Try this. If you don't like it - delete next line and this comment.
    search_method = "cover",
  }
end)

local map_lsp_selection = function(lhs, desc)
  local s = vim.startswith(desc, "Increase") and 1 or -1
  local rhs = function() vim.lsp.buf.selection_range(s * vim.v.count1) end
  vim.keymap.set("x", lhs, rhs, { desc = desc })
end
map_lsp_selection("<Leader>ls", "Increase selection")
map_lsp_selection("<Leader>lS", "Decrease selection")
-- Align text interactively. Example usage:
-- - `gaip,` - `ga` (align operator) *i*nside *p*aragraph by comma
-- - `gAip` - start interactive alignment on the paragraph. Choose how to
--   split, justify, and merge string parts. Press `<CR>` to make it permanent,
--   press `<Esc>` to go back to initial state.
--
-- See also:
-- - `:h MiniAlign-example` - hands-on list of examples to practice aligning
-- - `:h MiniAlign.gen_step` - list of support step customizations
-- - `:h MiniAlign-algorithm` - how alignment is done on algorithmic level
later(
  function()
    require("mini.align").setup {
      mappings = {
        start = "ga",
        start_with_preview = "gA",
      },

      options = {
        split_pattern = "=",
        justify_side = "left",
        merge_delimiter = "",
      },
    }
  end
)

-- Animate common Neovim actions. Like cursor movement, scroll, window resize,
-- window open, window close. Animations are done based on Neovim events and
-- don't require custom mappings.
--
-- It is not enabled by default because its effects are a matter of taste.
-- Also scroll and resize have some unwanted side effects (see `:h mini.animate`).
-- Uncomment next line (use `gcc`) to enable.
-- later(function() require('mini.animate').setup() end)

-- Go forward/backward with square brackets. Implements consistent sets of mappings
-- for selected targets (like buffers, diagnostic, quickfix list entries, etc.).
-- Example usage:
-- - `]b` - go to next buffer
-- - `[j` - go to previous jump inside current buffer
-- - `[Q` - go to first entry of quickfix list
-- - `]X` - go to last conflict marker in a buffer
--
-- See also:
-- - `:h MiniBracketed` - overall mapping design and list of targets
later(function()
  require("mini.bracketed").setup {
    undo = { suffix = "", options = {} },
    file = { suffix = "", options = {} },
    jump = { suffix = "", options = {} },
    buffer = { suffix = "b", options = {} },
    comment = { suffix = "c", options = {} },
    conflict = { suffix = "x", options = {} },
    -- NOTE: Use lspsaga instead
    diagnostic = { suffix = "", options = {} },
    indent = { suffix = "i", options = {} },
    location = { suffix = "l", options = {} },
    oldfile = { suffix = "", options = {} },
    quickfix = { suffix = "q", options = {} },
    treesitter = { suffix = "t", options = {} },
    window = { suffix = "w", options = {} },
    yank = { suffix = "", options = {} },
  }
  vim.keymap.set({ "n", "i" }, "<M-w>", "<Cmd>lua MiniBracketed.window('forward')<CR>")
end)

-- Remove buffers. Opened files occupy space in tabline and buffer picker.
-- When not needed, they can be removed. Example usage:
-- - `<Leader>bw` - completely wipeout current buffer (see `:h :bwipeout`)
-- - `<Leader>bW` - completely wipeout current buffer even if it has changes
-- - `<Leader>bd` - delete current buffer (see `:h :bdelete`)
later(function() require("mini.bufremove").setup() end)

-- Command line tweaks. Improves command line editing with:
-- - Autocompletion. Basically an automated `:h cmdline-completion`.
-- - Autocorrection of words as-you-type. Like `:W`->`:w`, `:lau`->`:lua`, etc.
-- - Autopeek command range (like line number at the start) as-you-type.
later(function()
  require("mini.cmdline").setup {
    -- Autopeek: show command's target range in a floating window
    autopeek = {
      n_context = 3,
    },
  }
end)

-- Tweak and save any color scheme. Contains utility functions to work with
-- color spaces and color schemes. Example usage:
-- - `:Colorscheme default` - switch with animation to the default color scheme
--
-- See also:
-- - `:h MiniColors.interactive()` - interactively tweak color scheme
-- - `:h MiniColors-recipes` - common recipes to use during interactive tweaking
-- - `:h MiniColors.convert()` - convert between color spaces
-- - `:h MiniColors-color-spaces` - list of supported color sapces
--
-- It is not enabled by default because it is not really needed on a daily basis.
-- Uncomment next line (use `gcc`) to enable.
later(function() require("mini.colors").setup() end)

-- Comment lines. Provides functionality to work with commented lines.
-- Uses `:h 'commentstring'` option to infer comment structure.
-- Example usage:
-- - `gcip` - toggle comment (`gc`) *i*inside *p*aragraph
-- - `vapgc` - *v*isually select *a*round *p*aragraph and toggle comment (`gc`)
-- - `gcgc` - uncomment (`gc`, operator) comment block at cursor (`gc`, textobject)
--
-- The built-in `:h commenting` is based on 'mini.comment'. Yet this module is
-- still enabled as it provides more customization opportunities.
later(function()
  require("mini.comment").setup {
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      -- Toggle comment (like `gcip` - comment inner paragraph) for both
      -- Normal and Visual modes
      comment = "gc",

      -- Toggle comment on current line
      comment_line = "gcc",

      -- Toggle comment on visual selection
      comment_visual = "gc",

      -- Define 'comment' textobject (like `dgc` - delete whole comment block)
      -- Works also in Visual mode if mapping differs from `comment_visual`
      textobject = "gc",
    },
  }
end)

-- Autohighlight word under cursor with a customizable delay.
-- Word boundaries are defined based on `:h 'iskeyword'` option.
--
-- It is not enabled by default because its effects are a matter of taste.
-- Uncomment next line (use `gcc`) to enable.

-- later(function() require('mini.cursorword').setup() end)

-- Work with diff hunks that represent the difference between the buffer text and
-- some reference text set by a source. Default source uses text from Git index.
-- Also provides summary info used in developer section of 'mini.statusline'.
-- Example usage:
-- - `ghip` - apply hunks (`gh`) within *i*nside *p*aragraph
-- - `gHG` - reset hunks (`gH`) from cursor until end of buffer (`G`)
-- - `ghgh` - apply (`gh`) hunk at cursor (`gh`)
-- - `gHgh` - reset (`gH`) hunk at cursor (`gh`)
-- - `<Leader>go` - toggle overlay
--
-- See also:
-- - `:h MiniDiff-overview` - overview of how module works
-- - `:h MiniDiff-diff-summary` - available summary information
-- - `:h MiniDiff.gen_source` - available built-in sources
later(function()
  local gitsign = Config.get_custom_icon "GitSign"
  require("mini.diff").setup {
    view = {
      -- Visualization style. Possible values are 'sign' and 'number'.
      -- Default: 'number' if line numbers are enabled, 'sign' otherwise.
      style = "sign",

      -- Signs used for hunks with 'sign' view
      signs = { add = gitsign, change = gitsign, delete = gitsign },

      -- Priority of used visualization extmarks
      priority = 199,
    },
    -- Module mappings. Use `''` (empty string) to disable one.
    -- Apply hunks inside a visual/operator region
    mappings = {
      apply = "gh",

      -- Reset hunks inside a visual/operator region
      reset = "gH",

      -- Hunk range textobject to be used inside operator
      -- Works also in Visual mode if mapping differs from apply and reset
      textobject = "gh",

      -- Go to hunk range in corresponding direction
      goto_first = "[H",
      goto_prev = "[h",
      goto_next = "]h",
      goto_last = "]H",
    },
    options = {
      -- Diff algorithm. See `:h vim.diff()`.
      algorithm = "histogram",

      -- Whether to use "indent heuristic". See `:h vim.diff()`.
      indent_heuristic = true,

      -- The amount of second-stage diff to align lines
      linematch = 60,

      -- Whether to wrap around edges during hunk navigation
      wrap_goto = true,
    },
  }
  local format_summary = function(data)
    local summary = vim.b[data.buf].minidiff_summary
    local t = {}
    local t_obj = {}
    if summary.add > 0 then
      local icon = Config.get_custom_icon "GitAdd"
      t_obj.add_icon = icon
      t_obj.add = summary.add
      table.insert(t, icon .. " " .. summary.add)
    end
    if summary.change > 0 then
      local icon = Config.get_custom_icon "GitChange"
      t_obj.change_icon = icon
      t_obj.change = summary.change
      table.insert(t, icon .. " " .. summary.change)
    end
    if summary.delete > 0 then
      local icon = Config.get_custom_icon "GitDelete"
      t_obj.delete_icon = icon
      t_obj.delete = summary.delete
      table.insert(t, icon .. " " .. summary.delete)
    end
    vim.b[data.buf].minidiff_summary_string = table.concat(t, " ")
    vim.b[data.buf].minidiff_summary_string_obj = t_obj
  end
  Config.new_autocmd("User", "MiniDiffUpdated", format_summary)
end)

-- Highlight patterns in text. Like `TODO`/`NOTE` or color hex codes.
-- Example usage:
-- - `:Pick hipatterns` - pick among all highlighted patterns
--
-- See also:
-- - `:h MiniHipatterns-examples` - examples of common setups
later(function()
  local hipatterns = require "mini.hipatterns"
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup {
    highlighters = {
      -- Highlight a fixed set of common words. Will be highlighted in any place,
      -- not like "only in comments".
      fixme = hi_words({ "FIXME", "Fixme", "fixme", "BUG", "bug", "Bug" }, "MiniHipatternsFixme"),
      hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
      todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
      note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

      -- Highlight hex color string (#aabbcc) with that color as a background
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  }
end)

-- Jump to next/previous single character. It implements "smarter `fFtT` keys"
-- (see `:h f`) that work across multiple lines, start "jumping mode", and
-- highlight all target matches. Example usage:
-- - `fxff` - move *f*orward onto next character "x", then next, and next again
-- - `dt)` - *d*elete *t*ill next closing parenthesis (`)`)
later(function()
  require("mini.jump").setup {
    view = {
      -- Whether to dim lines with at least one jump spot
      dim = true,

      -- How many steps ahead to show. Set to big number to show all steps.
      n_steps_ahead = 9999,
    },
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      forward = "f",
      backward = "F",
      forward_till = "t",
      backward_till = "T",
      repeat_jump = ";",
    },
    silent = false,
  }
  -- Stop jumping after pressing `<Esc>`
  local jump_stop = function()
    if not MiniJump.state.jumping then return "<Esc>" end
    MiniJump.stop_jumping()
  end
  local opts = { expr = true, desc = "Stop jumping" }
  vim.keymap.set({ "n", "x", "o" }, "<Esc>", jump_stop, opts)
end)

-- Jump within visible lines to pre-defined spots via iterative label filtering.
-- Spots are computed by a configurable spotter function. Example usage:
-- - Lock eyes on desired location to jump
-- - `<CR>` - start jumping; this shows character labels over target spots
-- - Type character that appears over desired location; number of target spots
--   should be reduced
-- - Keep typing labels until target spot is unique to perform the jump
--
-- See also:
-- - `:h MiniJump2d.gen_spotter` - list of available spotters
later(function()
  require("mini.jump2d").setup {

    -- Characters used for labels of jump spots (in supplied order)
    labels = "abcdefghijklmnopqrstuvwxyz",
    view = {
      -- Whether to dim lines with at least one jump spot
      dim = true,
      -- How many steps ahead to show. Set to big number to show all steps.
      n_steps_ahead = 9999,
    },
    -- Which lines are used for computing spots
    allowed_lines = {
      blank = true, -- Blank line (not sent to spotter even if `true`)
      cursor_before = true, -- Lines before cursor line
      cursor_at = true, -- Cursor line
      cursor_after = true, -- Lines after cursor line
      fold = true, -- Start of fold (not sent to spotter even if `true`)
    },

    -- Which windows from current tabpage are used for visible lines
    allowed_windows = {
      current = true,
      not_current = true,
    },

    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      start_jumping = "<CR>",
    },
  }
end)

vim.api.nvim_set_hl(0, "MiniJump2dSpot", { fg = "#cc9057" })
vim.api.nvim_set_hl(0, "MiniJump2dSpotUnique", { fg = "#8ebd6b" })
-- Special key mappings. Provides helpers to map:
-- - Multi-step actions. Apply action 1 if condition is met; else apply
--   action 2 if condition is met; etc.
-- - Combos. Sequence of keys where each acts immediately plus execute extra
--   action if all are typed fast enough. Useful for Insert mode mappings to not
--   introduce delay when typing mapping keys without intention to execute action.
--
-- See also:
-- - `:h MiniKeymap-examples` - examples of common setups
-- - `:h MiniKeymap.map_multistep()` - map multi-step action
-- - `:h MiniKeymap.map_combo()` - map combo

-- steps[1] = {
--   condition = function() table.insert(_G.log, 'C1'); return _G.cond1 end,
--   -- Compute and return keys. Will be emulated as pressed.
--   action = function() table.insert(_G.log, 'A1'); return 'hello' end,
-- }
-- -- Make Insert mode <Tab> mapping
-- require('mini.keymap').map_multistep('i', '<Tab>', steps)
--
-- -- Pressing <Tab> inserts fallback `\t`; logs C1+C2+C3
-- _G.cond1, _G.cond2, _G.cond3 = false, false, false
later(function()
  require("mini.keymap").setup()
  -- Navigate 'mini.completion' menu with `<Tab>` /  `<S-Tab>`
  MiniKeymap.map_multistep("n", "<Tab>", { "minisnippets_next" })
  MiniKeymap.map_multistep("n", "<S-Tab>", { "minisnippets_prev" })
  -- -- On `<CR>` try to accept current completion item, fall back to accounting
  -- -- for pairs from 'mini.pairs'
  -- MiniKeymap.map_multistep(
  --   "i",
  --   "<CR>",
  --   { "minisnippets_expand", "pmenu_accept", "blink_accept", "cmp_accept", "minipairs_cr", "nvimautopairs_cr" }
  -- )
  -- On `<BS>` just try to account for pairs from 'mini.pairs'
  MiniKeymap.map_multistep("i", "<BS>", { "nvimautopairs_bs", "minipairs_bs" })

  -- Hide search highlighting
  require("mini.keymap").map_combo({ "n", "i", "x", "c" }, "<Esc><Esc>", function()
    if MiniSnippets then MiniSnippets.session.stop() end
    return "<Esc><Esc>"
  end)

  -- To fix bad habit of repeating key
  -- local notify_many_keys = function(key, times)
  --   local lhs = string.rep(key, times or 10)
  --   -- action can return string key, function, boolean
  --   local action = function() vim.notify('Too many ' .. key .. ' pressed') end
  --   MiniKeymap.map_combo({ 'n', 'x' }, lhs, action, { delay = 200 })
  -- end

  -- Uncomment this show notification if there is too much movement by repeating same key
  -- notify_many_keys 'h'
  -- notify_many_keys 'j'
  -- notify_many_keys 'k'
  -- notify_many_keys 'l'
end)

-- Window with text overview. It is displayed on the right hand side. Can be used
-- for quick overview and navigation. Hidden by default. Example usage:
-- - `<Leader>mt` - toggle map window
-- - `<Leader>mf` - focus on the map for fast navigation
-- - `<Leader>ms` - change map's side (if it covers something underneath)
--
-- See also:
-- - `:h MiniMap.gen_encode_symbols` - list of symbols to use for text encoding
-- - `:h MiniMap.gen_integration` - list of integrations to show in the map
--
-- NOTE: Might introduce lag on very big buffers (10000+ lines)
later(function()
  local map = require "mini.map"
  map.setup {
    -- Use Braille dots to encode text
    -- symbols = { encode = map.gen_encode_symbols.dot '3x2' },
    -- Show built-in search matches, 'mini.diff' hunks, and diagnostic entries
    integrations = {
      map.gen_integration.builtin_search(),
      map.gen_integration.diff(),
      map.gen_integration.diagnostic(),
      map.gen_integration.gitsigns,
    },
    window = {
      width = 1,
      winblend = 25,
      -- number and + indicator between scroll bar + map
      show_integration_count = true,
    },
  }

  -- Map built-in navigation characters to force map refresh
  for _, key in ipairs { "n", "N", "*", "#" } do
    local rhs = key
      -- Also open enough folds when jumping to the next match
      .. "zv"
      .. "<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
    vim.keymap.set("n", key, rhs)
  end
end)

-- Move any selection in any direction. Example usage in Normal mode:
-- - `<M-j>`/`<M-k>` - move current line down / up
-- - `<M-h>`/`<M-l>` - decrease / increase indent of current line
--
-- Example usage in Visual mode:
-- - `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` - move selection left/down/up/right
later(function()
  require("mini.move").setup {
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
      left = "<M-h>",
      right = "<M-l>",
      down = "<M-j>",
      up = "<M-k>",

      -- Move current line in Normal mode
      line_left = "<M-h>",
      line_right = "<M-l>",
      line_down = "<M-j>",
      line_up = "<M-k>",
    },
  }
end)

-- Text edit operators. All operators have mappings for:
-- - Regular operator (waits for motion/textobject to use)
-- - Current line action (repeat second character of operator to activate)
-- - Act on visual selection (type operator in Visual mode)
--
-- Example usage:
-- - `griw` - replace (`gr`) *i*inside *w*ord
-- - `gmm` - multiple/duplicate (`gm`) current line (extra `m`)
-- - `vipgs` - *v*isually select *i*nside *p*aragraph and sort it (`gs`)
-- - `gxiww.` - exchange (`gx`) *i*nside *w*ord with next word (`w` to navigate
--   to it and `.` to repeat exchange operator)
-- - `g==` - execute current line as Lua code and replace with its output.
--   For example, typing `g==` over line `vim.lsp.get_clients()` shows
--   information about all available LSP clients.
--
-- See also:
-- - `:h MiniOperators-mappings` - overview of how mappings are created
-- - `:h MiniOperators-overview` - overview of present operators
later(function()
  require("mini.operators").setup {

    -- Each entry configures one operator.
    -- `prefix` defines keys mapped during `setup()`: in Normal mode
    -- to operate on textobject and line, in Visual - on selection.

    -- Evaluate text and replace with output
    evaluate = {
      prefix = "g=",

      -- Function which does the evaluation
      -- func = nil,
    },

    -- Exchange/swap text regions
    -- Step 1 use gx.. -> select first region
    -- Step 2 use it again -> select second region and swap with text from step 1
    -- Use `<C-c>` to stop exchanging after the first step.
    exchange = {
      -- NOTE: Default `gx` is remapped to `gX`
      prefix = "gX",

      -- Whether to reindent new text to match previous indent
      reindent_linewise = true,
    },

    -- Multiply (duplicate) text
    -- Supports two types of |[count]|: `[count1]gm[count2][textobject]` with default
    -- `config.multiply.prefix` makes `[count1]` copies of region defined by
    -- `[count2][textobject]`. Example: `2gm3aw` - 2 copies of `3aw`.
    -- - Advantages of using this instead of "yank" + "paste":
    --    - Doesn't modify any register, while separate steps need some register to
    --      hold multiplied text.
    --    - In most cases separate steps would be "yank" + "move cursor" + "paste",
    --      while "multiply" makes it at once.
    multiply = {
      prefix = "gm",

      -- Function which can modify text before multiplying
      -- func = nil,
    },

    -- Replace text with register
    -- Also support count like multiply
    -- - Advantages of using this instead of "visually select" + "paste with |v_P|":
    --    - As operator it is dot-repeatable which has cumulative gain in case of
    --      multiple replacing is needed.
    --    - Can automatically reindent.
    replace = {
      -- NOTE: Default `gr*` LSP mappings are removed
      prefix = "gr",

      -- Whether to reindent new text to match previous indent
      reindent_linewise = true,
    },

    -- Sort text
    sort = {
      prefix = "gs",

      -- Function which does the sort
      -- func = nil,
    },
  }
end)

-- Autopairs functionality. Insert pair when typing opening character and go over
-- right character if it is already to cursor's right. Also provides mappings for
-- `<CR>` and `<BS>` to perform extra actions when inside pair.
-- Example usage in Insert mode:
-- - `(` - insert "()" and put cursor between them
-- - `)` when there is ")" to the right - jump over ")" without inserting new one
-- - `<C-v>(` - always insert a single "(" literally. This is useful since
--   'mini.pairs' doesn't provide particularly smart behavior, like auto balancing
later(function()
  -- Create pairs not only in Insert, but also in Command line mode
  require("mini.pairs").setup {
    --NOTE: Use autopairs for insert mode, terminal mode
    modes = { insert = false, command = true, terminal = false },
    mappings = {
      ["("] = { action = "open", pair = "()", neigh_pattern = "^[^\\]" },
      ["["] = { action = "open", pair = "[]", neigh_pattern = "^[^\\]" },
      ["{"] = { action = "open", pair = "{}", neigh_pattern = "^[^\\]" },

      [")"] = { action = "close", pair = "()", neigh_pattern = "^[^\\]" },
      ["]"] = { action = "close", pair = "[]", neigh_pattern = "^[^\\]" },
      ["}"] = { action = "close", pair = "{}", neigh_pattern = "^[^\\]" },

      ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "^[^\\]", register = { cr = false } },
      ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "^[^%a\\]", register = { cr = false } },
      ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "^[^\\]", register = { cr = false } },
    },
  }
end)

-- Manage and expand snippets (templates for a frequently used text).
-- Typical workflow is to type snippet's (configurable) prefix and expand it
-- into a snippet session.
--
-- How to manage snippets:
-- - 'mini.snippets' itself doesn't come with preconfigured snippets. Instead there
--   is a flexible system of how snippets are prepared before expanding.
--   They can come from pre-defined path on disk, 'snippets/' directories inside
--   config or plugins, defined inside `setup()` call directly.
-- - This config, however, does come with snippet configuration:
--     - 'snippets/global.json' is a file with global snippets that will be
--       available in any buffer
--     - 'after/snippets/lua.json' defines personal snippets for Lua language
--     - 'friendly-snippets' plugin configured in 'plugin/40_plugins.lua' provides
--       a collection of language snippets
--
-- How to expand a snippet in Insert mode:
-- - If you know snippet's prefix, type it as a word and press `<C-j>`. Snippet's
--   body should be inserted instead of the prefix.
-- - If you don't remember snippet's prefix, type only part of it (or none at all)
--   and press `<C-j>`. It should show picker with all snippets that have prefixes
--   matching typed characters (or all snippets if none was typed).
--   Choose one and its body should be inserted instead of previously typed text.
--
-- How to navigate during snippet session:
-- - Snippets can contain tabstops - places for user to interactively adjust text.
--   Each tabstop is highlighted depending on session progression - whether tabstop
--   is current, was or was not visited. If tabstop doesn't yet have text, it is
--   visualized with special "ghost" inline text: • and ∎ by default.
-- - Type necessary text at current tabstop and navigate to next/previous one
--   by pressing `<C-l>` / `<C-h>`.
-- - Repeat previous step until you reach special final tabstop, usually denoted
--   by ∎ symbol. If you spotted a mistake in an earlier tabstop, navigate to it
--   and return back to the final tabstop.
-- - To end a snippet session when at final tabstop, keep typing or go into
--   Normal mode. To force end snippet session, press `<C-c>`.
--
-- See also:
-- - `:h MiniSnippets-overview` - overview of how module works
-- - `:h MiniSnippets-examples` - examples of common setups
-- - `:h MiniSnippets-session` - details about snippet session
-- - `:h MiniSnippets.gen_loader` - list of available loaders
later(function()
  -- Define language patterns to work better with 'friendly-snippets'
  local snippets = require "mini.snippets"
  -- local match_strict = function(snips)
  --   -- Do not match with whitespace to cursor's left
  --   return snippets.default_match(snips, { pattern_fuzzy = '%S+' })
  -- end
  snippets.setup {
    snippets = {
      -- Always load 'snippets/global.json' from config directory
      snippets.gen_loader.from_file(vim.fn.stdpath "config" .. "/snippets/global.json"),
      -- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
      snippets.gen_loader.from_lang {},
      -- Load project-local snippets with `gen_loader.from_file()`
      -- and relative path (file doesn't have to be present)
      snippets.gen_loader.from_file ".vscode/project.code-snippets",
      -- Custom loader for language-specific project-local snippets
      function(context)
        local rel_path = ".vscode/" .. context.lang .. ".code-snippets"
        return vim.fn.filereadable(rel_path) == 1 and snippets.read_file(rel_path)
      end,
      -- Ensure that some prefixes are not used (as there is no `body`)
      { prefix = { "bad", "prefix" } },
    },
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      -- Expand snippet at cursor position. Created globally in Insert mode.
      expand = "",
      -- Interact with default `expand.insert` session.
      -- Created for the duration of active session(s)
      jump_next = "",
      jump_prev = "",
      stop = "<C-c>",
    },
    -- expand   = { match = match_strict },
  }
  -- By default snippets available at cursor are not shown as candidates in
  -- 'mini.completion' menu. This requires a dedicated in-process LSP server
  -- that will provide them. To have that, uncomment next line (use `gcc`).
  if MiniCompletion then MiniSnippets.start_lsp_server() end
end)

-- Split and join arguments (regions inside brackets between allowed separators).
-- It uses Lua patterns to find arguments, which means it works in comments and
-- strings but can be not as accurate as tree-sitter based solutions.
-- Each action can be configured with hooks (like add/remove trailing comma).
-- Example usage:
-- - `gS` - toggle between joined (all in one line) and split (each on a separate
--   line and indented) arguments. It is dot-repeatable (see `:h .`).
--
-- See also:
-- - `:h MiniSplitjoin.gen_hook` - list of available hooks
later(function()
  require("mini.splitjoin").setup {
    -- Module mappings. Use `''` (empty string) to disable one.
    -- Created for both Normal and Visual modes.
    mappings = { toggle = "gj", split = "", join = "" },

    -- Detection options: where split/join should be done
    detect = {
      -- Array of Lua patterns to detect region with arguments.
      -- Default: { '%b()', '%b[]', '%b{}' }
      brackets = { "%b()", "%b[]", "%b{}" },

      -- String Lua pattern defining argument separator
      separator = "[,;]",

      -- Array of Lua patterns for sub-regions to exclude separators from.
      -- Enables correct detection in presence of nested brackets and quotes.
      -- Default: { '%b()', '%b[]', '%b{}', '%b""', "%b''" }
      -- exclude_regions = nil,
    },

    -- Split options
    split = {
      hooks_pre = {},
      hooks_post = {},
    },

    -- Join options
    join = {
      hooks_pre = {},
      hooks_post = {},
    },
  }
end)

-- Surround actions: add/delete/replace/find/highlight. Working with surroundings
-- is surprisingly common: surround word with quotes, replace `)` with `]`, etc.
-- This module comes with many built-in surroundings, each identified by a single
-- character. It searches only for surrounding that covers cursor and comes with
-- a special "next" / "last" versions of actions to search forward or backward
-- (just like 'mini.ai'). All text editing actions are dot-repeatable (see `:h .`).
--
-- Example usage (this may feel intimidating at first, but after practice it
-- becomes second nature during text editing):
-- - `saiw)` - *s*urround *a*dd for *i*nside *w*ord parenthesis (`)`)
-- - `sdf`   - *s*urround *d*elete *f*unction call (like `f(var)` -> `var`)
-- - `srb[`  - *s*urround *r*eplace *b*racket (any of [], (), {}) with padded `[`
-- - `sf*`   - *s*urround *f*ind right part of `*` pair (like bold in markdown)
-- - `shf`   - *s*urround *h*ighlight current *f*unction call
-- - `srn{{` - *s*urround *r*eplace *n*ext curly bracket `{` with padded `{`
-- - `sdl'`  - *s*urround *d*elete *l*ast quote pair (`'`)
-- - `vaWsa<Space>` - *v*isually select *a*round *W*ORD and *s*urround *a*dd
--                    spaces (`<Space>`)
--
-- See also:
-- - `:h MiniSurround-builtin-surroundings` - list of all supported surroundings
-- - `:h MiniSurround-surrounding-specification` - examples of custom surroundings
-- - `:h MiniSurround-vim-surround-config` - alternative set of action mappings
later(function()
  require("mini.surround").setup {
    -- Add custom surroundings to be used on top of builtin ones. For more
    -- information with examples, see `:h MiniSurround.config`.
    -- custom_surroundings = nil,

    -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
    highlight_duration = 1000,

    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      add = "sa", -- Add surrounding in Normal and Visual modes
      delete = "sd", -- Delete surrounding
      find = "sf", -- Find surrounding (to the right)
      find_left = "sF", -- Find surrounding (to the left)
      highlight = "sh", -- Highlight surrounding
      replace = "sr", -- Replace surrounding

      suffix_last = "l", -- Suffix to search with "prev" method
      suffix_next = "n", -- Suffix to search with "next" method
    },

    -- Number of lines within which surrounding is searched
    n_lines = 20,

    -- Whether to respect selection type:
    -- - Place surroundings on separate lines in linewise mode.
    -- - Place surroundings on each line in blockwise mode.
    respect_selection_type = false,

    -- How to search for surrounding (first inside current line, then inside
    -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
    -- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
    -- see `:h MiniSurround.config`.
    search_method = "cover",

    -- Whether to disable showing non-error feedback
    -- This also affects (purely informational) helper messages shown after
    -- idle time if user input is required.
    silent = false,
  }
end)

-- Highlight and remove trailspace. Temporarily stops highlighting in Insert mode
-- to reduce noise when typing. Example usage:
-- - `<Leader>ot` - trim all trailing whitespace in a buffer
later(function()
  require("mini.trailspace").setup {
    -- Highlight only in normal buffers (ones with empty 'buftype'). This is
    -- useful to not show trailing whitespace where it usually doesn't matter.
    only_in_normal_buffers = true,
  }
end)
