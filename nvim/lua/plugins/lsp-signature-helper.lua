return {
  "AstroNvim/astrocore",
  opts = function(_, _)
    local astrocore = require "astrocore"
    local original_sig_help = vim.lsp.buf.signature_help
    if not vim.g.changed_sign_helper then
      vim.lsp.buf.signature_help = function(opts)
        if astrocore.is_available "i18n.nvim" and require("i18n.display").get_key_under_cursor() then
          require("i18n").show_popup()
        else
          opts = astrocore.extend_tbl(opts, {
            anchor_bias = "above",
          })
          return original_sig_help(opts)
        end
      end
      vim.g.changed_sign_helper = true
    end
  end,
}
