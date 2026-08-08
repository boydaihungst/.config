---@type LazySpec
return {
  "andymass/vim-matchup",
  event = "User AstroFile",
  init = function()
    vim.g.matchup_matchparen_nomode = "i"
    vim.g.matchup_matchparen_deferred = 1
    vim.g.matchup_surround_enabled = 1
  end,
  specs = {
    { "nvim-treesitter/nvim-treesitter", optional = true },
  },
}
