local lsp_manager = require("lvim.lsp.manager")

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, {
  "volar",
  "tsserver"
})

lsp_manager.setup("tailwindcss", {
  filetypes = {
    "aspnetcorerazor",
    "astro",
    "astro-markdown",
    "blade",
    "django-html",
    "htmldjango",
    "edge",
    "eelixir",
    "ejs",
    "erb",
    "eruby",
    "gohtml",
    "haml",
    "handlebars",
    "hbs",
    "html",
    "html-eex",
    "heex",
    "jade",
    "leaf",
    "liquid",
    "markdown",
    "mdx",
    "mustache",
    "njk",
    "nunjucks",
    "php",
    "razor",
    "slim",
    "twig",
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "stylus",
    "sugarss",
    "javascriptreact",
    "reason",
    "rescript",
    "typescriptreact",
    "vue",
    "svelte",
  },
})

lsp_manager.setup("eslint", {
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
-- lsp_manager.setup("graphql", {
--   filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
-- })
