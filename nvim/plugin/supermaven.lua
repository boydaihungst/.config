on_event("InsertEnter", function()
  add {
    "https://github.com/supermaven-inc/supermaven-nvim",
  }

  require("supermaven-nvim").setup {
    ignore_filetypes = {
      "sql",
      "grug-far",
      "snacks_picker_input",
      "neo-tree-popup",
      "minifiles",
      "bigfile",
      "largefile",
    },
    --return true -> disable
    -- condition = function() return require("largefile").is_large() end,
    keymaps = {
      accept_suggestion = "<C-l>",
      clear_suggestion = "<C-h>",
      accept_word = "<C-w>",
    },
    log_level = "off",
    disable_inline_completion = false, -- disables inline completion for use with cmp
    disable_keymaps = false, -- disables built in keymaps for more manual control
    -- color = {
    --   suggestion_color = "#ffffff",
    --   cterm = 244,
    -- },
  }
end)
