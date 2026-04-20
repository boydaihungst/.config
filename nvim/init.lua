_G.STARTUP_TIME = vim.uv.hrtime()
-- Disable built-in plugins
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
vim.loader.enable(true)
vim.lsp.log.set_level(vim.log.levels.ERROR)
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

-- Import full environment from login shell
do
  local env = vim.fn.systemlist(vim.o.shell .. " -l -c env")
  for _, line in ipairs(env) do
    local k, v = line:match "([^=]+)=(.*)"
    if k and v then vim.env[k] = v end
  end
end

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
--   - `on_event` - execute once on a first matched event. Like "delay until
--     first Insert mode enter": `on_event('InsertEnter,BufEnter', function() ... end)`.
--   - `on_filetype` - execute once on a first matched filetype. Like "delay
--     until first Lua file": `on_filetype('lua', function() ... end)`.
--
-- See also:
-- - `:h MiniMisc.safely()`
-- - 'plugin/30_mini.lua' and 'plugin/40_plugins.lua'
local misc = require "mini.misc"
Config.now = function(f) misc.safely("now", f) end
Config.later = function(f) misc.safely("later", f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event = function(ev, f) misc.safely("event:" .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely("filetype:" .. ft, f) end

local default_gr = vim.api.nvim_create_augroup("custom-config", { clear = true })
Config.new_autocmd = function(event, pattern, callback, desc, gr)
  local opts = { group = gr or default_gr, pattern = pattern, callback = callback, desc = desc }
  return vim.api.nvim_create_autocmd(event, opts)
end

Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd("PackChanged", "*", f, desc)
end

-- Custom icons
Config.icons = {
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
}
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

--- Get an icon from the AstroNvim internal icons if it is available and return it
---@param kind string The kind of icon in astroui.icons to retrieve
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

--- Get a icon spinner table if it is available in the AstroNvim icons. Icons in format `kind1`,`kind2`, `kind3`, ...
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
Config.default_large_buf_opts = {
  -- Allow large files to be detected
  enabled = true,
  -- Notify when a large file is detected
  notify = true,
  -- The maximum size of a file in bytes. 2MB
  size = 1000 * 2000,
  -- The maximum number of lines in a file
  lines = 10000,
  -- The maximum average line length in a file
  line_length = 1000,
}

---@class AstroCoreMaxFile
---@field enabled (boolean|fun(bufnr: integer, config: AstroCoreMaxFile):boolean|AstroCoreMaxFile?)? whether to enable large file detection
---@field notify boolean? whether or not to display a notification when a large file is detected
---@field size integer|false? the number of bytes in a file or false to disable check
---@field lines integer|false? the number of lines in a file or false to disable check
---@field line_length integer|false? the average line length in a file or false to disable check

--- Check if a buffer is a large buffer (always returns false if large buffer detection is disabled)
---@param bufnr? integer the buffer to check the size of, default to current buffer
---@param large_buf_opts? AstroCoreMaxFile large buffer parameters, default to AstroCore configuration
---@return boolean is_large whether the buffer is detected as large or not
function Config.is_large(bufnr, large_buf_opts)
  if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
  -- always return not large until buffer is loaded, do not cache decision
  if not vim.api.nvim_buf_is_loaded(bufnr) then return false end
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

vim.pack.is_available = function(pkg) return pcall(require, pkg) end

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

local function enable_lsp_feature(feature)
  if not vim.lsp[feature] then vim.lsp[feature].enable(true) end
end

vim.lsp.inlay_hint.enable(false)
vim.lsp.semantic_tokens.enable(true)
vim.lsp.linked_editing_range.enable(true)
vim.lsp.codelens.enable(true)
vim.lsp.inline_completion.enable(true)
vim.lsp.on_type_formatting.enable(false)
vim.lsp.config("*", {
  capabilities = {
    textDocument = {
      -- TODO: python won't work Wait till this PR is merged https://github.com/neovim/neovim/pull/35578
      -- This is because require('blink.cmp').get_lsp_capabilities() doesn't set the necessary capability for onTypeFormatting.
      -- onTypeFormatting = { dynamicRegistration = false },

      -- Force enable callHierarchy
      callHierarchy = {
        dynamicRegistration = true,
      },
    },
  },
})
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

-- vim: ts=2 sts=2 sw=2 et
