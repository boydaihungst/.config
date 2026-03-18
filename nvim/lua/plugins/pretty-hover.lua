---@type LazySpec
return {
  "Fildo7525/pretty_hover",
  event = "LspAttach",
  enabled = true,
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
                  return
                end
                require("pretty_hover").hover()
              end,
              cond = "textDocument/hover",
              desc = "Toggle pretty hover",
            },
          },
        },
      },
    },
  },
  opts = {
    -- If you use nvim 0.11.0 or higher you can choose, whether you want to use the new
    -- multi lsp support or not. Otherwise this option is ignored.
    -- NOTE: Temporarily disable because it make lua_ls stuck after using a while
    multi_server = false,
  },
}
