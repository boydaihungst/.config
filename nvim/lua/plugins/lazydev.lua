---@type LazySpec
return {
  "folke/lazydev.nvim",
  optional = true,
  dependencies = {
    -- {
    --   "DrKJeff16/wezterm-types",
    --   lazy = true,
    -- },
  },
  opts = {
    library = {
      -- Load yazi types library
      { path = os.getenv "HOME" .. "/.config/yazi/plugins/types.yazi", words = { "ya%." } },
      -- { path = "wezterm-types", mods = { "wezterm" } },
    },
  },
}
