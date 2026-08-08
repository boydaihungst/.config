---https://tombi-toml.github.io/tombi/docs/configuration/
---@type vim.lsp.Config
return {
  root_markers = { "tombi.toml", "pyproject.toml", ".git", "Cargo.toml" },
  cmd = { "tombi", "lsp" },
  filetypes = { "toml" },
  settings = {
    tombi = {
      lsp = {
        ["code-action"] = {
          enabled = true,
        },
      },
      format = {
        rules = {
          ["indent-sub-tables"] = true,
          ["indent-table-key-value-pairs"] = true,
          ["key-value-equals-sign-alignment"] = true,
          ["trailing-comment-alignment"] = true,
        },
      },
    },
  },
}
