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
  on_attach = function(client, bufnr)
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
  },
  commands = {
    OrganizeImports = {
      organize_imports,
      description = "Organize Imports",
    },
  },
})
