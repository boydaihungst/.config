local prefix = "<leader>r"

---@type LazySpec
return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerOpen",
    "OverseerClose",
    "OverseerToggle",
    "OverseerSaveBundle",
    "OverseerLoadBundle",
    "OverseerDeleteBundle",
    "OverseerRunCmd",
    "OverseerRun",
    "OverseerInfo",
    "OverseerBuild",
    "OverseerQuickAction",
    "OverseerTaskAction ",
    "OverseerClearCache",
  },
  ---@param opts overseer.Config
  opts = function(_, opts)
    opts.dap = false
    local astrocore = require "astrocore"
    if astrocore.is_available "toggleterm.nvim" then opts.strategy = "toggleterm" end
    opts.task_list = {
      bindings = {
        ["<C-l>"] = false,
        ["<C-h>"] = false,
        ["<C-k>"] = false,
        ["<C-j>"] = false,
        q = "<Cmd>close<CR>",
        K = "IncreaseDetail",
        J = "DecreaseDetail",
        ["<C-p>"] = "ScrollOutputUp",
        ["<C-n>"] = "ScrollOutputDown",
      },
    }
  end,
  dependencies = {
    { "AstroNvim/astroui", opts = { icons = { Overseer = "" } } },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            [prefix] = { desc = require("astroui").get_icon("Overseer", 1, true) .. "Overseer" },
            [prefix .. "t"] = { "<Cmd>OverseerToggle!<CR>", desc = "Toggle Overseer" },
            [prefix .. "c"] = { "<Cmd>OverseerRunCmd<CR>", desc = "Run Command" },
            [prefix .. "r"] = { "<Cmd>OverseerRun<CR>", desc = "Run Task" },
            [prefix .. "q"] = { "<Cmd>OverseerQuickAction<CR>", desc = "Quick Action" },
            [prefix .. "a"] = { "<Cmd>OverseerTaskAction<CR>", desc = "Task Action" },
            [prefix .. "i"] = { "<Cmd>OverseerInfo<CR>", desc = "Overseer Info" },
          },
        },
      },
    },
    {
      "catppuccin",
      optional = true,
      ---@type CatppuccinOptions
      opts = { integrations = { overseer = true } },
    },
    {
      "mfussenegger/nvim-dap",
      optional = true,
      opts = function() require("overseer").enable_dap() end,
    },
    {
      "nvim-neotest/neotest",
      optional = true,
      opts = function(_, opts)
        opts = opts or {}
        opts.consumers = opts.consumers or {}
        opts.consumers.overseer = require "neotest.consumers.overseer"
      end,
    },
  },
}
