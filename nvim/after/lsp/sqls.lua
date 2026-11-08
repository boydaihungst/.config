-- rename this file to sqls.lua to override the default lsp config
---@type vim.lsp.Config
return {
  cmd = { "sqls" },
  filetypes = { "sql", "mysql" },
  single_file_support = true,
  settings = {
    sqls = {
      filetypes = { "sql", "mysql" },
      -- https://github.com/sqls-server/sqls?tab=readme-ov-file#db-configuration
      connections = {
        -- {
        --   alias = "postgres sample",
        --   driver = "postgresql",
        --   dataSourceName = "postgresql://testuser:testpw123@localhost:5432/example",
        -- },
      },
    },
  },
}
