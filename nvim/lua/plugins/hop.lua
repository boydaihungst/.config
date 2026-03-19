---@type LazySpec
return {
  "smoka7/hop.nvim",
  enabled = false,
  optional = true,
  cmd = { "HopChar1", "HopChar2", "HopLine", "HopPattern", "HopWord", "Hop" },
  opts = {
    excluded_filetypes = {
      "DressingSelect",
      "NvimTree",
      "Outline",
      "TelescopePrompt",
      "Trouble",
      "alpha",
      "cmp_menu",
      "dap-repl",
      "dapui_breakpoints",
      "dapui_console",
      "dapui_scopes",
      "dapui_watches",
      "dirvish",
      "flash_prompt",
      "fugitive",
      "grug-far",
      "grug-far-help",
      "grug-far-history",
      "lazy",
      "lir",
      "neo-tree",
      "neogitstatus",
      "netrw",
      "noice",
      "notify",
      "qf",
      "spectre_panel",
      "toggleterm",
      "undotree",
    },
  },
  dependencies = {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["s"] = {
            function() require("hop").hint_words { multi_windows = true } end,
            desc = "Hop hint words",
          },
          ["<S-s>"] = { function() require("hop").hint_char1 { multi_windows = true } end, desc = "Hop hint 1 char" },
        },
        v = {
          ["s"] = { function() require("hop").hint_words { extend_visual = true } end, desc = "Hop hint words" },
          ["<S-s>"] = {
            function() require("hop").hint_char1 { extend_visual = true } end,
            desc = "Hop hint 1 char",
          },
        },
      },
    },
  },
}
