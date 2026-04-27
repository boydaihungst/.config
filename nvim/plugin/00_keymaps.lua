-- ┌─────────────────┐
-- │ Custom mappings │
-- └─────────────────┘
--
-- This file contains definitions of custom general and Leader mappings.

-- General mappings ===========================================================

-- Use this section to add custom general mappings. See `:h vim.keymap.set()`.

-- An example helper to create a Normal mode mapping
local nmap = function(lhs, rhs, desc)
  -- See `:h vim.keymap.set()`
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

-- Paste linewise before/after current line
-- Usage: `yiw` to yank a word and `]p` to put it on the next line.
nmap("[p", '<Cmd>exe "iput! " . v:register<CR>', "Paste Above")
nmap("]p", '<Cmd>exe "iput "  . v:register<CR>', "Paste Below")
nmap("H", '<Cmd>lua MiniBracketed.buffer("backward")<CR>', "Prev buffer")
nmap("L", '<Cmd>lua MiniBracketed.buffer("forward")<CR>', "Next buffer")
nmap("gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Below")
nmap("gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Above")

-- Helpers for a more concise `<Leader>` mappings.
-- Most of the mappings use `<Cmd>...<CR>` string as a right hand side (RHS) in
-- an attempt to be more concise yet descriptive. See `:h <Cmd>`.
-- This approach also doesn't require the underlying commands/functions to exist
-- during mapping creation: a "lazy loading" approach to improve startup time.
local nmap_leader = function(suffixes, rhs, desc)
  if type(suffixes) == "table" then
    for _, s in ipairs(suffixes) do
      if type(s) == "string" then vim.keymap.set("n", "<Leader>" .. s, rhs, { desc = desc }) end
    end
  else
    vim.keymap.set("n", "<Leader>" .. suffixes, rhs, { desc = desc })
  end
end
local xmap_leader = function(suffixes, rhs, desc)
  if type(suffixes) == "table" then
    for s in suffixes do
      if type(s) == "string" then vim.keymap.set("x", "<Leader>" .. s, rhs, { desc = desc }) end
    end
  else
    vim.keymap.set("x", "<Leader>" .. suffixes, rhs, { desc = desc })
  end
end

-- b is for 'Buffer'. Common usage:
-- - `<Leader>bs` - create scratch (temporary) buffer
-- - `<Leader>ba` - navigate to the alternative buffer
-- - `<Leader>bw` - wipeout (fully delete) current buffer
local new_scratch_buffer = function() vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true)) end

--- Helper function to power a save confirmation prompt before `mini.bufremove`
---@param func fun(bufnr:integer,force:boolean?) The function to execute if confirmation is passed
---@param bufnr integer The buffer to close or the current buffer if not provided
---@param force? boolean Whether or not to foce close the buffers or confirm changes (default: false)
local function mini_confirm(func, bufnr, force)
  if not force and vim.bo[bufnr].modified then
    local bufname = vim.fn.expand "%"
    local empty = bufname == ""
    if empty then bufname = "Untitled" end
    local confirm = vim.fn.confirm(('Save changes to "%s"?'):format(bufname), "&Yes\n&No\n&Cancel", 1, "Question")
    if confirm == 1 then
      if empty then return end
      vim.cmd.write()
    elseif confirm == 2 then
      force = true
    else
      return
    end
  end
  func(bufnr, force)
end

--- Close a given buffer
---@param bufnr? integer The buffer to close or the current buffer if not provided
---@param force? boolean Whether or not to foce close the buffers or confirm changes (default: false)
function Config.close_buffer(bufnr, force)
  if not bufnr or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if Config.is_valid_buf(bufnr) and #vim.t.bufs > 1 then
    if vim.pack.is_available "snacks.nvim" then
      require("snacks").bufdelete { buf = bufnr, force = force }
      return
    end
    if vim.pack.is_available "mini.nvim" or vim.pack.is_available "mini.bufremove" then
      mini_confirm(require("mini.bufremove").delete, bufnr, force)
      return
    end
  end
  -- fallback
  local buftype = vim.bo[bufnr].buftype
  vim.cmd(("silent! %s %d"):format((force or buftype == "terminal") and "bdelete!" or "confirm bdelete", bufnr))
end

--- Fully wipeout a given buffer
---@param bufnr? integer The buffer to wipe or the current buffer if not provided
---@param force? boolean Whether or not to foce close the buffers or confirm changes (default: false)
local function wipe(bufnr, force)
  if not bufnr or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if Config.is_valid_buf(bufnr) and #vim.t.bufs > 1 then
    if vim.pack.is_available "snacks.nvim" then
      return require("snacks").bufdelete { buf = bufnr, force = force, wipe = true }
    end
    if vim.pack.is_available "mini.nvim" or vim.pack.is_available "mini.bufremove" then
      return mini_confirm(require("mini.bufremove").wipeout, bufnr, force)
    end
  end
  -- fallback
  local buftype = vim.bo[bufnr].buftype
  vim.cmd(("silent! %s %d"):format((force or buftype == "terminal") and "bwipeout!" or "confirm bwipeout", bufnr))
