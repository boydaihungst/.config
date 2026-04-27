_G.STARTUP_TIME = vim.uv.hrtime()
-- Disable unused built-in plugins
local disabled_builtins = {
  "gzip",
  "netrwPlugin",
  "tarPlugin",
  "tohtml",
  "zipPlugin",
}

for _, plugin in ipairs(disabled_builtins) do
  vim.g["loaded_" .. plugin] = 1
end

-- This makes nvim load faster
vim.loader.enable(true)
vim.lsp.log.set_level(vim.log.levels.ERROR)

-- User new ui2 to prevent error request for press enter to continue
local ui2_exist, ui2 = pcall(require, "vim._core.ui2")
if ui2_exist then
  ui2.enable {
    enable = true,
    msg = {
      -- Options related to the message module.
      ---@type 'cmd'|'msg' Default message target, either in the
      ---cmdline or in a separate ephemeral message window.
      ---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
      ---or table mapping |ui-messages| kinds and triggers to a target.
      targets = "cmd",
      cmd = { -- Options related to messages in the cmdline window.
        height = 0.5,
      }, -- Maximum height while expanded for messages beyond 'cmdheight'.
      dialog = { -- Options related to dialog window.
        height = 0.5,
      }, -- Maximum height.
      msg = {
        height = 0.5, -- Maximum height.
        timeout = 5000, -- Time a message is visible in the message window.
      },
      pager = { height = 0.5 }, -- Maximum height.
    },
  }
end

-- Import full environment from login shell. Useful for codecompanion to read API key from env
do
  local env = vim.fn.systemlist(vim.o.shell .. " -l -c env")
  for _, line in ipairs(env) do
    local k, v = line:match "([^=]+)=(.*)"
    if k and v then vim.env[k] = v end
  end
end

-- cd to project root on startup
local project_root = vim.fs.root(0, { ".nvim.lua", ".nvimrc", ".exrc" })
if project_root then vim.cmd.cd(project_root) end

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.icons_enabled = true

