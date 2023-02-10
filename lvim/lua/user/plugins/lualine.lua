local lualine_components                        = require("lvim.core.lualine.components")
lvim.builtin.lualine.sections.lualine_a         = {
  lualine_components.mode,
  lualine_components.filename,
}
lvim.builtin.lualine.sections.lualine_x         = {
  lualine_components.diagnostics,
  lualine_components.treesitter,
  lualine_components.encoding,
  lualine_components.filetype,
}
lvim.builtin.lualine.options.globalstatus       = false
lvim.builtin.lualine.options.disabled_filetypes = {
  "fugitive",
  "spectre_panel",
  "tagbar",
  "fzf",
  "Trouble",
  "NvimTree",
  "quickfix",
  "minimap",
  "packer",
  "telescope",
  "alpha",
}
lvim.builtin.lualine.options.theme              = "onedark"
lvim.builtin.lualine.options.refresh            = {
  winbar = 200,
}
