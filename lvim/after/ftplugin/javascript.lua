local lsp_manager = require("lvim.lsp.manager")

-- require("lvim.lsp.manager").setup("tsserver", {
-- 	settings = { documentFormatting = false },
-- })
local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = "",
  }
  vim.lsp.buf.execute_command(params)
end

lsp_manager.setup("graphql", {
  filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
})

lsp_manager.setup("tsserver", {
  filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" },
  cmd = { Lsp_get_cmd_path("typescript-language-server"), "--stdio" },
  on_attach = function(client, bufnr)
    -- local bufPath = vim.fn.expand('%:p:h')
    -- -- Get volar clients that attached to this buffer
    -- local volarClients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "volar" })
    -- if #volarClients >= 1 then
    --   for _, volarClient in pairs(volarClients) do
    --     if volarClient and not volarClient.is_stopped() and vim.lsp.buf_is_attached(bufnr, volarClient.id) and vim.lsp.buf_is_attached(bufnr, client.id) then
    --       -- detach this tsserver client from this buffer
    --       if util.search_ancestors(bufPath, check_package_json_contain_vue_package) then
    --         detachLspClient(client.id, bufnr)
    --         return
    --       else
    --         detachLspClient(volarClient.id, bufnr)
    --       end
    --     end
    --   end
    -- end

    lvim_lsp.common_on_attach(client, bufnr)
    if (#(vim.lsp.get_active_clients({ bufnr = bufnr, name = "eslint" })) >= 1) then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
    client.server_capabilities.workspace = vim.tbl_deep_extend("force", client.server_capabilities.workspace,
      {
        didChangeWatchedFiles = {
          dynamicRegistration = true
        }
      }
    )
    -- client.server_capabilities.workspace.didChangeWatchedFiles = {
    --   dynamicRegistration = true
    -- }
    require("which-key").register({
      ["lO"] = {
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
