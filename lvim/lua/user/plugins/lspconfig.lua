vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, {
  "volar",
  "tsserver"
})

require("lvim.lsp.manager").setup("eslint", {
  on_attach = function(client, bufnr)
    require("lvim.lsp").common_on_attach(client, bufnr)
    require("which-key").register({
      ["lE"] = {
        "<cmd>EslintFixAll<CR>",
        "Eslint Fix All",
      },
      ["lf"] = {
        "<cmd>lua require('lvim.lsp.utils').format()<cr><cmd>EslintFixAll<CR>",
        "Format",
      },
    }, { prefix = "<leader>" })
  end,
  root_dir  = function(filename, bufnr)
    if string.find(filename, "node_modules/") then
      return nil
    end
    return require("lspconfig.server_configurations.eslint").default_config.root_dir(filename, bufnr)
  end,
  settings  = {
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine",
      },
      showDocumentation = {
        enable = true,
      },
    },
    codeActionOnSave = {
      enable = false,
      mode = "all",
    },
    problems = {
      shortenToSingleLine = false
    },
    experimental = {
      useFlatConfig = false
    },
    format = true,
    onIgnoredFiles = "off",
    packageManager = "yarn",
    quiet = false,
    rulesCustomizations = {},
    run = "onType",
    useESLintClass = false,
    validate = "on",
    workingDirectory = {
      mode = "location",
    },
  },
})
