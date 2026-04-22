later(function()
  add {
    "https://github.com/yarospace/dev-tools.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/ThePrimeagen/refactoring.nvim",
  }
  require("refactoring").setup()
  require("dev-tools").setup {
    -- Custom actions: https://github.com/yarospace/dev-tools.nvim?tab=readme-ov-file#adding-code-actions
    actions = {},

    filetypes = { -- filetypes for which to attach the LSP
      include = {}, -- {} to include all, except for special buftypes, e.g. nofile|help|terminal|prompt
      exclude = {},
    },

    builtin_actions = {
      include = {}, -- filetype/group/name of actions to include or {} to include all
      exclude = {
        "Debugging",
        "Specs",
        "Convert JSON->Lua table",
        "Extract variable",
        "Extract function",
      }, -- filetype/group/name of actions to exclude or "true" to exclude all
    },

    action_opts = { -- override default options for actions
      {
        group = "Debugging",
        name = "Log vars under cursor",
        opts = {
          logger = nil, ---@type function to log debug info, default dev-tools.log
          keymap = nil, ---@type Keymap action keymap spec, e.g.
        },
      },
    },

    ui = {
      -- Use lspsaga code action
      override = false, -- override vim.ui.select, requires `snacks.nvim` to be included in dependencies or installed separately
    },

    debug = false, -- extra debug info
    cache = true, -- cache the actions on start
  }
end)
