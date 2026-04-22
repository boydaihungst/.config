later(function()
  add {
    "https://github.com/folke/ts-comments.nvim",
  }
  require("ts-comments").setup {
    lang = {
      kitty = "# %s",
      mpvconfig = "# %s",
    },
  }
end)
