local lsp_manager = require("lvim.lsp.manager")
local util = require "lspconfig.util"

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, {
  "volar",
  "tsserver"
})

local function get_typescript_server_path(root_dir)
  local global_ts = os.getenv("HOME") .. "/.config/yarn/global/node_modules/typescript/lib/"
  local found_ts = ""
  local function check_dir(path)
    found_ts = util.path.join(path, "node_modules", "typescript", "lib")
    if util.path.exists(found_ts) then
      return path
    end
  end
  if util.search_ancestors(root_dir, check_dir) then
    return found_ts
  else
    return global_ts
  end
end

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = "",
  }
  vim.lsp.buf.execute_command(params)
end
local function check_package_json_contain_vue_package(path)
  local found_package_json = util.path.join(path, 'package.json')
  if util.path.exists(found_package_json) then
    local packageJson = vim.fn.json_decode(vim.fn.readfile(found_package_json))
    if packageJson and packageJson.dependencies and (packageJson.dependencies.vue or packageJson.devDependencies.vue) then
      return true
    end
  end
end

local function detachLspClient(clientId, bufnr)
  vim.schedule(function()
    vim.cmd("silent lua vim.lsp.buf_detach_client(" .. bufnr .. "," .. clientId .. ")")
    local leftoverBufsAttachedToTsServer = vim.lsp.get_buffers_by_client_id(clientId)
    -- Stop if no attach to any buffer
    if #leftoverBufsAttachedToTsServer <= 0 then
      vim.lsp.stop_client(clientId, true)
    end
  end
  )
end
lsp_manager.setup("volar", {
  filetypes = { "vue", "typescriptreact", "javascriptreact", "typescript", "javascript", "json" },
  on_attach = function(client, bufnr)
    local bufPath = vim.fn.expand('%:p:h')
    local tsserverClients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "tsserver" })
    for _, tsserverClient in pairs(tsserverClients) do
      if tsserverClient and not tsserverClient.is_stopped() and vim.lsp.buf_is_attached(bufnr, tsserverClient.id) and vim.lsp.buf_is_attached(bufnr, client.id) then
        -- detach tsserver from attach to this buffer
        if util.search_ancestors(bufPath, check_package_json_contain_vue_package) then
          detachLspClient(tsserverClient.id, bufnr)
        else
          detachLspClient(client.id, bufnr)
          return
        end
      end
    end
    require("lvim.lsp").common_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  on_new_config = function(new_config, new_root_dir)
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end,
})

lsp_manager.setup("tsserver", {
  filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" },
  on_attach = function(client, bufnr)
    local bufPath = vim.fn.expand('%:p:h')
    -- Get volar clients that attached to this buffer
    local volarClients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "volar" })
    if #volarClients >= 1 then
      for _, volarClient in pairs(volarClients) do
        if volarClient and not volarClient.is_stopped() and vim.lsp.buf_is_attached(bufnr, volarClient.id) and vim.lsp.buf_is_attached(bufnr, client.id) then
          -- detach this tsserver client from this buffer
          if util.search_ancestors(bufPath, check_package_json_contain_vue_package) then
            detachLspClient(client.id, bufnr)
            return
          else
            detachLspClient(volarClient.id, bufnr)
          end
        end
      end
    end

    require("lvim.lsp").common_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    require("which-key").register({
      ["lo"] = {
        "<cmd>OrganizeImports<CR>",
        "Organize Imports",
      },
    }, { prefix = "<leader>" })
  end,
  init_options = {
    hostInfo = "neovim",
    tsserver = {
      useSyntaxServer = "auto"
    }
  },
  commands = {
    OrganizeImports = {
      organize_imports,
      description = "Organize Imports",
    },
  },
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
lsp_manager.setup("graphql", {
  filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
})
