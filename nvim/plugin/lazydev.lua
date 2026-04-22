on_filetype("lua", function()
  add {
    "https://github.com/folke/lazydev.nvim",
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "1.x" },
    -- 'https://github.com/DrKJeff16/wezterm-types',
  }
  require("lazydev").setup {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = os.getenv "HOME" .. "/.config/yazi/plugins/types.yazi", words = { "ya%.", "ui%." } },
      -- { path = "wezterm-types", mods = { "wezterm" } },
    },
  }
  local blink_avail, blink = pcall(require, "blink.cmp")
  if blink_avail then
    blink.add_filetype_source("lua", "lazydev")
    blink.add_source_provider("lazydev", {
      name = "LazyDev",
      module = "lazydev.integrations.blink",
      score_offset = 100,
    })
  end
end)
