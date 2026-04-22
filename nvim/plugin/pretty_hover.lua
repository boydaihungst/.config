on_event("LspAttach", function()
  add {
    "https://github.com/Fildo7525/pretty_hover",
  }
  require("pretty_hover").setup {}
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.buf.hover = function(opts)
    local _, i18n = pcall(require, "i18n")
    if i18n and i18n._activated and require("i18n.display").get_key_under_cursor() then
      require("i18n").show_popup()
      return
    end
    require("pretty_hover").hover(opts)
  end
end)
