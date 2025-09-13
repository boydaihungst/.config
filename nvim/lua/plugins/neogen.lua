return {
  "danymat/neogen",
  optional = true,
  opts = {
    languages = {
      lua = { template = { annotation_convention = "emmylua" } },
      typescript = { template = { annotation_convention = "tsdoc" } },
      typescriptreact = { template = { annotation_convention = "tsdoc" } },
      vue = { template = { annotation_convention = "tsdoc" } },
      javascript = { template = { annotation_convention = "jsdoc" } },
      javascriptreact = { template = { annotation_convention = "jsdoc" } },
      ruby = { template = { annotation_convention = "yard" } },
    },
    snippet_engine = "mini",
  },
}
