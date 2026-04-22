later(function()
  add { "https://github.com/stevearc/overseer.nvim" }
  local overseer = require "overseer"

  require("overseer").setup {
    dap = false,
    strategy = vim.pack.is_available "toggleterm" and "toggleterm",
    task_list = {
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
    },
  }
  if vim.pack.is_available "dap" then overseer.enable_dap() end

  local prefix = "<Leader>r"
  vim.keymap.set("n", prefix .. "t", "<Cmd>OverseerToggle!<CR>", { desc = "Toggle Overseer" })
  vim.keymap.set("n", prefix .. "c", "<Cmd>OverseerRunCmd<CR>", { desc = "Run Command" })
  vim.keymap.set("n", prefix .. "r", "<Cmd>OverseerRun<CR>", { desc = "Run Task" })
  vim.keymap.set("n", prefix .. "q", "<Cmd>OverseerQuickAction<CR>", { desc = "Quick Action" })
  vim.keymap.set("n", prefix .. "a", "<Cmd>OverseerTaskAction<CR>", { desc = "Task Action" })
  vim.keymap.set("n", prefix .. "i", "<Cmd>OverseerInfo<CR>", { desc = "Overseer Info" })

  if wk then wk.add {
    { prefix, group = Config.get_custom_icon("Overseer", 1, true) .. "Overseer" },
  } end
end)
