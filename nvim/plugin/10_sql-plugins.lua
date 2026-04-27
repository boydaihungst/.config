-- Language-based supported plugins should add to this file
-- Or 10_lang-plugins.lua file (lang is filetype/language)

-- Add keymaps for any lsp server that support inline completion

on_filetype({ "sql", "mysql" }, function()
  add { "https://github.com/nanotee/sqls.nvim" }

  --Remember to disable sqls lsp auto start in 05_lsp-servers.lua
  vim.lsp.config("sqls", {})
  vim.lsp.enable "sqls"
end)
