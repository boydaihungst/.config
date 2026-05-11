---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "User AstroFile",
  cmd = { "TSContext" },
  opts = {
    multiline_threshold = 5,
    separator = "─",
    -- How many lines the window should span. Values <= 0 mean no limit.
    -- Can be '<int>%' like '30%' - to specify percentage of win.height
    max_lines = 5,
  },
  specs = {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ["<Leader>uT"] = {
            "<cmd>TSContext toggle<CR>",
            desc = "Toggle treesitter context",
          },
        },
      },
    },
  },
}
