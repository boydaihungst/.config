on_filetype({ "markdown", "markdown.mdx" }, function()
  vim.g.mkdp_filetypes = { "markdown", "markdown.mdx" }
  vim.g.mkdp_auto_start = false

  vim.pack.on_packchanged(
    "markdown-preview.nvim",
    { "update" },
    function() vim.cmd "call mkdp#util#install()" end,
    ":call mkdp#util#install()"
  )
  add { "https://github.com/iamcco/markdown-preview.nvim" }
  vim.cmd "call mkdp#util#install()"

  local prefix = "<leader>M"

  if wk then wk.add { { prefix, group = Config.get_custom_icon("Markdown", 1, true) .. "Markdown" } } end

  vim.keymap.set("n", prefix .. "p", "<cmd>MarkdownPreview<cr>", { desc = "Preview" })
  vim.keymap.set("n", prefix .. "s", "<cmd>MarkdownPreviewStop<cr>", { desc = "Stop preview" })
  vim.keymap.set("n", prefix .. "t", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle preview" })
end)
