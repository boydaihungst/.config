---@type LazySpec
return {
  "nanotee/sqls.nvim",
  optional = true,
  dependencies = {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        sqls_attach = {},
      },
    },
  },
}
