---@type LazySpec
return {
  "yarospace/dev-tools.nvim",
  event = "LspAttach",
  cmd = "Lspsaga",
  lazy = true,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    {
      "folke/snacks.nvim",
      optional = true,
    },
    {
      "ThePrimeagen/refactoring.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
    },
  },

  opts = {
    -- Custom actions: https://github.com/yarospace/dev-tools.nvim?tab=readme-ov-file#adding-code-actions
    actions = {},

    filetypes = { -- filetypes for which to attach the LSP
      include = {}, -- {} to include all, except for special buftypes, e.g. nofile|help|terminal|prompt
      exclude = {},
    },

    builtin_actions = {
      include = {}, -- filetype/group/name of actions to include or {} to include all
      exclude = {}, -- filetype/group/name of actions to exclude or "true" to exclude all
    },

    action_opts = { -- override default options for actions
      {
        group = "Debugging",
        name = "Log vars under cursor",
        opts = {
          logger = nil, ---@type function to log debug info, default dev-tools.log
          keymap = nil, ---@type Keymap action keymap spec, e.g.
          -- {
          --   global = "<leader>dl"|{ "<leader>dl", mode = { "n", "x" } },
          --   picker = "<M-l>",
          --   hide = true,  -- hide the action from the picker
          -- }
        },
      },
      {
        group = "Specs",
        name = "Watch specs",
        opts = {
          tree_cmd = nil, ---@type string command to run the file tree, default "git ls-files -cdmo --exclude-standard"
          test_cmd = nil, ---@type string command to run tests, default "nvim -l tests/minit.lua tests --shuffle-tests -v"
          test_tag = nil, ---@type string test tag, default "wip"
          terminal_cmd = nil, ---@type function to run the terminal, default is Snacks.terminal
        },
      },
      {
        group = "Todo",
        name = "Open Todo",
        opts = {
          filename = nil, ---@type string name of the todo file, default ".todo.md"
          template = nil, ---@type string[] -- template for the todo file
        },
      },
    },

    ui = {
      override = true, -- override vim.ui.select, requires `snacks.nvim` to be included in dependencies or installed separately
      group_actions = false, -- group actions by group
      keymaps = { filter = "<C-b>", open_group = "<C-l>", close_group = "<C-h>" },
    },

    debug = false, -- extra debug info
    cache = true, -- cache the actions on start
  },
  specs = {
    {
      "boydaihungst/lspsaga.nvim",
      optional = true,
      opts = {
        lightbulb = {
          ignore = {
            clients = "dev-tools",
          },
        },
      },
    },
    {
      "kosayoda/nvim-lightbulb",
      optional = true,
      opts = {
        ignore = { clients = { "dev-tools" } },
      },
    },
  },
}
