---@type LazySpec
return {
  "iamcco/markdown-preview.nvim",
  optional = true,
  build = ":call mkdp#util#install()",
}
