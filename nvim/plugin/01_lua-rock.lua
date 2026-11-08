-- This is a library plugin, so it shouldn't be lazy-loaded
-- So we don't have to add on_packchanged any where we require it
now(function()
  add {
    "https://github.com/vhyrro/luarocks.nvim",
  }
  require("luarocks-nvim").setup {
    rocks = { "luautf8" },
  }
end)
