-- Suggest scheme for JSON files
-- https://github.com/SchemaStore/schemastore/blob/master/src/api/json/catalog.json
-- https://github.com/b0o/schemastore.nvim
return {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas {
        -- select = { ".eslintrc", "tsconfig.json", "jsconfig.json", "package.json" },
        validate = { enable = true },
      },
    },
  },
}
