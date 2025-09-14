---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        -- install language servers
        "taplo",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "emmet-ls",
        "marksman",
        "sqls",
        "yaml-language-server",

        -- install formatters
        "rust-analyzer",
        "stylua",
        "markdown-toc",
        "isort",
        "black",

        -- linters
        "shellcheck",
        "dotenv-linter",

        -- install debuggers
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
        "firefox-debug-adapter",
        "fish-lsp",
        "gh-actions-language-server",
      },
    },
  },
}
