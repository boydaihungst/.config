---@type LazySpec
return {
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
}
