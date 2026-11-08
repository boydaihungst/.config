later(function()
  vim.g.undotree_WindowLayout = 3
  vim.g.undotree_SplitWidth = 50
  vim.g.undotree_DiffpanelHeight = 25
  vim.g.undotree_DiffAutoOpen = 0
  vim.g.undotree_SetFocusWhenToggle = 1
  vim.g.undotree_HighlightChangedText = 1
  vim.g.undotree_ShortIndicators = 0
  vim.g.undotree_SignAdded = Config.get_custom_icon("GitAdd", 1, true)
  vim.g.undotree_SignModified = Config.get_custom_icon("GitChange", 1, true)
  vim.g.undotree_SignDeleted = Config.get_custom_icon("GitDelete", 1, true)

  add {
    "https://github.com/mbbill/undotree",
  }

  vim.keymap.set("n", "<Leader>fu", "<Cmd>UndotreeToggle<CR>", { desc = "Undotree" })
end)
