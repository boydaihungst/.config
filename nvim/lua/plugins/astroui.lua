---@type LazySpec
return {
  "AstroNvim/astroui",
  version = false,
  branch = "v4",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "astrodark",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
        SignColumn = { fg = "#BCC4C9", bg = "#080A0E" },
        Normal = { fg = "#BCC4C9", bg = "#080A0E" },
        Terminal = { fg = "#BCC4C9", bg = "#080A0E" },
        EndOfBuffer = { fg = "#BCC4C9", bg = "#080A0E" },
        FoldColumn = { fg = "#BCC4C9", bg = "#080A0E" },
        Folded = { fg = "#BCC4C9", bg = "#282c34" },
        Search = { link = "CurSearch" },
        MatchParen = { underline = true, link = "MatchBackground" },
        NormalFloat = { fg = "#BCC4C9", bg = "#080A0E" },
        FloatBorder = { fg = "#BCC4C9", bg = "#080A0E" },
        NvimSurroundHighlight = { fg = "#080A0E", bg = "#8ebd6b" },
        -- TelescopeMatching = { fg = "#8ebd6b", bg = "NONE", bold = true },
        -- TelescopeSelectionCaret = { fg = "#BCC4C9", bg = "NONE" },
        -- TelescopeMultiSelection = { fg = "#BCC4C9", bg = "NONE" },
        TreesitterContext = { fg = "NONE", link = "CursorLine" },
        LspReferenceRead = { underline = true },
        NeoTreeFloatBorder = { link = "FloatBorder" },
        CodeiumSuggestion = { link = "CodeCompanionVirtualText" },
        -- @markup.link.url xxx cterm=underline,italic gui=underline,italic guifg=#8ebd6b
        ["@markup.link.url"] = { underline = true, italic = true },
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
      separators = {
        breadcrumbs = "  ",
        path = "  ",
      },
      icon_highlights = {
        breadcrumbs = true,
        file_icon = {
          tabline = function(self) return self.is_active or self.is_visible end,
          statusline = true,
          winbar = true,
        },
      },

      -- Configure enabling/disabling of winbar
      winbar = {
        -- enabled = { -- whitelist buffer patterns
        --   filetype = { "gitsigns.blame" },
        -- },
        -- disabled = { -- blacklist buffer patterns
        --   buftype = { "nofile", "terminal" },
        -- },
      },
    },
  },
}
