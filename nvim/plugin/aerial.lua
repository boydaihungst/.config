later(function()
  add { "https://github.com/stevearc/aerial.nvim" }
  local aerial = require "aerial"
  aerial.setup {
    attach_mode = "global",
    backends = { "lsp", "treesitter", "markdown", "man" },
    layout = { min_width = 28 },
    filter_kind = false,
    guides = {
      mid_item = "├ ",
      last_item = "└ ",
      nested_top = "│ ",
      whitespace = "  ",
    },
    keymaps = {
      ["[y"] = "actions.prev",
      ["]y"] = "actions.next",
      ["[Y"] = "actions.prev_up",
      ["]Y"] = "actions.next_up",
      ["{"] = false,
      ["}"] = false,
      ["[["] = false,
      ["]]"] = false,
    },
    nav = {
      preview = true,
      keymaps = {
        ["<CR>"] = "actions.jump",
        ["o"] = "actions.jump",
        ["<C-w>v"] = "actions.jump_vsplit",
        ["<C-w>s"] = "actions.jump_split",
        ["<C-h>"] = "actions.left",
        ["<C-l>"] = "actions.right",
        ["q"] = "actions.close",
        ["<ESC>"] = "actions.close",
      },
    },
    close_automatic_events = { "unfocus", "unsupported" },
    highlight_on_hover = true,
    autojump = true,
    open_automatic = false,
    manage_folds = false,
    link_folds_to_tree = true,
    link_tree_to_folds = true,
    show_guides = true,
    disable_max_lines = Config.default_large_buf_opts.lines,
    -- disable aerial on files this size or larger (in bytes)
    disable_max_size = Config.default_large_buf_opts.size,
  }

  vim.keymap.set("n", "]y", function() aerial.next(vim.v.count1) end, { desc = "Next symbol" })
  vim.keymap.set("n", "[y", function() aerial.prev(vim.v.count1) end, { desc = "Previous symbol" })
  vim.keymap.set("n", "]Y", function() aerial.next_up(vim.v.count1) end, { desc = "Next symbol upwards" })
  vim.keymap.set("n", "[Y", function() aerial.prev_up(vim.v.count1) end, { desc = "Previous symbol upwards" })
  vim.keymap.set("n", "<leader>lS", function() aerial.toggle { direction = "right" } end, { desc = "Symbols" })
end)
