---@type LazySpec
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      toml = { "prettier" },
      -- Conform will run multiple formatters sequentially
      -- Use a sub-list to run only the first available formatter
      -- javascript = { { "prettierd", "prettier" } },
    },
  },
}
