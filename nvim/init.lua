vim.loader.enable(true)
vim.lsp.log.set_level(vim.log.levels.ERROR)

-- Import full environment from login shell
do
  local env = vim.fn.systemlist(vim.o.shell .. ' -l -c env')
  for _, line in ipairs(env) do
    local k, v = line:match '([^=]+)=(.*)'
    if k and v then vim.env[k] = v end
  end
end

local project_root = vim.fs.root(0, { '.lazy.lua', '.nvim.lua', '.nvimrc', '.exrc' })
if project_root then vim.cmd.cd(project_root) end
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.icons_enabled = true

_G.Config = {}

vim.pack.add { 'https://github.com/nvim-mini/mini.nvim', 'https://github.com/nvim-lua/plenary.nvim' }

-- Loading helpers used to organize config into fail-safe parts. Example usage:
-- - `now` - execute immediately. Use for what must be executed during startup.
--   Like colorscheme, statusline, tabline, dashboard, etc.
-- - `later` - execute a bit later. Use for things not needed during startup.
-- - `now_if_args` - use only if needed during startup when Neovim is started
--   like `nvim -- path/to/file`, but otherwise delaying is fine.
-- - Others are better used only if the above is not enough for good performance.
--   Use only if you are comfortable with adding complexity to your config:
--   - `on_event` - execute once on a first matched event. Like "delay until
--     first Insert mode enter": `on_event('InsertEnter', function() ... end)`.
--   - `on_filetype` - execute once on a first matched filetype. Like "delay
--     until first Lua file": `on_filetype('lua', function() ... end)`.
--
-- See also:
-- - `:h MiniMisc.safely()`
-- - 'plugin/30_mini.lua' and 'plugin/40_plugins.lua'
local misc = require 'mini.misc'
Config.now = function(f) misc.safely('now', f) end
Config.later = function(f) misc.safely('later', f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event = function(ev, f) misc.safely('event:' .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely('filetype:' .. ft, f) end

local default_gr = vim.api.nvim_create_augroup('custom-config', { clear = true })
Config.new_autocmd = function(event, pattern, callback, desc, gr)
  local opts = { group = default_gr, pattern = pattern, callback = callback, desc = desc }
  return vim.api.nvim_create_autocmd(event, opts)
end

Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd('PackChanged', '*', f, desc)
end

-- Custom icons
Config.icons = {
  icons = {
    ActiveLSP = '',
    ActiveTS = '',
    ArrowLeft = '',
    ArrowRight = '',
    Bookmarks = '',
    BufferClose = '󰅖',
    DapBreakpoint = '',
    DapBreakpointCondition = '',
    DapBreakpointRejected = '',
    DapLogPoint = '󰛿',
    DapStopped = '󰁕',
    Debugger = '',
    DefaultFile = '󰈙',
    Diagnostic = '󰒡',
    DiagnosticError = '',
    DiagnosticHint = '󰌵',
    DiagnosticInfo = '󰋼',
    DiagnosticWarn = '',
    Ellipsis = '…',
    Environment = '',
    FileNew = '',
    FileModified = '',
    FileReadOnly = '',
    FoldClosed = '',
    FoldOpened = '',
    FoldSeparator = ' ',
    FolderClosed = '',
    FolderEmpty = '',
    FolderOpen = '',
    Git = '󰊢',
    GitConflict = '',
    GitIgnored = '◌',
    GitRenamed = '➜',
    GitSign = '▎',
    GitStaged = '✓',
    GitUnstaged = '✗',
    GitUntracked = '★',
    List = '',
    LSPLoading1 = '⠋',
    LSPLoading2 = '⠙',
    LSPLoading3 = '⠹',
    LSPLoading4 = '⠸',
    LSPLoading5 = '⠼',
    LSPLoading6 = '⠴',
    LSPLoading7 = '⠦',
    LSPLoading8 = '⠧',
    LSPLoading9 = '⠇',
    LSPLoading10 = '⠏',
    MacroRecording = '',
    Package = '󰏖',
    Paste = '󰅌',
    Refresh = '',
    Search = '',
    Selected = '❯',
    Session = '󱂬',
    Sort = '󰒺',
    Spellcheck = '󰓆',
    Tab = '󰓩',
    TabClose = '󰅙',
    Terminal = '',
    Window = '',
    WordFile = '󰈭',
    VimIcon = '',
    ScrollText = '',
    GitBranch = '',
    GitAdd = '',
    GitChange = '',
    GitDelete = '',
  },
  text_icons = {
    ActiveLSP = 'LSP:',
    ArrowLeft = '<',
    ArrowRight = '>',
    BufferClose = 'x',
    DapBreakpoint = 'B',
    DapBreakpointCondition = 'C',
    DapBreakpointRejected = 'R',
    DapLogPoint = 'L',
    DapStopped = '>',
    DefaultFile = '[F]',
    DiagnosticError = 'X',
    DiagnosticHint = '?',
    DiagnosticInfo = 'i',
    DiagnosticWarn = '!',
    Ellipsis = '...',
    Environment = 'Env:',
    FileModified = '*',
    FileReadOnly = '[lock]',
    FoldClosed = '+',
    FoldOpened = '-',
    FoldSeparator = ' ',
    FolderClosed = '[D]',
    FolderEmpty = '[E]',
    FolderOpen = '[O]',
    GitAdd = '[+]',
    GitChange = '[/]',
    GitConflict = '[!]',
    GitDelete = '[-]',
    GitIgnored = '[I]',
    GitRenamed = '[R]',
    GitSign = '|',
    GitStaged = '[S]',
    GitUnstaged = '[U]',
    GitUntracked = '[?]',
    MacroRecording = 'Recording:',
    Paste = '[PASTE]',
    Search = '?',
    Selected = '*',
    Spellcheck = '[SPELL]',
    TabClose = 'X',
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
    if not hl.fg then hl.fg = 'NONE' end
    if not hl.bg then hl.bg = 'NONE' end
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
  if not icons_enabled and no_fallback then return '' end
  local icon_pack = assert(Config.icons[icons_enabled and 'icons' or 'text_icons'])
  local icon = icon_pack[kind]
  return icon and icon .. (' '):rep(padding or 0) or ''
end
--- Get a icon spinner table if it is available in the AstroNvim icons. Icons in format `kind1`,`kind2`, `kind3`, ...
---@param kind string The kind of icon to check for sequential entries of
---@return string[]|nil spinners # A collected table of spinning icons in sequential order or nil if none exist
function Config.get_spinner(kind, ...)
  local spinner = {}
  repeat
    local icon = Config.get_custom_icon(('%s%d'):format(kind, #spinner + 1), ...)
    if icon ~= '' then table.insert(spinner, icon) end
  until not icon or icon == ''
  if #spinner > 0 then return spinner end
end

function Config.extend_hl(name, data)
  local old_hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local new_hl = vim.tbl_extend('force', old_hl, data)
  vim.api.nvim_set_hl(0, name, new_hl)
end

function vim.tbl_to_set(array)
  local set = {}
  for _, v in ipairs(array) do
    local _v = tostring(v)
    set[_v] = true
  end
  return set
end

-- vim: ts=2 sts=2 sw=2 et
