-- local lsp_manager = require("lvim.lsp.manager")

-- local function organize_imports()
--   local params = {
--     command = "_typescript.organizeImports",
--     arguments = { vim.api.nvim_buf_get_name(0) },
--     title = "",
--   }
--   vim.lsp.buf.execute_command(params)
-- end

-- lsp_manager.setup("tsserver", {
--   on_attach = function(client, bufnr)
--     -- Get volar clients that attached to this buffer
--     local volarClients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "volar" })
--     if #volarClients >= 1 then
--       for _, volarClient in pairs(volarClients) do
--         if volarClient and not volarClient.is_stopped() and vim.lsp.buf_is_attached(bufnr, volarClient.id) and vim.lsp.buf_is_attached(bufnr, client.id) then
--           -- detach this tsserver client from this buffer

--           vim.lsp.buf_detach_client(bufnr, client.id)
--           return
--         end
--       end
--     end

--     require("lvim.lsp").common_on_attach(client, bufnr)
--     client.server_capabilities.documentFormattingProvider = false
--     client.server_capabilities.documentRangeFormattingProvider = false

--     require("which-key").register({
--       ["lo"] = {
--         "<cmd>OrganizeImports<CR>",
--         "Organize Imports",
--       },
--     }, { prefix = "<leader>" })
--   end,
--   init_options = {
--     hostInfo = "neovim",
--     tsserver = {
--       useSyntaxServer = "auto"
--     }
--   },
--   commands = {
--     OrganizeImports = {
--       organize_imports,
--       description = "Organize Imports",
--     },
--   },
-- })
