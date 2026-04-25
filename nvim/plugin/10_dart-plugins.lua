on_filetype({ "dart" }, function()
  add {
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/akinsho/flutter-tools.nvim",
  }
  require("flutter-tools").setup {
    lsp = vim.lsp.config["dartls"] or {},
    debugger = { enabled = true },
  }
end)
