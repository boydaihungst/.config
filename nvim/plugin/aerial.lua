later(function()
  add { "https://github.com/stevearc/aerial.nvim" }
  require("aerial").setup {
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
    on_attach = function(bufnr)
      local aerial = require "aerial"
      vim.keymap.set("n", "]y", function() aerial.next(vim.v.count1) end, { buf = bufnr, desc = "Next symbol" })
      vim.keymap.set("n", "[y", function() aerial.prev(vim.v.count1) end, { buf = bufnr, desc = "Previous symbol" })
      vim.keymap.set(
        "n",
        "]Y",
        function() aerial.next_up(vim.v.count1) end,
        { buf = bufnr, desc = "Next symbol upwards" }
      )
      vim.keymap.set(
        "n",
        "[Y",
        function() aerial.prev_up(vim.v.count1) end,
        { buf = bufnr, desc = "Previous symbol upwards" }
      )
    end,
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
end)
