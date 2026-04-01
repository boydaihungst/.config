return {
  "folke/ts-comments.nvim",
  enabled = false,
  opts = {
    lang = {
      kitty = "# %s",
      lua = { "-- %s", [=[--[[ %s ]]--]=] }, -- langs can have multiple commentstrings
    },
  },
  optional = true,
}
