if vim.fn.exists ":VenvSelect" ~= 0 then
  vim.keymap.set("n", "<Leader>lv", "<Cmd>VenvSelect<CR>", { desc = "Select VirtualEnv", buf = 0 })
end
