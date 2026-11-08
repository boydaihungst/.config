local M = {}
local large_buf_cache, buf_size_cache = {}, {} -- cache large buffer detection results and buffer sizes

M.default_large_buf_opts = {
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
}

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
function M.is_large(bufnr, large_buf_opts, event)
  if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
  -- always return not large until buffer is loaded, do not cache decision
  if not vim.api.nvim_buf_is_loaded(bufnr) and event ~= "BufReadPre" then return false end
  local skip_cache = large_buf_opts ~= nil -- skip cache when called manually with custom options
  if not large_buf_opts then large_buf_opts = M.default_large_buf_opts end
  if large_buf_opts then
    if skip_cache or large_buf_cache[bufnr] == nil then
      local enabled = vim.tbl_get(large_buf_opts, "enabled")
      if type(enabled) == "function" then
        large_buf_opts = vim.deepcopy(large_buf_opts)
        enabled = enabled(bufnr, large_buf_opts)
        if type(enabled) == "table" then large_buf_opts = enabled end
      end
      local large_buf = false
      if vim.nonnil(enabled, true) then
        if not buf_size_cache[bufnr] then
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          buf_size_cache[bufnr] = ok and stats and stats.size or 0
        end
        local file_size = buf_size_cache[bufnr]
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local fpath = vim.api.nvim_buf_get_name(bufnr)
        if fpath ~= "" and vim.uv.fs_stat(fpath) and (large_buf_opts.line_length or large_buf_opts.lines) then
          line_count = #vim.fn.readfile(fpath, "", large_buf_opts.lines + 1) -- read first line_length lines
        end
        local too_large = large_buf_opts.size and file_size > large_buf_opts.size
        local too_long = large_buf_opts.lines and line_count > large_buf_opts.lines
        local too_wide = large_buf_opts.line_length and ((file_size / line_count) - 1 > large_buf_opts.line_length)
          or false
        large_buf = too_large or too_long or too_wide or false
      end
      if skip_cache then return large_buf end
      large_buf_cache[bufnr] = large_buf
    end
    return large_buf_cache[bufnr]
  end
  return false
end

-- Detect big/large file
vim.api.nvim_create_autocmd("BufReadPre", {
  desc = "Detect big/large file",
  callback = function(args)
    if M.is_large(args.buf, nil, "BufReadPre") then
      -- Disable heavy features
      if vim.fn.exists ":NoMatchParen" ~= 0 then vim.cmd [[NoMatchParen]] end
      local snacks_exist, snacks = pcall(require, "snacks")
      if snacks_exist then snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 }) end

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
      if M.default_large_buf_opts.notify then
        vim.schedule(function() vim.notify("Large file detected: Heavy features disabled", vim.log.levels.WARN) end)
      end
    end
  end,
  group = vim.api.nvim_create_augroup("largefile detector", { clear = true }),
})

M.setup = function(opts) M.default_large_buf_opts = vim.tbl_deep_extend("force", M.default_large_buf_opts, opts or {}) end

return M
