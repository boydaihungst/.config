if vim.fn.exists ":VenvSelect" == 1 then
  vim.keymap.set("n", "<Leader>lv", "<Cmd>VenvSelect<CR>", { desc = "Select VirtualEnv" })
end
