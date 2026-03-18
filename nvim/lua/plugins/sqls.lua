---@type LazySpec
return {
  "nanotee/sqls.nvim",
  optional = true,
  lazy = true,
  ft = { "sql", "mysql" },
  dependencies = {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        sqls_attach = {},
      },
    },
  },
}
