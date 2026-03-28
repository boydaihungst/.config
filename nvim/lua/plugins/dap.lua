---@type LazySpec
return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        -- Default adapters: https://github.com/jay-babu/mason-nvim-dap.nvim/tree/main/lua/mason-nvim-dap/mappings/adapters
        -- Default adapters configurations: https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/configurations.lua
        firefox = function(source_name)
          local dap = require "dap"
          dap.configurations.firefox = {
            {
              name = "Firefox: Debug",
              type = "firefox",
              request = "launch",
              reAttach = true,
              url = "http://localhost:3000",
              webRoot = "${workspaceFolder}",
              firefoxExecutable = vim.fn.exepath "waterfox",
            },
          }
        end,
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local get_icon = require("astroui").get_icon
          if not opts.signs then opts.signs = {} end
          opts.signs.DapBreakpoint = {
            text = get_icon "DapBreakpoint",
            texthl = "DiagnosticInfo",
            numhl = "TinyInlineDiagnosticVirtualTextInfo",
          }
          opts.signs.DapBreakpointCondition = {
            text = get_icon "DapBreakpointCondition",
            texthl = "DiagnosticInfo",
            numhl = "TinyInlineDiagnosticVirtualTextInfo",
          }
          opts.signs.DapBreakpointRejected = {
            text = get_icon "DapBreakpointRejected",
            texthl = "DiagnosticError",
            numhl = "TinyInlineDiagnosticVirtualTextError",
          }
          opts.signs.DapLogPoint = {
            text = get_icon "DapLogPoint",
            texthl = "DiagnosticInfo",
            numhl = "TinyInlineDiagnosticVirtualTextInfo",
          }
          opts.signs.DapStopped =
            { text = get_icon "DapStopped", texthl = "DiagnosticWarn", numhl = "TinyInlineDiagnosticVirtualTextWarn" }
        end,
      },
    },
  },
}
