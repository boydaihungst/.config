---@type LazySpec
return {
  "nanotee/sqls.nvim",
  optional = true,
  lazy = true,
  ft = { "sql", "mysql" },
  specs = {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        sqls_attach = {},
      },
    },
  },
}
