vim.keymap.set("n", "<leader>Me", "<Cmd>Editor edit<CR>", { desc = "Editor code block", buf = 0 })
vim.keymap.set("n", "<leader>Mn", "<Cmd>Editor create<CR>", { desc = "Create code block", buf = 0 })

vim.keymap.set("n", "<leader>Mc", "<Cmd>Checkbox change 1 0<CR>", { desc = "Change check box", buf = 0 })
vim.keymap.set("n", "<leader>MC", "<Cmd>Checkbox toggle<CR>", { desc = "Add/Remove check box", buf = 0 })

vim.keymap.set("n", "<M-l>", function()
  local line = vim.api.nvim_get_current_line()
  if line:match "^%s*#" then
    vim.cmd "Heading increase"
  elseif MiniMove and vim.tbl_get(MiniMove, "config", "mappings", "right") == "<M-l>" then
    MiniMove.move_line "right"
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<M-l>", true, false, true), "n", false)
  end
end, { desc = "Increase heading", buf = 0 })
vim.keymap.set("n", "<M-h>", function()
  local line = vim.api.nvim_get_current_line()
  if line:match "^%s*#" then
    vim.cmd "Heading decrease"
  elseif MiniMove and vim.tbl_get(MiniMove, "config", "mappings", "left") == "<M-h>" then
    MiniMove.move_line "left"
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<M-h>", true, false, true), "n", false)
  end
end, { desc = "Decrease heading", buf = 0 })
