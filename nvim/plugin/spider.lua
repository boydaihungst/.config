later(function()
  add {
    "https://github.com/chrisgrieser/nvim-spider",
  }

  require("spider").setup {
    skipInsignificantPunctuation = true,
    subwordMovement = true,
    consistentOperatorPending = false, -- see the README for details
    customPatterns = {}, -- see the README for details
  }
  vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>")
  vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>")
  vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>")
  vim.keymap.set({ "n", "o", "x" }, "ge", "<cmd>lua require('spider').motion('ge')<CR>")
  vim.keymap.set("i", "<C-w>", "<Esc>l<cmd>lua require('spider').motion('w')<CR>i")
  vim.keymap.set("i", "<C-e>", "<Esc>l<cmd>lua require('spider').motion('e')<CR>i")
  vim.keymap.set("i", "<C-b>", "<Esc><cmd>lua require('spider').motion('b')<CR>i")
end)
