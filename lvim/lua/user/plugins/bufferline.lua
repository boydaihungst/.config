lvim.builtin.bufferline.active                          = true
lvim.builtin.bufferline.options.offsets                 = {
  {
    filetype = "NvimTree",
    text = "File Explorer",
    highlight = "Directory",
    text_align = "center",
  },
}
lvim.builtin.bufferline.highlights                      = {
  fill = {
    fg = '#BCC4C9',
    bg = "NONE",
  },
  background = {
    fg = '#BCC4C9',
    bg = "NONE"
  },
  buffer = {
    bg = '#080A0E',
  },
  buffer_visible = {
    bg = "#080A0E",
  },
  buffer_selected = {
    bg = "#29303D",
  },
  diagnostic = {
    bg = "NONE",
  },
  diagnostic_visible = {
    bg = "#080A0E",
  },
  diagnostic_selected = {
    bg = "#29303D",
  },
  hint = {
    bg = "NONE",
  },
  hint_visible = {
    bg = "#080A0E",
  },
  hint_selected = {
    bg = "#29303D",
  },
  hint_diagnostic = {
    bg = 'NONE',
  },
  hint_diagnostic_visible = {
    bg = "#080A0E",
  },
  hint_diagnostic_selected = {
    bg = "#29303D",
  },
  info = {
    bg = 'NONE',
  },
  info_visible = {
    bg = "#080A0E",
  },
  info_selected = {
    bg = "#29303D",
  },
  info_diagnostic = {
    bg = 'NONE',
  },
  info_diagnostic_visible = {
    bg = "#080A0E",
  },
  info_diagnostic_selected = {
    bg = "#29303D",
  },
  warning = {
    bg = 'NONE',
  },
  warning_visible = {
    bg = "#080A0E",
  },
  warning_selected = {
    bg = "#29303D",
  },
  warning_diagnostic = {
    bg = 'NONE',
  },
  warning_diagnostic_visible = {
    bg = "#080A0E",
  },
  warning_diagnostic_selected = {
    bg = "#29303D",
  },
  error = {
    bg = 'NONE',
  },
  error_visible = {
    bg = "#080A0E",
  },
  error_selected = {
    bg = "#29303D",
  },
  error_diagnostic = {
    bg = 'NONE',
  },
  error_diagnostic_visible = {
    bg = "#080A0E",
  },
  error_diagnostic_selected = {
    bg = "#29303D",
  },
  modified = {
    bg = 'NONE',
  },
  modified_visible = {
    bg = "#080A0E",
  },
  modified_selected = {
    bg = "#29303D",
  },
  duplicate_selected = {
    bg = "#29303D",
  },
  duplicate_visible = {
    bg = "#080A0E",
  },
  duplicate = {
    bg = 'NONE',
  },

  separator_selected = {
    bg = "#29303D",
  },
  separator_visible = {
    bg = "#080A0E",
  },
  separator = {
    -- bg = 'NONE',
  },
  tab_separator = {
    bg = 'NONE',
  },
  tab_separator_selected = {
    bg = "#29303D",
  },
  indicator_selected = {
    bg = "#29303D",
  },
  indicator_visible = {
    bg = "#080A0E",
    bold = true
  },
  pick_selected = {
    bg = "#29303D",
    fg = "#29303D"
  },
  pick_visible = {
    bg = "#080A0E",
    fg = "#080A0E",
  },
  pick = {
    bg = 'NONE',
  },
  offset_separator = {
    bg = 'NONE',
  },
}
lvim.builtin.bufferline.options.always_show_bufferline  = true
lvim.builtin.bufferline.options.show_buffer_close_icons = false
lvim.builtin.bufferline.options.close_command           = function(bufnum)
  require("bufdelete").bufdelete(bufnum, true)
end