_G.Config = {
  default_lsp_signature_help = true,
  default_large_buf_opts = {
    -- Allow large files to be detected
    enabled = true,
    -- Notify when a large file is detected
    notify = true,
    -- The maximum size of a file in bytes. 2MB
    size = 1000 * 2000,
    -- The maximum number of lines in a file
    lines = 5000,
    -- The maximum average line length in a file
    line_length = 3000,
  },
  auto_chdir_root = true,
  -- Change current working directory based on the current file path. It
  -- searches up the file tree until the first root marker ('.git' or 'Makefile')
  -- and sets their parent directory as a current directory.
  -- This is helpful when simultaneously dealing with files from several projects.
  root_markers = {
    "nvim-pack-lock.json",
    ".git",
    "_darcs",
    ".hg",
    ".bzr",
    ".svn",
    "lua",
    "MakeFile",
    "package.json",
    "lazy-lock.json",
    "yazi.toml",
    "hyprland.conf",
  },
  -- LSP took priority over root_markers above
  -- Add the names of LSP servers you want to ignore here
  root_markers_lsp_servers_ignored = {
    ["copilot"] = true,
    ["null-ls"] = true,
    ["efm"] = true,
    ["dev-tools"] = true,
    ["taplo"] = true,
  },
  -- auto load project-local Plugins and LSP configurations
  enable_project_local_loader = true,

  -- Custom icons
  icons = {
    icons = {
      ActiveLSP = "",
      ActiveTS = "",
      ArrowLeft = "",
      ArrowRight = "",
      Bookmarks = "",
      BufferClose = "󰅖",
      DapBreakpoint = "",
      DapBreakpointCondition = "",
      DapBreakpointRejected = "",
      DapLogPoint = "󰛿",
      DapStopped = "󰁕",
      Debugger = "",
      DefaultFile = "󰈙",
      Diagnostic = "󰒡",
      DiagnosticError = "",
      DiagnosticHint = "󰌵",
      DiagnosticInfo = "󰋼",
      DiagnosticWarn = "",
      Ellipsis = "…",
      Environment = "",
      FileNew = "",
      FileModified = "",
      FileReadOnly = "",
      FoldClosed = "",
      FoldOpened = "",
      FoldSeparator = " ",
      FolderClosed = "",
      FolderEmpty = "",
      FolderOpen = "",
      Git = "󰊢",
      GitConflict = "",
      GitIgnored = "◌",
      GitRenamed = "➜",
      GitSign = "▎",
      GitStaged = "✓",
      GitUnstaged = "✗",
      GitUntracked = "★",
      List = "",
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
      MacroRecording = "",
      Package = "󰏖",
      Paste = "󰅌",
      Refresh = "",
      Search = "",
      Selected = "❯",
      Session = "󱂬",
      Sort = "󰒺",
      Spellcheck = "󰓆",
      Tab = "󰓩",
      TabClose = "󰅙",
      Terminal = "",
      Window = "",
      WordFile = "󰈭",
      VimIcon = "",
      ScrollText = "",
      GitBranch = "",
      GitAdd = "",
      GitChange = "",
      GitDelete = "",
      -- Custom plugins icon
      GrugFar = "󰛔",
      CommentBox = "󱋄",
      Markdown = "",
      Neogen = "󰷉",
      Tests = "󰗇",
      Watch = "",
      Octo = "",
      Overseer = "",
      VimVisualMulti = "󰵉",
      FolderTree = "",
      TabBar = "󰠷",
      OtherTools = "",
      CodeCompanion = "󱙺",
      Coverage = "",
    },
    text_icons = {
      ActiveLSP = "LSP:",
      ArrowLeft = "<",
      ArrowRight = ">",
      BufferClose = "x",
      DapBreakpoint = "B",
      DapBreakpointCondition = "C",
      DapBreakpointRejected = "R",
      DapLogPoint = "L",
      DapStopped = ">",
      DefaultFile = "[F]",
      DiagnosticError = "X",
      DiagnosticHint = "?",
      DiagnosticInfo = "i",
      DiagnosticWarn = "!",
      Ellipsis = "...",
      Environment = "Env:",
      FileModified = "*",
      FileReadOnly = "[lock]",
      FoldClosed = "+",
      FoldOpened = "-",
      FoldSeparator = " ",
      FolderClosed = "[D]",
      FolderEmpty = "[E]",
      FolderOpen = "[O]",
      GitAdd = "[+]",
      GitChange = "[/]",
      GitConflict = "[!]",
      GitDelete = "[-]",
      GitIgnored = "[I]",
      GitRenamed = "[R]",
      GitSign = "|",
      GitStaged = "[S]",
      GitUnstaged = "[U]",
      GitUntracked = "[?]",
      MacroRecording = "Recording:",
      Paste = "[PASTE]",
      Search = "?",
      Selected = "*",
      Spellcheck = "[SPELL]",
      TabClose = "X",
    },
  },
}

vim.pack.add { "https://github.com/nvim-mini/mini.nvim", "https://github.com/nvim-lua/plenary.nvim" }

-- Loading helpers used to organize config into fail-safe parts. Example usage:
-- - `now` - execute immediately. Use for what must be executed during startup.
--   Like colorscheme, statusline, tabline, dashboard, etc.
-- - `later` - execute a bit later. Use for things not needed during startup.
-- - `now_if_args` - use only if needed during startup when Neovim is started
--   like `nvim -- path/to/file`, but otherwise delaying is fine.
-- - Others are better used only if the above is not enough for good performance.
--   Use only if you are comfortable with adding complexity to your config:
--   - `on_event` - execute once on a first matched event. Like "delay until:
--     first Insert mode enter" (no pattern):
--        -`on_event('InsertEnter,BufEnter', function() ... end)`.
--     first BufEnter with pattern (with pattern):
--        - `on_event('BufEnter~package.json', function() ... end)`.
--     first BufEnter or BufReadPre with pattern (multiple events with multiple pattern):
--        - `on_event({'BufEnter', 'BufReadPre'}, {"package.json", "*.lua"}, function() ... end)`.
--        - `on_event('BufReadPre,BufEnter~package.json,*.lua', function() ... end)`.
--   - `on_filetype` - execute once on a first matched filetype. Like "delay
--     until first Lua file": `on_filetype('lua', function() ... end)`.
--
-- See also:
-- - `:h MiniMisc.safely()`
-- - 'plugin/30_mini.lua' and 'plugin/40_plugins.lua'
local misc = require "mini.misc"
_G.add = vim.pack.add
_G.now = function(f) misc.safely("now", f) end
_G.later = function(f) misc.safely("later", f) end
_G.now_if_args = vim.fn.argc(-1) > 0 and _G.now or _G.later
_G.on_event = function(ev, patt, f)
  if type(ev) == "table" then ev = table.concat(ev, ",") end
  if type(patt) == "table" then patt = table.concat(patt, ",") end
  if type(patt) == "function" then
    f = patt
    patt = nil
  end
  if not ev then return end
  misc.safely("event:" .. ev .. (patt and "~" .. patt or ""), f)
