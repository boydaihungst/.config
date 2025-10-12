---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  optional = true,
  opts = function(_, opts)
    opts.matchup = {
      enable = true,
      include_match_words = true,
    }
    vim.treesitter.language.register("bash", "kitty")
  end,
}
