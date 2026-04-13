Config.new_autocmd(
  'BufReadPost',
  { '.env', '.env.*' },
  function(args) vim.diagnostic.enable(false, { bufnr = args.buf }) end,
  'Disable diagnostic for environment files'
)

Config.new_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, nil, function()
  if vim.bo.buftype ~= 'nofile' then vim.cmd 'checktime' end
end, 'Check if buffers changed on editor focus')

Config.new_autocmd('BufWritePre', nil, function(args)
  local file = args.match
  if not Config.is_valid_buf(args.buf) or file:match '^%w+:[\\/][\\/]' then return end
  vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(file) or file, ':p:h'), 'p')
end, "Automatically create parent directories if they don't exist when saving a file")

Config.new_autocmd('FileType', nil, function(args)
  if vim.F.if_nil(vim.b.editorconfig, vim.g.editorconfig) then
    local editorconfig_avail, editorconfig = pcall(require, 'editorconfig')
    if editorconfig_avail then editorconfig.config(args.buf) end
  end
end, 'Ensure editorconfig settings take highest precedence')

Config.new_autocmd('TextYankPost', '*', function() vim.hl.on_yank() end, 'Highlight yanked text')

Config.new_autocmd('BufWinEnter', nil, function(args)
  if not vim.g.q_close_windows then vim.g.q_close_windows = {} end
  if vim.g.q_close_windows[args.buf] then return end
  vim.g.q_close_windows[args.buf] = true
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(args.buf, 'n')) do
    if map.lhs == 'q' then return end
  end
  if vim.tbl_contains({ 'help', 'nofile', 'quickfix' }, vim.bo[args.buf].buftype) then
    vim.keymap.set('n', 'q', '<Cmd>close<CR>', {
      desc = 'Close window',
      buffer = args.buf,
      silent = true,
      nowait = true,
    })
  end
end, 'Make q close help, man, quickfix, dap floats')

Config.new_autocmd('BufDelete', nil, function(args)
  if vim.g.q_close_windows then vim.g.q_close_windows[args.buf] = nil end
end, 'Clean up q_close_windows cache')

Config.new_autocmd('BufReadPost', nil, function(args)
  local buf = args.buf
  if vim.b[buf].last_loc_restored or vim.tbl_contains({ 'gitcommit' }, vim.bo[buf].filetype) then return end
  vim.b[buf].last_loc_restored = true
  local mark = vim.api.nvim_buf_get_mark(buf, '"')
  if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
end, 'Restore last cursor position when opening a file')

Config.new_autocmd('FileType', 'qf', function() vim.opt_local.buflisted = false end, 'Unlist quickfix buffers')
