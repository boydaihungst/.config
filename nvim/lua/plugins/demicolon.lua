---@type LazySpec
return {
  "mawkler/demicolon.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    keymaps = {
      disabled_keys = { "p", "I", "A", "i" },
    },
  },
}
