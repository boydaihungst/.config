local lualine_components                        = require("lvim.core.lualine.components")
local colors                                    = require "lvim.core.lualine.colors"
lvim.builtin.lualine.sections.lualine_a         = {
  {
    function()
      return " " .. lvim.icons.ui.Target .. " "
    end,
    padding = { left = 0, right = 0 },
    color = {},
    cond = nil,
  },
  {
    "b:gitsigns_head",
  },
}
lvim.builtin.lualine.sections.lualine_b         = {
  {
    "filename",
    color = {},
    cond = nil,
    path = 1,
    symbols = {
      modified = '[+]',        -- Text to show when the file is modified.
      readonly = '[ReadOnly]', -- Text to show when the file is non-modifiable or readonly.
      unnamed = '[No Name]',   -- Text to show for unnamed buffers.
      newfile = '[New]',       -- Text to show for newly created file before first write
    }
  }
}
lvim.builtin.lualine.sections.lualine_x         = {
  lualine_components.diagnostics,
  lualine_components.treesitter,
  lualine_components.encoding,
  lualine_components.filetype,
}
lvim.builtin.lualine.options.globalstatus       = false
lvim.builtin.lualine.options.disabled_filetypes = {
  statusline = {
    "alpha",
    "fugitive",
    "spectre_panel",
    "tagbar",
    "fzf",
    "Trouble",
    "NvimTree",
    "quickfix",
    "minimap",
    "packer",
    "lazy",
    "telescope",
    "dap-repl",
    "dapui_console",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "neotest-summary",
  }
}
lvim.builtin.lualine.options.theme              = "onedark"
lvim.builtin.lualine.options.refresh            = {
  winbar = 200,
}
