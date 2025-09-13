---@type LazySpec
return {
  "supermaven-nvim",
  optional = true,
  opts = {
    ignore_filetypes = { "sql", "grug-far" },
    -- color = {
    --   suggestion_color = "#ffffff",
    --   cterm = 244,
    -- },
    condition = function() return require("astrocore.buffer").is_large() end,
    log_level = "off",
  },
  specs = {
    {
      "saghen/blink.cmp",
      optional = true,
      opts = {
        sources = {
          default = { "supermaven" },
          providers = {
            supermaven = {
              name = "supermaven",
              module = "blink.compat.source",
              -- score_offset = 100,
            },
          },
        },
      },
    },
  },
}
