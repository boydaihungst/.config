later(function()
  add { "https://github.com/danymat/neogen" }
  local neogeo = require "neogen"
  neogeo.setup {
    languages = {
      lua = { template = { annotation_convention = "emmylua" } },
      typescript = { template = { annotation_convention = "tsdoc" } },
      typescriptreact = { template = { annotation_convention = "tsdoc" } },
      vue = { template = { annotation_convention = "tsdoc" } },
      javascript = { template = { annotation_convention = "jsdoc" } },
      javascriptreact = { template = { annotation_convention = "jsdoc" } },
      ruby = { template = { annotation_convention = "yard" } },
    },
    snippet_engine = MiniSnippets and "mini" or "luasnip",
  }

  if wk then
    wk.add {
      {
        "<leader>a",
        group = Config.get_custom_icon("Neogen", 1, true) .. "Annotation",
      },
    }
  end
  local function gen(type)
    return function() require("neogen").generate { type = type } end
  end
  local prefix = "<leader>a"
  vim.keymap.set("n", prefix .. "<CR>", gen "any", { desc = "Current" })
  vim.keymap.set("n", prefix .. "c", gen "class", { desc = "Class" })
  vim.keymap.set("n", prefix .. "f", gen "func", { desc = "Function" })
  vim.keymap.set("n", prefix .. "t", gen "type", { desc = "Type" })
  vim.keymap.set("n", prefix .. "F", gen "file", { desc = "File" })
end)
