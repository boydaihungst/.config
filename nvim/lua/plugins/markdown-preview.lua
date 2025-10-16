---@type LazySpec
return {
  "iamcco/markdown-preview.nvim",
  optional = true,
  build = ":call mkdp#util#install()",
  ft = { "markdown", "markdown.mdx" },
  specs = {
    {
      "AstroNvim/astrocore",
      optional = true,
      opts = {
        options = {
          g = {
            mkdp_auto_start = false,
          },
        },
      },
    },
  },
}