end

--- Close all buffers
---@param keep_current? boolean Whether or not to keep the current buffer (default: false)
---@param force? boolean Whether or not to foce close the buffers or confirm changes (default: false)
local function close_all(keep_current, force)
  if keep_current == nil then keep_current = false end
  local current = vim.api.nvim_get_current_buf()
  for _, bufnr in ipairs(vim.t.bufs) do
    if not keep_current or bufnr ~= current then Config.close_buffer(bufnr, force) end
  end
end

--- Close buffers to the left of the current buffer
---@param force? boolean Whether or not to foce close the buffers or confirm changes (default: false)
local function close_left(force)
  local current = vim.api.nvim_get_current_buf()
  for _, bufnr in ipairs(vim.t.bufs) do
    if bufnr == current then break end
    Config.close_buffer(bufnr, force)
  end
end

--- Close buffers to the right of the current buffer
---@param force? boolean Whether or not to foce close the buffers or confirm changes (default: false)
local function close_right(force)
  local current = vim.api.nvim_get_current_buf()
  local after_current = false
  for _, bufnr in ipairs(vim.t.bufs) do
    if after_current then Config.close_buffer(bufnr, force) end
    if bufnr == current then after_current = true end
  end
end

nmap_leader("q", "<Cmd>confirm qall<CR>", "Quit")
nmap_leader("bp", "<Cmd>b#<CR>", "Prev buffer")
nmap_leader("bd", Config.close_buffer, "Close current buffer")
nmap_leader("bc", function() close_all(true) end, "Close all buffer except current")
nmap_leader("bC", close_all, "Close all buffer")
nmap_leader("bh", close_left, "Close all left buffers")
nmap_leader("bl", close_right, "Close all right buffers")
nmap_leader("bs", new_scratch_buffer, "New scratch buffer")
nmap_leader("bn", "<Cmd>enew<CR>", "New buffer")
nmap_leader("bw", wipe, "Wipeout")
nmap_leader("c", Config.close_buffer, "Close/Delete buffer")

nmap_leader(
  "pu",
  "<Cmd>MasonUpdate<CR>:<Cmd>MasonToolsUpdate<CR>:<Cmd>TSUpdate<CR>:<Cmd>Pack update-all<CR>",
  "Update All"
)
nmap_leader("pp", "<Cmd>Pack<CR>", "Plugins")
nmap_leader("pm", "<Cmd>Mason<CR>", "Mason")
nmap_leader("pt", "<Cmd>TSUpdate<CR>", "Treesitter Update")

vim.keymap.set({ "i", "s" }, "<C-s>", function()
  if Config.default_lsp_signature_help then
    local win, _ = vim.api.nvim_get_win_by_var "lsp_floating_bufnr"
    if win and vim.api.nvim_win_is_valid(win) and vim.fn.pumvisible() == 0 then
      vim.api.nvim_win_set_config(win, {
        focusable = true,
      })
      Config.new_autocmd("TextChanged", nil, function()
        win, _ = vim.api.nvim_get_win_by_var "lsp_floating_bufnr"
        if win and vim.api.nvim_win_is_valid(win) and vim.fn.pumvisible() == 0 then
          local bufnr = vim.api.nvim_win_get_buf(win)
          if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
            local bufnr_line_count = vim.api.nvim_buf_line_count(bufnr)
            vim.api.nvim_win_set_height(win, math.min(bufnr_line_count, 15))
            vim.api.nvim_win_call(win, function() vim.cmd "set concealcursor=niv" end)
          end
        end
      end, "Set concealcursor sign window")
    end
  end
  vim.lsp.buf.signature_help {}
end, { desc = "Show sign_help help" }) -- don't use "signature" word on desc because it will be replaced by mini.basic

-- e is for 'Explore' and 'Edit'. Common usage:
-- - `<Leader>ed` - open explorer at current working directory
-- - `<Leader>ef` - open directory of current file (needs to be present on disk)
-- - `<Leader>ei` - edit 'init.lua'
-- - All mappings that use `edit_plugin_file` - edit 'plugin/' config files
local explore_at_file = "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>"
local explore_quickfix = function() vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen") end
local explore_locations = function() vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen") end

nmap_leader("ed", "<Cmd>lua MiniFiles.open()<CR>", "Directory")
nmap_leader("ef", explore_at_file, "File directory")
nmap_leader("en", '<Cmd>lua require("snacks").notifier.show_history()<CR>', "Notifications history")
nmap_leader("eq", explore_quickfix, "Quickfix list")
nmap_leader("eQ", explore_locations, "Location list")
nmap("<C-q>", explore_quickfix, "Quickfix list")

-- local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
-- local git_log_buf_cmd = git_log_cmd .. ' --follow -- %'

