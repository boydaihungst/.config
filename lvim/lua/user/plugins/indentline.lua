lvim.builtin.indentlines.setup = function()
  lvim.builtin.indentlines = {
    active = true,
    on_config_done = nil,
    options = {
      enabled = true,
      exclude = {
        filetypes = {
          "help",
          "startify",
          "dashboard",
          "lazy",
          "neogitstatus",
          "NvimTree",
          "Trouble",
          "text"
        },
        buftypes = {
          "terminal",
          "nofile"
        }
      },
      indent = {
        char = lvim.icons.ui.LineLeft
      },
      scope = {
        char = lvim.icons.ui.LineLeft
      }

      -- context_char = lvim.icons.ui.LineLeft,
      -- show_trailing_blankline_indent = false,
      -- show_first_indent_level = true,
      -- use_treesitter = true,
      -- show_current_context = true,
    },
  }
end
