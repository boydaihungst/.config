-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "astrodark",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
        SignColumn = { fg = "#BCC4C9", bg = "#080A0E" },
        Normal = { fg = "#BCC4C9", bg = "#080A0E" },
        Terminal = { fg = "#BCC4C9", bg = "#080A0E" },
        EndOfBuffer = { fg = "#BCC4C9", bg = "#080A0E" },
        FoldColumn = { fg = "#BCC4C9", bg = "#080A0E" },
        Folded = { fg = "#BCC4C9", bg = "#282c34" },
        MatchParen = { fg = "NONE", bg = "NONE", underline = true },
        NormalFloat = { fg = "#BCC4C9", bg = "#080A0E" },
        FloatBorder = { fg = "#BCC4C9", bg = "#080A0E" },
        NvimSurroundHighlight = { fg = "#080A0E", bg = "#8ebd6b" },
        TelescopeMatching = { fg = "#8ebd6b", bg = "NONE", bold = true },
        TelescopeSelectionCaret = { fg = "#BCC4C9", bg = "NONE" },
        TelescopeMultiSelection = { fg = "#BCC4C9", bg = "NONE" },
        TreesitterContext = { fg = "NONE", link = "CursorLine" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- TreesitterContextSeparator = { fg = "#ffffff", bg = "#ffffff" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
    status = {
      icon_highlights = {
        breadcrumbs = true,
        file_icon = {
          tabline = function(self) return self.is_active or self.is_visible end,
          statusline = true,
          winbar = true,
        },
      },
    },
  },
}