-- nmap_leader('ga', '<Cmd>Git diff --cached<CR>', 'Added diff')
-- nmap_leader('gA', '<Cmd>Git diff --cached -- %<CR>', 'Added diff buffer')
-- nmap_leader('gc', '<Cmd>Git commit<CR>', 'Commit')
-- nmap_leader('gC', '<Cmd>Git commit --amend<CR>', 'Commit amend')
-- nmap_leader('gd', '<Cmd>Git diff<CR>', 'Diff')
-- nmap_leader('gD', '<Cmd>Git diff -- %<CR>', 'Diff buffer')
-- nmap_leader('gl', '<Cmd>' .. git_log_cmd .. '<CR>', 'Log')
-- nmap_leader('gL', '<Cmd>' .. git_log_buf_cmd .. '<CR>', 'Log buffer')
-- nmap_leader('go', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', 'Toggle overlay')
-- nmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>', 'Show at cursor')
--
-- xmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>', 'Show at selection')

-- l is for 'Language'. Common usage:
-- - `<Leader>ld` - show more diagnostic details in a floating window
-- - `<Leader>lr` - perform rename via LSP
-- - `<Leader>ls` - navigate to source definition of symbol under cursor
--
-- NOTE: most LSP mappings represent a more structured way of replacing built-in
-- LSP mappings (like `:h gra` and others). This is needed because `gr` is mapped
-- by an "replace" operator in 'mini.operators' (which is more commonly used).
nmap("gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition")
nmap_leader("la", "<Cmd>lua vim.lsp.buf.code_action()<CR>", "Code actions")
xmap_leader("la", ":<C-U>lua vim.lsp.buf.code_action()<CR>", "Code actions")
nmap_leader("lc", "<Cmd>lua vim.lsp.buf.incoming_calls<CR>", "Incoming calls")
nmap_leader("lC", "<Cmd>lua vim.lsp.buf.outgoing_calls<CR>", "Outgoing calls")
nmap_leader("ld", "<Cmd>Lspsaga show_buf_diagnostics ++float<CR>", "Diagnostic (buffer)")
-- Use snacks
-- nmap_leader('lD', '<Cmd>Lspsaga show_workspace_diagnostics ++float)<CR>', 'Diagnostic (workspace)')
nmap_leader("li", "<Cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation")
nmap_leader("lh", "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover")
nmap_leader("ll", "<Cmd>lua vim.lsp.codelens.run()<CR>", "CodeLens Run")
nmap_leader("lr", "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename")
nmap("<F2>", "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename")
nmap_leader("lR", "<Cmd>lua vim.lsp.buf.references()<CR>", "References")
nmap_leader("lt", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", "Type definition")
nmap_leader("lT", '<Cmd>lua vim.lsp.buf.typehierarchy("supertypes")<CR>', "Type hierarchy")
-- LSP Information Capability flattener
nmap_leader("lI", "<Cmd>checkhealth vim.lsp<CR>", "Lsp information")

nmap("gl", "<Cmd>lua vim.diagnostic.open_float({scope='c'})<CR>", "Diagnostics (cursor)")
nmap("gL", "<Cmd>lua vim.diagnostic.open_float({scope='l'})<CR>", "Diagnostics (line)")
nmap("]d", "<Cmd>Lspsaga diagnostic_jump_next<CR>", "Next diagnostic")
nmap("[d", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", "Prev diagnostic")

-- Use conform custom user command to format
nmap_leader("lf", "<Cmd>Format<CR>", "Format")
xmap_leader("lf", "<Cmd>Format<CR>", "Format selection")
-- m is for 'Map'. Common usage:
-- - `<Leader>mt` - toggle map from 'mini.map' (closed by default)
-- - `<Leader>mf` - focus on the map for fast navigation
-- - `<Leader>ms` - change map's side (if it covers something underneath)
nmap("\\m", "<Cmd>lua MiniMap.toggle()<CR>", "Toggle scrollbar")

-- o is for 'Other'. Common usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
nmap("\\r", "<Cmd>lua MiniMisc.resize_window()<CR>", "Resize to default width")
nmap("\\t", "<Cmd>lua MiniTrailspace.trim()<CR>", "Trim trailspace")
nmap("\\z", "<Cmd>lua MiniMisc.zoom()<CR>", "Zoom toggle")

-- s is for 'Session'. Common usage:
-- - `<Leader>sn` - start new session
-- - `<Leader>sr` - read previously started session
-- - `<Leader>sR` - restart Neovim preserving current session
local session_new = 'vim.ui.input({ prompt = "Session name: " }, MiniSessions.write)'

nmap_leader("Sd", '<Cmd>lua MiniSessions.select("delete")<CR>', "Delete")
nmap_leader("Sn", "<Cmd>lua " .. session_new .. "<CR>", "New")
nmap_leader("Sr", '<Cmd>lua MiniSessions.select("read")<CR>', "Read")
nmap_leader("SR", "<Cmd>lua MiniSessions.restart()<CR>", "Restart")
nmap_leader("Sw", "<Cmd>lua MiniSessions.write()<CR>", "Write current")

-- other key maps
nmap_leader("h", function()
  vim.cmd "nohlsearch"
  vim.schedule(function() vim.api.nvim_exec_autocmds("User", { pattern = "Nohlsearch" }) end)
end, "Clear highlight")

-- stylua: ignore end
