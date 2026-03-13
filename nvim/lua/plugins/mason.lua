---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        require("astrocore").list_insert_unique(opts.ensure_installed, {
          -- install language servers
          "taplo",
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
          "local-lua-debugger-vscode",
          "firefox-debug-adapter",

          -- install any other package
          "tree-sitter-cli",
          "fish-lsp",
          "gh-actions-language-server",
          "lua-language-server",
        })
        -- NOTE: disable emmet-ls, so react template will display correct lsp autocompletion
        local disabled_lsp_servers = { "emmet-ls", "emmet-language-server" }
        for i = #opts.ensure_installed, 1, -1 do
          local server = opts.ensure_installed[i]
          if vim.tbl_contains(disabled_lsp_servers, server) then table.remove(opts.ensure_installed, i) end
        end
      end
    end,
  },
}
