later(function()
  add { "https://github.com/LudoPinelli/comment-box.nvim" }
  require("comment-box").setup {
    comment_style = "auto",
    outer_blank_lines_above = true, -- insert a blank line above the box
    outer_blank_lines_below = true, -- insert a blank line below the box
    inner_blank_lines = true, -- insert a blank line above and below the text
    line_blank_line_above = true, -- insert a blank line above the line
    line_blank_line_below = true, -- insert a blank line below the line
  }
  local key_prefix = "<Leader>B"
  local modes = { "n", "x" }
  if wk then
    wk.add {
      { key_prefix, group = Config.get_custom_icon("CommentBox", 1, true) .. "Comment Box/Line", mode = modes },
      { key_prefix .. "b", group = "Comment Box", mode = modes },
      { key_prefix .. "l", group = "Comment Line", mode = modes },
    }
  end
  vim.keymap.set(modes, key_prefix .. "bl", "<Cmd>CBllbox<Cr>", { desc = "Comment Box Left" })
  vim.keymap.set(modes, key_prefix .. "bc", "<Cmd>CBlcbox<Cr>", { desc = "Comment Box Center" })
  vim.keymap.set(modes, key_prefix .. "br", "<Cmd>CBlrbox<Cr>", { desc = "Comment Box Right" })

  vim.keymap.set(modes, key_prefix .. "ll", "<Cmd>CBllline<Cr>", { desc = "Comment Line Left" })
  vim.keymap.set(modes, key_prefix .. "lc", "<Cmd>CBlcline<Cr>", { desc = "Comment Line Center" })
  vim.keymap.set(modes, key_prefix .. "lr", "<Cmd>CBlrline<Cr>", { desc = "Comment Line Right" })
end)
