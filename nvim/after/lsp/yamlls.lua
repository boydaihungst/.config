local ok, schemastore = pcall(require, "schemastore")
if ok then
  return {
    settings = {
      yaml = {
        schemas = schemastore.yaml.schemas {
          validate = { enable = true },
        },
      },
    },
  }
else
  return {}
end
