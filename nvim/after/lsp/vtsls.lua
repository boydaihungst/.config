---@type vim.lsp.Config
return {
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "all" },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = true },
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = true },
      },
    },
    vtsls = {
      enableMoveToFileCodeAction = true,
      tsserver = {
        globalPlugins = {},
      },
    },
  },
  before_init = function(_, config)
    local registry_ok, registry = pcall(require, "mason-registry")
    if not registry_ok then return end

    if registry.is_installed "vue-language-server" then
      local vue_plugin_config = {
        name = "@vue/typescript-plugin",
        location = vim.fn.expand "$MASON/packages/vue-language-server/node_modules/@vue/language-server",
        languages = { "vue" },
        configNamespace = "typescript",
        enableForWorkspaceTypeScriptVersions = true,
      }

      config.settings.vtsls.tsserver.globalPlugins =
        vim.tbl_unique_extend(config.settings.vtsls.tsserver.globalPlugins, { vue_plugin_config })
    end
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
}