end
_G.on_filetype = function(ft, f)
  if type(ft) == "table" then ft = table.concat(ft, ",") end
  misc.safely("filetype:" .. ft, f)
end

local default_gr = vim.api.nvim_create_augroup("custom-config", { clear = true })
Config.new_autocmd = function(event, pattern, callback, desc, gr)
  if type(gr) == "string" then gr = vim.api.nvim_create_augroup(gr, { clear = true }) end
  local opts = { group = gr or default_gr, pattern = pattern, callback = callback, desc = desc }
  return vim.api.nvim_create_autocmd(event, opts)
end

--- Check if a buffer is valid
---@param bufnr? integer The buffer to check, default to current buffer
---@return boolean # Whether the buffer is valid or not
function Config.is_valid_buf(bufnr)
  if not bufnr then bufnr = 0 end
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

--- Get highlight properties for a given highlight name
---@param name string The highlight group name
---@param fallback? table The fallback highlight properties
---@return table properties # the highlight group properties
function Config.get_hlgroup(name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if not hl.fg then hl.fg = "NONE" end
    if not hl.bg then hl.bg = "NONE" end
    if hl.reverse then
      hl.fg, hl.bg, hl.reverse = hl.bg, hl.fg, nil
    end
    return hl
  end
  return fallback or {}
end

--- Get an icon from the internal icons if it is available and return it
---@param kind string The kind of icon in Config.icons to retrieve
---@param padding? integer Padding to add to the end of the icon
---@param no_fallback? boolean Whether or not to disable fallback to text icon
---@return string icon
function Config.get_custom_icon(kind, padding, no_fallback)
  local icons_enabled = vim.g.icons_enabled ~= false
  if not icons_enabled and no_fallback then return "" end
  local icon_pack = assert(Config.icons[icons_enabled and "icons" or "text_icons"])
  local icon = icon_pack[kind]
  return icon and icon .. (" "):rep(padding or 0) or ""
end

--- Get a icon spinner table if it is available in the internal icons. Icons in format `kind1`,`kind2`, `kind3`, ...
---@param kind string The kind of icon to check for sequential entries of
---@return string[]|nil spinners # A collected table of spinning icons in sequential order or nil if none exist
function Config.get_spinner(kind, ...)
  local spinner = {}
  repeat
    local icon = Config.get_custom_icon(("%s%d"):format(kind, #spinner + 1), ...)
    if icon ~= "" then table.insert(spinner, icon) end
  until not icon or icon == ""
  if #spinner > 0 then return spinner end
end

function Config.extend_hl(name, data)
  local old_hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local new_hl = vim.tbl_extend("force", old_hl, data)
  vim.api.nvim_set_hl(0, name, new_hl)
end

local large_buf_cache, buf_size_cache = {}, {} -- cache large buffer detection results and buffer sizes
---@class CoreMaxFile
---@field enabled (boolean|fun(bufnr: integer, config: CoreMaxFile):boolean|CoreMaxFile?)? whether to enable large file detection
---@field notify boolean? whether or not to display a notification when a large file is detected
---@field size integer|false? the number of bytes in a file or false to disable check
---@field lines integer|false? the number of lines in a file or false to disable check
---@field line_length integer|false? the average line length in a file or false to disable check

--- Check if a buffer is a large buffer (always returns false if large buffer detection is disabled)
---@param bufnr? integer the buffer to check the size of, default to current buffer
---@param large_buf_opts? CoreMaxFile large buffer parameters, default configuration
---@return boolean is_large whether the buffer is detected as large or not
function Config.is_large(bufnr, large_buf_opts, event)
  if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
  -- always return not large until buffer is loaded, do not cache decision
  if not vim.api.nvim_buf_is_loaded(bufnr) and event ~= "BufReadPre" then return false end
  local skip_cache = large_buf_opts ~= nil -- skip cache when called manually with custom options
  if not large_buf_opts then large_buf_opts = Config.default_large_buf_opts end
  if large_buf_opts then
    if skip_cache or large_buf_cache[bufnr] == nil then
      local enabled = vim.tbl_get(large_buf_opts, "enabled")
      if type(enabled) == "function" then
        large_buf_opts = vim.deepcopy(large_buf_opts)
        enabled = enabled(bufnr, large_buf_opts)
        if type(enabled) == "table" then large_buf_opts = enabled end
      end
      local large_buf = false
      if vim.F.if_nil(enabled, true) then
        if not buf_size_cache[bufnr] then
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          buf_size_cache[bufnr] = ok and stats and stats.size or 0
        end
        local file_size = buf_size_cache[bufnr]
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if event == "BufReadPre" and (large_buf_opts.line_length or large_buf_opts.lines) then
          line_count = #vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr), "", large_buf_opts.line_length) -- read first line_length lines
        end
        local too_large = large_buf_opts.size and file_size > large_buf_opts.size
        local too_long = large_buf_opts.lines and line_count > large_buf_opts.lines
        local too_wide = large_buf_opts.line_length and (file_size / line_count) - 1 > large_buf_opts.line_length
        large_buf = too_large or too_long or too_wide or false
      end
      if skip_cache then return large_buf end
      large_buf_cache[bufnr] = large_buf
    end
    return large_buf_cache[bufnr]
  end
  return false
end

function vim.tbl_to_set(array)
  local set = {}
  for _, v in ipairs(array) do
    local _v = tostring(v)
    set[_v] = true
  end
  return set
end

--- Extend string table with another string table, value is unique
---@param base table table to extend
---@param extra table table contain new values
---@return table
function vim.tbl_unique_extend(base, extra)
  local seen = {}
  local result = {}

  -- Mark existing items as seen
  for _, v in ipairs(base) do
    if not seen[v] then
      table.insert(result, v)
      seen[v] = true
    end
  end

  -- Add new items only if not seen
  for _, v in ipairs(extra) do
    if not seen[v] then
      table.insert(result, v)
      seen[v] = true
    end
  end

  return result
end

vim.pack.is_available = function(pkg)
  local loaded = package.loaded and package.loaded[pkg]
  if loaded then return true end
  local result, _ = pcall(vim.pack.get, { pkg })
  return result
end

vim.pack.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd("PackChanged", "*", f, desc)
end

vim.api.nvim_get_buffers_rel_path = function(path)
  path = vim.fn.fnamemodify(path, ":p") -- normalize to absolute path
  local matched_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.fs.relpath(path, vim.fn.fnamemodify(name, ":p")) then
        matched_buffers[#matched_buffers + 1] = buf
      end
    end
  end
  return matched_buffers
end

vim.api.nvim_get_buffers_by_path = function(path)
  path = vim.fn.fnamemodify(path, ":p") -- normalize to absolute path
  local matched_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.fn.fnamemodify(name, ":p") == path then matched_buffers[#matched_buffers + 1] = buf end
    end
  end
  return matched_buffers
end

vim.api.nvim_get_win_by_var = function(var_name)
  -- Iterate through all windows in the current tabpage
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- Check if the variable exists in this window's scope
    local success, value = pcall(vim.api.nvim_win_get_var, winid, var_name)
    if success then return winid, value end
  end
  return nil
end
string.to_litteral = function(str) return str and str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") end

vim.diagnostic.config {
  -- use tiny-inline-diagnostic.nvim instead
  virtual_lines = false,
  virtual_text = false,

  update_in_insert = false,
  float = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = Config.get_custom_icon "DiagnosticError",
      [vim.diagnostic.severity.HINT] = Config.get_custom_icon "DiagnosticHint",
      [vim.diagnostic.severity.WARN] = Config.get_custom_icon "DiagnosticWarn",
      [vim.diagnostic.severity.INFO] = Config.get_custom_icon "DiagnosticInfo",
    },
  },
}

vim.lsp.inlay_hint.enable(false)
vim.lsp.semantic_tokens.enable(true)
vim.lsp.linked_editing_range.enable(true)
if vim.lsp.codelens.enable then vim.lsp.codelens.enable(true) end
vim.lsp.inline_completion.enable(true)
vim.lsp.on_type_formatting.enable(false)
vim.lsp.protocol.make_client_capabilities()
vim.lsp.config("*", {
  capabilities = {
    textDocument = {
      -- Force enable callHierarchy to use with lspsaga
      callHierarchy = {
        dynamicRegistration = true,
      },
    },
  },
})

if vim.lsp.inline_completion.is_enabled() then
  Config.new_autocmd("LspAttach", nil, function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method "textDocument/inlineCompletion" then
      vim.keymap.set(
        "i",
        "<C-l>",
        function() vim.lsp.inline_completion.get() end,
        { desc = "Accept inline completion" }
      )

      -- Switch to previous inline completion
      vim.keymap.set(
        "i",
        "<C-[>",
        function() vim.lsp.inline_completion.select { wrap = true, count = -1 } end,
        { desc = "Switch to previous inline completion" }
      )

      -- Switch to next inline completion
      vim.keymap.set(
        "i",
        "<C-]>",
        function() vim.lsp.inline_completion.select { wrap = true, count = 1 } end,
        { desc = "Switch to next inline completion" }
      )
      vim.api.nvim_del_augroup_by_name "nvim-inline-completion"
    end
  end, "Set keymaps for when a lsp support ", "nvim-inline-completion")
end
if Config.enable_project_local_loader then require("project-local-loader").setup() end

vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function(args)
    if Config.is_large(args.buf, nil, "BufReadPre") then
      -- Disable heavy features
      if vim.fn.exists ":NoMatchParen" ~= 0 then vim.cmd [[NoMatchParen]] end
      require("snacks").util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })

      vim.bo.autocomplete = false
      vim.b.completion = false

      vim.b.minianimate_disable = true
      vim.b.minihipatterns_disable = true
      vim.b.minimap_disable = true
      vim.diagnostic.enable(false, { bufnr = args.buf })
      vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
      vim.lsp.semantic_tokens.enable(false, { bufnr = args.buf })
      vim.lsp.linked_editing_range.enable(false, { bufnr = args.buf })
      if vim.lsp.codelens.enable then vim.lsp.codelens.enable(false, { bufnr = args.buf }) end
      vim.lsp.inline_completion.enable(false, { bufnr = args.buf })
      vim.lsp.on_type_formatting.enable(false, { bufnr = args.buf })

      vim.opt_local.filetype = "largefile"
      vim.opt_local.wrap = false
      vim.opt_local.syntax = "off"
      vim.opt_local.spell = false
      vim.opt_local.undofile = false
      vim.opt_local.swapfile = false

      vim.opt_local.undolevels = -1
      vim.opt_local.undoreload = 0
      vim.opt_local.list = false
      vim.schedule(function()
        vim.treesitter.stop(args.buf)
        vim.opt_local.filetype = "largefile"
      end)
      if Config.default_large_buf_opts.notify then
        vim.schedule(
          function()
            vim.notify(
              "Large file detected: Heavy features disabled" .. vim.api.nvim_buf_get_name(args.buf),
              vim.log.levels.WARN
            )
          end
        )
      end
    end
  end,
})
