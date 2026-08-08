-- Suggest scheme for JSON files
-- https://github.com/SchemaStore/schemastore/blob/master/src/api/json/catalog.json
-- https://github.com/b0o/schemastore.nvim
local ok,schemastore = pcall(require, "schemastore")
if ok then
return {
  settings = {
    json = {
      schemas = schemastore.json.schemas {
        -- select = { ".eslintrc", "tsconfig.json", "jsconfig.json", "package.json" },
        validate = { enable = true },
      },
    },
  },
}
else
  return {}
end
