now(function()
  local original_sig_help = vim.lsp.buf.signature_help
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.buf.signature_help = function(opts)
    opts = vim.tbl_extend("force", opts, {
      anchor_bias = "above",
    })
    return original_sig_help(opts)
  end
end)
