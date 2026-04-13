---@type LazySpec
return {
  "mawkler/demicolon.nvim",
  keys = { ";", ",", "]", "[" }, -- Uncomment this to lazy load
  ft = "tex", -- ...and this if you use LaTeX
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = function(_, opts)
    opts.keymaps = vim.tbl_extend("force", opts.keymaps or {}, {
      disabled_keys = { "p", "I", "A", "i", "f", "F", "t", "T" },
      horizontal_motions = false,
    })
  end,
}
