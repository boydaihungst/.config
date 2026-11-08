local ok, schemastore = pcall(require, "schemastore")
if ok then
  ---@type vim.lsp.Config
  return {
    settings = {
      yaml = {
        schemaStore = {
          -- You must disable built-in schemaStore support if you want to use
          -- schemastore plugin and its advanced options like `ignore`.
          enable = false,
          -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
          url = "",
        },
        schemas = schemastore.yaml.schemas {
          validate = { enable = true },
        },
      },
    },
  }
else
  return {}
end
