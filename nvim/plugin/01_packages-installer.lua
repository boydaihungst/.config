local is_aarch64 = vim.loop.os_uname().machine == "aarch64"

local ensure_installed_pkg = {
  -- install language servers
  -- Tree sitter cli should be installed first
  vim.fn.executable "tree-sitter" == 0 and "tree-sitter-cli" or nil,
  "ast-grep",
  "fish-lsp",
  "gh-actions-language-server",
  "lua-language-server",
  "marksman",
  vim.fn.executable "dotnet" == 1 and "msbuild_project_tools_server" or nil,
  "roslyn",
  "sqls",
  "taplo",
  "vtsls",
  "yaml-language-server",
  "bash-language-server",
  "ansible-language-server",
  "vtsls",
  "astro-language-server",
  "docker-language-server",
  "eslint-lsp",
  "json-lsp",
  "html-lsp",
  "css-lsp",
  "emmet-ls",
  "hyprls",
  "kotlin-language-server",
  "lua-language-server",
  "stylua",
  "nginx-language-server",
  "buf",
  "basedpyright",
  "tailwindcss-language-server",
  "vue-language-server",
  "lemminx",
  "jdtls",
  "csharp-language-server",
  (not is_aarch64 and "selene") or nil,

  (function()
    local uname = (vim.uv or vim.loop).os_uname()
    local is_linux_arm = uname.sysname == "Linux" and (is_aarch64 or vim.startswith(uname.machine, "arm"))
    if not is_linux_arm then return "clangd" end
  end)(),
  -- AI asisstent
  -- "copilot-language-server",

  -- formatters
  "markdown-toc",
  "prettierd",
  "rust-analyzer",
  "shfmt",
  "stylua",
  "csharpier",
  "nginx-config-formatter",
  "black",
  "isort",
  -- linters
  "dotenv-linter",
  "shellcheck",
  "ansible-lint",
  "hadolint",
  "ktlint",
  "sqlfluff",

  -- debuggers
  "debugpy",
  "firefox-debug-adapter",
  "local-lua-debugger-vscode",
  "netcoredbg",
  "bash-debug-adapter",
  "js-debug-adapter",
  "codelldb",
  "kotlin-debug-adapter",
  "java-debug-adapter",
  "java-test",
  "dart-debug-adapter",

  -- other
  vim.fn.executable "gh" == 0 and "gh" or nil,
}

later(function()
  vim.pack.on_packchanged("mason.nvim", { "install", "update" }, function() vim.cmd "MasonUpdate" end, ":MasonUpdate")
  add {
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  }
  local mason = require "mason"
  mason.setup {
    registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
      "github:boydaihungst/mason-registry",
    },
    ui = {
      icons = vim.g.icons_enabled == false and {
        package_installed = "O",
        package_uninstalled = "X",
        package_pending = "0",
      } or {
        package_installed = "✓",
        package_uninstalled = "✗",
        package_pending = "⟳",
      },
    },
  }
  local mason_tool_installer = require "mason-tool-installer"

  mason_tool_installer.setup {
    ensure_installed = ensure_installed_pkg,
    -- disable alternative name from these package, only use name from Mason.Nvim
    integrations = { ["mason-lspconfig"] = false, ["mason-null-ls"] = false, ["mason-nvim-dap"] = false },
  }
  -- Install at the startup
  mason_tool_installer.run_on_start()
end)
