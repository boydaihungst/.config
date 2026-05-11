local prefix = "<Leader>M"
---@type LazySpec
return {
  "iamcco/markdown-preview.nvim",
  build = ":call mkdp#util#install()",
  ft = { "markdown", "markdown.mdx" },
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  init = function()
    local plugin = require("lazy.core.config").spec.plugins["markdown-preview.nvim"]
    vim.g.mkdp_filetypes = require("lazy.core.plugin").values(plugin, "ft", true)
    vim.g.mkdp_auto_start = false
  end,
  specs = {
    { "AstroNvim/astroui", opts = { icons = { Markdown = "" } } },
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            [prefix] = { desc = require("astroui").get_icon("Markdown", 1, true) .. "Markdown" },
            [prefix .. "p"] = { "<cmd>MarkdownPreview<cr>", desc = "Preview" },
            [prefix .. "s"] = { "<cmd>MarkdownPreviewStop<cr>", desc = "Stop preview" },
            [prefix .. "t"] = { "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle preview" },
          },
        },
      },
    },
  },
}
