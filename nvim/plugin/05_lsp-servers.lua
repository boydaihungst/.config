local manually_start_lsp_servers = {
  "jdtls",
  "rust_analyzer", -- rustaceanvim will auto enable this lsp server
  "sqls", -- sqls-nvim instead
  "dartls",
  not vim.pack.is_available "roslyn.nvim" and "csharp_ls", -- using rosyln.nvim instead
}

later(function()
  add {
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
    "https://github.com/neovim/nvim-lspconfig",
  }
  local _ = require "mason-core.functional"
  local registry = require "mason-registry"
  local mappings = require "mason-lspconfig.mappings"

  -- Auto enable lsp servers on update/install
  local enabled_servers = {}
  if not mason_lsp_setup then
    _G.mason_lsp_setup = vim.schedule_wrap(function(mason_pkg)
      if type(mason_pkg) ~= "string" then mason_pkg = mason_pkg.name end
      local lspconfig_name = mappings.get_mason_map().package_to_lspconfig[mason_pkg]
      -- if mason_pkg == "tree-sitter-cli" and vim.fn.executable "tree-sitter" == 0 then vim.cmd "restart" end
      if
        not lspconfig_name
        or enabled_servers[lspconfig_name]
        or vim.tbl_contains(manually_start_lsp_servers, lspconfig_name)
      then
        return
      end

      local ok, config = pcall(require, "mason-lspconfig.lsp." .. lspconfig_name)
      if ok then vim.lsp.config(lspconfig_name, config) end

      vim.lsp.enable(lspconfig_name)
      enabled_servers[lspconfig_name] = true
    end)
  end

  --Enable all installed lsp servers via mason
  _.each(mason_lsp_setup, registry.get_installed_package_names())
  registry.refresh(vim.schedule_wrap(function(success, updated_registries)
    if success and #updated_registries > 0 then _.each(mason_lsp_setup, registry.get_installed_package_names()) end
  end))

  -- Restart lsp servers when update lsp server via mason
  registry:off("package:install:success", mason_lsp_setup)
  registry:on("package:install:success", mason_lsp_setup)

  require("mason-lspconfig").setup {
    automatic_enable = false,
    ensure_installed = nil, -- because we use mason-tool-installer to install lsp severs
  }
end)
