local formatters = require("lvim.lsp.null-ls.formatters")
local code_actions = require("lvim.lsp.null-ls.code_actions")
local linters = require("lvim.lsp.null-ls.linters")

formatters.setup({
  -- { name = "deno_fmt" },
  {
    name = "prettier",
    filetypes = { "css", "scss", "less", "yaml", "handlebars" },
    extra_filetypes = {
      "toml"
    }
  },
  -- { name = "eslint_d" },
  -- { name = "rustywind" },
  { name = "sqlfmt" },
  { name = "shfmt" },
  { name = "markdownlint" },
  -- { name = "black" },
  -- { name = "reorder_python_imports" },
  -- { name = "rustfmt" },
  -- { name = "nginx_beautifier" },
  -- { name = "fish_indent" },
})
code_actions.setup({
  { name = "shellcheck" },
  -- { name = "eslint_d", filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" } },
})

linters.setup({
  { name = "vint" },
  { name = "dotenv_linter" },
  -- {
  --   name = "luacheck",
  -- },
  { name = "markdownlint" },
  {
    name = "shellcheck",
  },
  -- { name = "yamllint" },
  -- { name = "commitlint" },
  -- { name = "hadolint" },
  -- { name = "fish" },
})
