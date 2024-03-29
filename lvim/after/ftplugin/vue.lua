local lsp_manager = require("lvim.lsp.manager")
local util = require "lspconfig.util"
local lvim_lsp = require "lvim.lsp"


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

-- local function check_package_json_contain_vue_package(path)
--   local found_package_json = util.path.join(path, 'package.json')
--   if util.path.exists(found_package_json) then
--     local packageJson = vim.fn.json_decode(vim.fn.readfile(found_package_json))
--     if packageJson and packageJson.dependencies and (packageJson.dependencies.vue or packageJson.devDependencies.vue) then
--       return true
--     end
--   end
-- end

-- local function detachLspClient(clientId, bufnr)
--   vim.schedule(function()
--     vim.cmd("silent lua vim.lsp.buf_detach_client(" .. bufnr .. "," .. clientId .. ")")
--     local leftoverBufsAttachedToTsServer = vim.lsp.get_buffers_by_client_id(clientId)
--     -- Stop if no attach to any buffer
--     if #leftoverBufsAttachedToTsServer <= 0 then
--       vim.lsp.stop_client(clientId, true)
--     end
--   end
--   )
-- end
lsp_manager.setup("volar", {
  filetypes = { "vue", "json" },
  cmd = { Lsp_get_cmd_path("vue-language-server"), "--stdio" },
  -- root_dir = function(fname)
  --   return util.search_ancestors(fname, check_package_json_contain_vue_package)
  -- end,
  on_attach = function(client, bufnr)
    lvim_lsp.common_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.workspace = vim.tbl_deep_extend("force", client.server_capabilities.workspace,
      {
        didChangeWatchedFiles = {
          dynamicRegistration = true
        }
      }
    )
  end,
  on_new_config = function(new_config, new_root_dir)
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end,
})

lsp_manager.setup("tailwindcss", {
  cmd = { Lsp_get_cmd_path("tailwindcss-language-server"), "--stdio" },
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

lsp_manager.setup("graphql", {
  cmd = { Lsp_get_cmd_path("graphql-lsp"), "server", "-m", "stream" },
  filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
})
