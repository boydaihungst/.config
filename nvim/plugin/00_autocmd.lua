Config.new_autocmd(
  "BufReadPost",
  { ".env", ".env.*" },
  function(args) vim.diagnostic.enable(false, { bufnr = args.buf }) end,
  "Disable diagnostic for environment files"
)

Config.new_autocmd({ "FocusGained", "TermClose", "TermLeave" }, nil, function()
  if vim.bo.buftype ~= "nofile" then vim.cmd "checktime" end
end, "Check if buffers changed on editor focus")

Config.new_autocmd("BufWritePre", nil, function(args)
  local file = args.match
  if not Config.is_valid_buf(args.buf) or file:match "^%w+:[\\/][\\/]" then return end
  vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(file) or file, ":p:h"), "p")
end, "Automatically create parent directories if they don't exist when saving a file")

Config.new_autocmd("FileType", nil, function(args)
  if vim.F.if_nil(vim.b.editorconfig, vim.g.editorconfig) then
    local editorconfig_avail, editorconfig = pcall(require, "editorconfig")
    if editorconfig_avail then editorconfig.config(args.buf) end
  end
end, "Ensure editorconfig settings take highest precedence")

Config.new_autocmd("BufWinEnter", nil, function(args)
  if not vim.g.q_close_windows then vim.g.q_close_windows = {} end
  if vim.g.q_close_windows[args.buf] then return end
  vim.g.q_close_windows[args.buf] = true
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(args.buf, "n")) do
    if map.lhs == "q" then return end
  end
  if vim.tbl_contains({ "help", "nofile", "quickfix" }, vim.bo[args.buf].buftype) then
    vim.keymap.set("n", "q", "<Cmd>close<CR>", {
      desc = "Close window",
      buf = args.buf,
      silent = true,
      nowait = true,
    })
  end
end, "Make q close help, man, quickfix, dap floats")

Config.new_autocmd("BufDelete", nil, function(args)
  if vim.g.q_close_windows then vim.g.q_close_windows[args.buf] = nil end
end, "Clean up q_close_windows cache")

Config.new_autocmd("BufReadPost", nil, function(args)
  local buf = args.buf
  if vim.b[buf].last_loc_restored or vim.tbl_contains({ "gitcommit" }, vim.bo[buf].filetype) then return end
  vim.b[buf].last_loc_restored = true
  local mark = vim.api.nvim_buf_get_mark(buf, '"')
  if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
end, "Restore last cursor position when opening a file")

Config.new_autocmd("FileType", "qf", function() vim.opt_local.buflisted = false end, "Unlist quickfix buffers")

Config.new_autocmd({ "BufAdd", "BufEnter", "TabNewEntered" }, nil, function(args)
  if not vim.t.bufs then vim.t.bufs = {} end
  if not Config.is_valid_buf(args.buf) then return end
  local bufs = vim.t.bufs
  if not vim.tbl_contains(bufs, args.buf) then
    table.insert(bufs, args.buf)
    vim.t.bufs = bufs
  end
  vim.t.bufs = vim.tbl_filter(Config.is_valid_buf, vim.t.bufs)
end, "Update buffers when adding new buffers")

Config.new_autocmd({ "BufDelete", "TermClose" }, nil, function(args)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local bufs = vim.t[tab].bufs
    if bufs then
      for i, bufnr in ipairs(bufs) do
        if bufnr == args.buf then
          table.remove(bufs, i)
          vim.t[tab].bufs = bufs
          break
        end
      end
    end
  end
  vim.t.bufs = vim.tbl_filter(Config.is_valid_buf, vim.t.bufs)
  vim.cmd.redrawtabline()
end, "Update buffers when deleting buffers")

if Config.default_lsp_signature_help then
  local lsp_bufs = {}
  Config.new_autocmd({ "LspAttach" }, nil, function(args)
    if not Config.is_valid_buf(args.buf) then return end
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method("textDocument/signatureHelp", args.buf) and not lsp_bufs[args.buf] then
      local sig_timer = nil
      lsp_bufs[args.buf] = Config.new_autocmd({ "TextChangedI", "InsertEnter", "CursorMovedI" }, nil, function()
        if sig_timer then sig_timer:stop() end
        sig_timer = vim.defer_fn(function()
          if lsp_bufs[vim.api.nvim_get_current_buf()] and vim.api.nvim_get_mode().mode == "i" then
            vim.lsp.buf.signature_help {
              anchor_bias = "above",
              max_height = 15,
              focusable = false,
              silent = true,
            }
          end
          sig_timer = nil
        end, 200)
      end, "Automatically show signature help if enabled")
    end
  end)

  Config.new_autocmd({ "LspDetach" }, nil, function(args)
    if not Config.is_valid_buf(args.buf) then return end
    for _, client in pairs(vim.lsp.get_clients { bufnr = args.buf }) do
      if client.id ~= args.data.client_id and client:supports_method("textDocument/signatureHelp", args.buf) then
        return
      end
    end
    if lsp_bufs[args.buf] then pcall(vim.api.nvim_del_autocmd, lsp_bufs[args.buf]) end
    lsp_bufs[args.buf] = nil
  end, "Safely remove LSP signature help providers when language servers detach")
end

if Config.auto_chdir_root then
  vim.o.autochdir = false
  -- The Smart Root Function
  local function set_smart_root()
    if not vim.bo.buflisted then return end
    -- Check active LSP clients for the current buffer
    local clients = vim.lsp.get_clients { bufnr = 0 }

    for _, client in ipairs(clients) do
      -- Only proceed if the LSP isn't ignored AND has a valid root_dir
      if not (Config.root_markers_lsp_servers_ignored or {})[client.name] and client.root_dir then
        return vim.fn.chdir(vim.fn.expand(client.root_dir))
      end
    end

    local root = require("mini.misc").find_root(0, Config.root_markers or {})
    if root then return vim.fn.chdir(vim.fn.expand(root)) end
    -- fallback to current directory
    local file_path = vim.api.nvim_buf_get_name(0)
    if file_path ~= "" then return vim.fn.chdir(vim.fn.fnamemodify(file_path, ":p:h")) end
  end

  -- Autocmds to trigger the check
  Config.new_autocmd(
    { "BufEnter", "LspAttach" },
    nil,
    function() vim.schedule(set_smart_root) end,
    "Auto change cwd based on lsp and root files",
    "SmartRoot"
  )
end
