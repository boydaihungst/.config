---@type LazySpec
return {
  "andymass/vim-matchup",
  optional = true,
  specs = {
    {
      "AstroNvim/astrocore",
      optional = true,
      opts = {
        options = {
          g = {
            matchup_matchparen_nomode = "i",
            matchup_matchparen_deferred = 1,
            matchup_surround_enabled = 1,
          },
        },
      },
    },
  },
}
