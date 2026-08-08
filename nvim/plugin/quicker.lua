later(function()
  add {
    "https://github.com/stevearc/quicker.nvim",
  }
  local quicker = require "quicker"
  quicker.setup {
    keys = {
      {
        ">",
        function() quicker.expand { before = 2, after = 2, add_to_existing = true } end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function() quicker.collapse() end,
        desc = "Collapse quickfix context",
      },
    },
    follow = {
      -- When quickfix window  open, scroll to closest item to the cursor
      enabled = true,
    },
  }
  -- Quicker.nvim Keymaps
  vim.keymap.set("n", "<C-q>", function() quicker.toggle { focus = true } end, { desc = "Toggle quickfix" })

  vim.keymap.set("n", "<Leader>eq", function() quicker.toggle { focus = true } end, { desc = "Toggle quickfix" })

  vim.keymap.set(
    "n",
    "<Leader>eQ",
    function() quicker.toggle { focus = true, loclist = true } end,
    { desc = "Toggle loclist" }
  )
end)
