local lsp_manager = require("lvim.lsp.manager")

lsp_manager.setup("tailwindcss")
lsp_manager.setup("stylelint_lsp", {
  filetypes = { "css", "less", "scss", "sugarss", "vue", "wxss", "javascriptreact", "typescriptreact" }
})
