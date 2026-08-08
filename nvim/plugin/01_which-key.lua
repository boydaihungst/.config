now_if_args(function()
  add { "https://github.com/folke/which-key.nvim" }

  local config = {
    preset = "classic",
    notify = true,
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = true, suggestions = 20 },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    win = {
      border = vim.o.winborder,
    },
    keys = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    icons = {
      group = "",
      rules = false,
      separator = "-",
    },
  }

  if not vim.g.icons_enabled then
    config.icons.breadcrumb = ">"
    config.icons.group = "+"
    config.icons.keys = {
      Up = "Up",
      Down = "Down",
      Left = "Left",
      Right = "Right",
      C = "Ctrl+",
      M = "Alt+",
      D = "Cmd+",
      S = "Shift+",
      CR = "Enter",
      Esc = "Esc",
      ScrollWheelDown = "ScrollDown",
      ScrollWheelUp = "ScrollUp",
      NL = "Enter",
      BS = "Backspace",
      Space = "Space",
      Tab = "Tab",
      F1 = "F1",
      F2 = "F2",
      F3 = "F3",
      F4 = "F4",
      F5 = "F5",
      F6 = "F6",
      F7 = "F7",
      F8 = "F8",
      F9 = "F9",
      F10 = "F10",
      F11 = "F11",
      F12 = "F12",
    }
  end

  local wk = require "which-key"
  local get_icon = Config.get_custom_icon
  local leader_group_which_key = {
    { "<Leader>b", mode = "n", group = get_icon("TabBar", 1, true) .. "Buffer" },
    { "<Leader>d", mode = "n", group = get_icon("Debugger", 1, true) .. "Debugger" },
    { "<Leader>e", mode = "n", group = get_icon("FolderTree", 1, true) .. "Explore/Edit" },
    { "<Leader>f", mode = "n", group = get_icon("Search", 1, true) .. "Find" },
    { "<Leader>g", mode = { "n", "x" }, group = get_icon("Git", 1, true) .. "Git" },
    { "<Leader>l", mode = { "n", "x" }, group = get_icon("ActiveLSP", 1, true) .. "Language Tools" },
    { "<Leader>S", mode = "n", group = get_icon("Session", 1, true) .. "Session" },
    { "<Leader>p", mode = "n", group = get_icon("Package", 1, true) .. "Plugins" },
  }

  wk.add(leader_group_which_key)
  wk.setup(config)
  _G.wk = wk
end)
