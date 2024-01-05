local util = require "lspconfig.util"
local lsp_manager = require("lvim.lsp.manager")
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, {
  "volar",
  "tsserver",
  "biome"
})
-- -- Remove marksman from skipped_servers
lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
  return server ~= "jdtls"
end, lvim.lsp.automatic_configuration.skipped_servers)

Lsp_get_cmd_path = function(pkgBin)
  local home_dir = os.getenv("HOME");
  local bin_path = util.path.join(home_dir, '.bun/bin', pkgBin)
  if util.path.exists(bin_path) then
    return bin_path
  end
  return pkgBin
end

-- lsp_manager.setup("tailwindcss", {
--   filetypes = {
--     "aspnetcorerazor",
--     "astro",
--     "astro-markdown",
--     "blade",
--     "django-html",
--     "htmldjango",
--     "edge",
--     "eelixir",
--     "ejs",
--     "erb",
--     "eruby",
--     "gohtml",
--     "haml",
--     "handlebars",
--     "hbs",
--     "html",
--     "html-eex",
--     "heex",
--     "jade",
--     "leaf",
--     "liquid",
--     "markdown",
--     "mdx",
--     "mustache",
--     "njk",
--     "nunjucks",
--     "php",
--     "razor",
--     "slim",
--     "twig",
--     "css",
--     "less",
--     "postcss",
--     "sass",
--     "scss",
--     "stylus",
--     "sugarss",
--     "javascriptreact",
--     "reason",
--     "rescript",
--     "typescriptreact",
--     "vue",
--     "svelte",
--   },
-- })

lsp_manager.setup("eslint", {
  cmd       = { Lsp_get_cmd_path("vscode-eslint-language-server"), "--stdio" },
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
