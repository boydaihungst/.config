---@type LazySpec
return {
  "Fildo7525/pretty_hover",
  event = "LspAttach",
  dependencies = {
    {
      "AstroNvim/astrolsp",
      opts = {
        mappings = {
          n = {
            ["K"] = {
              function()
                if not require("astrocore").is_available "i18n.nvim" then return require("pretty_hover").hover() end
                if require("i18n.display").get_key_under_cursor() then
                  require("i18n").show_popup()
                else
                  require("pretty_hover").hover()
                end
              end,
              cond = "textDocument/hover",
              desc = "Toggle pretty hover",
            },
          },
        },
      },
    },
  },
  opts = {},
}
