---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter-context",
  optional = true,
  opts = {
    multiline_threshold = 5,
    separator = "─",
    -- How many lines the window should span. Values <= 0 mean no limit.
    -- Can be '<int>%' like '30%' - to specify percentage of win.height
    max_lines = 5,
  },
}
