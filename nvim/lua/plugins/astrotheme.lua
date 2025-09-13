-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Telescope

local base_color = "#080A0E"
---@type LazySpec
return {
  {
    "AstroNvim/astrotheme",
    -- the first parameter is the plugin specification
    -- the second is the table of options as set up in Lazy with the `opts` key
    ---@type AstroThemeOpts
    opts = {
      style = {
        italic_comments = true,
        neotree = true,
      },
      termguicolors = true,
      terminal_colors = true,
      palettes = {
        global = { -- Globally accessible palettes, theme palettes take priority.
        },
        astrodark = { -- Extend or modify astrodarks palette colors
          ui = {
            red = "#e55561", -- Overrides astrodarks red UI color
            blue = "#4fa6ed",
            green = "#8ebd6b",
            yellow = "#e2b86b",
            purple = "#bf68d9",
            cyan = "#48b0bd",
            orange = "#cc9057",
            accent = "#61afef", -- Changes the accent color of astrodark.
            base = base_color,
            text = "#BCC4C9",
            -- #080A0E
            tool = base_color,
            -- tabline = base_color,
            prompt = base_color,
            float = base_color,
            inactive_base = base_color,
            text_match = "#8ebd6b",
            split = "#BCC4C9",
          },
          syntax = {
            red = "#e55561", -- Overrides astrodarks red UI color
            blue = "#4fa6ed",
            green = "#8ebd6b",
            yellow = "#e2b86b",
            purple = "#bf68d9",
            cyan = "#48b0bd",
            orange = "#cc9057",
            accent = "#61afef", -- Changes the accent color of astrodark.
            text = "#BCC4C9",
          },
          term = {
            red = "#e55561",
            blue = "#4fa6ed",
            green = "#8ebd6b",
            yellow = "#e2b86b",
            purple = "#bf68d9",
            cyan = "#48b0bd",
            white = "#cc9057",
            black = "#0e1013",
            background = base_color,
          },
        },
      },
    },
  },
}
