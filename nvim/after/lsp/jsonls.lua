local ok, schemastore = pcall(require, "schemastore")
if ok then
  ---@type vim.lsp.Config
  return {
    settings = {
      json = {
        schemas = schemastore.json.schemas(),
        validate = { enable = true },
      },
    },
  }
else
  return {}
end
