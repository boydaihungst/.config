---@type LazySpec
return {
  "alex-popov-tech/store.nvim",
  enabled = true,
  lazy = true,
  cmd = "Store",
  keys = {
    { "<leader>s", "<cmd>Store<cr>", desc = "Open Plugin Store" },
  },
  opts = {
    proportions = {
      list = 0.3, -- 30% for repository list
      preview = 0.7, -- 70% for preview pane
    },
  },
}
