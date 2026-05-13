on_filetype({ "markdown", "markdown.mdx" }, function()
  vim.g.mkdp_filetypes = { "markdown", "markdown.mdx" }
  vim.g.mkdp_auto_start = false

  vim.pack.on_packchanged(
    "markdown-preview.nvim",
    { "update", "install" },
    function() vim.cmd "call mkdp#util#install()" end,
    ":call mkdp#util#install()"
  )
  add { "https://github.com/iamcco/markdown-preview.nvim" }
  local mkdp = vim.pack.get { "markdown-preview.nvim" }
  local mkdp_root_dir = #mkdp > 0 and vim.pack.get({ "markdown-preview.nvim" })[1].path or nil
  if mkdp_root_dir == nil then return vim.notify("markdown-preview.nvim install failed", vim.log.levels.ERROR) end
  local mkdp_server_script = mkdp_root_dir .. "/app/bin/markdown-preview-" .. vim.fn["mkdp#util#get_platform"]()
  if vim.fn.executable(mkdp_server_script) == 0 then vim.cmd "call mkdp#util#install()" end

  Config.new_autocmd("Filetype", { "markdown", "markdown.mdx" }, function(args)
    local prefix = "<leader>M"
    if wk then
      wk.add { { prefix, group = Config.get_custom_icon("Markdown", 1, true) .. "Markdown", buffer = args.buf } }
    end
    vim.keymap.set("n", prefix .. "p", "<cmd>MarkdownPreview<cr>", { desc = "Preview", buf = args.buf })
    vim.keymap.set("n", prefix .. "s", "<cmd>MarkdownPreviewStop<cr>", { desc = "Stop preview", buf = args.buf })
    vim.keymap.set("n", prefix .. "t", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle preview", buf = args.buf })
  end, "Markdown mappings", "markdown mappings")
end)
