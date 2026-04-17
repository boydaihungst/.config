vim.filetype.add {
  extension = {
    rasi = 'rasi',
    rofi = 'rasi',
    wofi = 'rasi',
    props = 'msbuild',
    tasks = 'msbuild',
    targets = 'msbuild',
  },
  filename = {
    ['vifmrc'] = 'vim',
    ['mpv.conf'] = 'editorconfig',
  },
  pattern = {
    ['.*/waybar/config.*'] = 'jsonc',
    ['.*/mako/config'] = 'dosini',
    ['.*/dunst/dunstrc'] = 'dosini',
    ['.*/ghostty/.*'] = 'toml',
    ['.*/kitty/.+%.conf'] = 'kitty',
    -- [".*/hypr/.+%.conf"] = "hyprlang",
    ['.*/sway/.+%.conf'] = 'swayconfig',
    ['%.env%.[%w_.-]+'] = 'sh',
    ['.*%..*proj'] = 'msbuild',
  },
}
vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = Config.get_custom_icon 'DiagnosticError',
      [vim.diagnostic.severity.HINT] = Config.get_custom_icon 'DiagnosticHint',
      [vim.diagnostic.severity.WARN] = Config.get_custom_icon 'DiagnosticWarn',
      [vim.diagnostic.severity.INFO] = Config.get_custom_icon 'DiagnosticInfo',
    },
  },
}

vim.cmd 'filetype plugin indent on'
vim.g.markdown_recommended_style = 0
vim.g.health = { style = 'float' }

-- Use osc52 on ssh terminals. Disable osc 52 pasting, not supported by weztern
if os.getenv 'SSH_TTY' then
  vim.o.clipboard = 'unnamedplus'
  local function paste()
    return {
      vim.fn.split(vim.fn.getreg '', '\n'),
      vim.fn.getregtype '',
    }
  end

  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy '+',
      ['*'] = require('vim.ui.clipboard.osc52').copy '*',
    },
    paste = {
      ['+'] = paste,
      ['*'] = paste,
    },
  }
else
  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.schedule(function() vim.opt.clipboard = 'unnamed,unnamedplus' end)
end
vim.o.foldmethod = 'expr'
-- Use 25_folding.lua folding
vim.o.foldexpr = 'v:lua.Folding.foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.mouse = 'h'
vim.opt.whichwrap = 'lh' -- allow horizontal and vertical movement

vim.opt.list = true
-- Tab chars for indentation: check mini.indentscope
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', extends = '»', precedes = '«' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
vim.opt.backspace = vim.list_extend(vim.opt.backspace:get(), { 'nostop' }) -- don't stop backspace at insert
vim.opt.breakindent = true -- wrap indent to match  line start
vim.opt.cmdheight = 1 -- hide command line unless needed
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'fuzzy', 'nosort' } -- Options for insert mode completion
vim.opt.confirm = true -- raise a dialog asking if you wish to save the current file(s)
vim.opt.copyindent = true -- copy the previous indentation on autoindenting
vim.opt.cursorline = true -- highlight the text line of the cursor
vim.opt.diffopt = vim.list_extend(vim.opt.diffopt:get(), { 'algorithm:histogram', 'linematch:60' }) -- enable linematch diff algorithm
vim.opt.expandtab = true -- enable the use of space in tab
vim.opt.fillchars = {
  eob = ' ',
  foldopen = Config.get_custom_icon 'FoldOpened', -- fold open icon
  foldclose = Config.get_custom_icon 'FoldClosed', -- fold close icon
  foldsep = Config.get_custom_icon 'FoldSeparator', -- fold separator
  foldinner = Config.get_custom_icon 'FoldSeparator', -- nested fold separator
} -- disable `~` on nonexistent lines
vim.opt.ignorecase = true -- case insensitive searching
vim.opt.infercase = true -- infer cases in keyword completion
vim.opt.jumpoptions = {} -- apply no jumpoptions on startup
vim.opt.laststatus = 3 -- global statusline
vim.opt.linebreak = true -- wrap lines at 'breakat'
vim.opt.number = true -- show numberline
vim.opt.preserveindent = true -- preserve indent structure as much as possible
vim.opt.pumheight = 10 -- height of the pop up menu
vim.opt.relativenumber = true -- show relative numberline
vim.opt.shiftround = true -- round indentation with `>`/`<` to shiftwidth
vim.opt.shiftwidth = 0 -- number of space inserted for indentation; when zero the 'tabstop' value will be used
vim.opt.shortmess = vim.tbl_deep_extend('force', vim.opt.shortmess:get(), { s = true, I = true, c = true, C = true }) -- disable search count wrap, startup messages, and completion messages
vim.opt.showmode = false -- disable showing modes in command line
vim.opt.showtabline = 2 -- always display tabline
vim.opt.signcolumn = 'yes' -- always show the sign column
vim.opt.smartcase = true -- case sensitive searching
vim.opt.splitbelow = true -- splitting a new window below the current one
vim.opt.splitright = true -- splitting a new window at the right of the current one
vim.opt.tabclose = 'uselast' -- go to last used tab when closing the current tab
vim.opt.tabstop = 2 -- number of space in a tab
vim.opt.termguicolors = true -- enable 24-bit RGB color in the TUI
vim.opt.timeoutlen = 300 -- shorten key timeout length a little bit for which-key
vim.opt.title = true -- set terminal title to the filename and path
vim.opt.undofile = true -- enable persistent undo
vim.opt.updatetime = 250 -- length of time to wait before triggering the plugin
vim.opt.virtualedit = 'block' -- allow going past end of line in visual block mode
vim.opt.winborder = 'rounded' -- set default winborder to rounded
vim.opt.pumborder = 'rounded' -- set default popup window border to rounded (e.g: autocomplete)
vim.opt.wrap = true -- wrapping of lines longer than the width of window
vim.opt.writebackup = false -- disable making a backup before overwriting a file
vim.opt.shada = "'100,<50,s10,:1000,/100,@100,h"
vim.opt.conceallevel = 2
vim.opt.exrc = true
vim.opt.secure = true
-- vim: ts=2 sts=2 sw=2 et
