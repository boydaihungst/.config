-- Language-based supported plugins should add to this file

on_filetype("python", function()
  if not (vim.fn.executable "fd" == 1 or vim.fn.executable "fdfind" == 1 or vim.fn.executable "fd-find" == 1) then
    add {
      "https://github.com/linux-cultist/venv-selector.nvim",
    }
    require("venv-selector").setup {}
  end

  add {
    "https://github.com/mfussenegger/nvim-dap-python",
    "https://github.com/nvim-neotest/neotest-python",
  }
  local path = vim.fn.exepath "debugpy-adapter"
  if path == "" then path = vim.fn.exepath "uv" end
  if path == "" then path = vim.fn.exepath "python" end
  require("dap-python").setup(path, {})

  if vim.pack.is_available "neotest" then
    table.insert(require("neotest.config").adapters, require "neotest-python" {})
  end
end)
