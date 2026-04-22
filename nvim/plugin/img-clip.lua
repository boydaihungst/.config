later(function()
  add { "https://github.com/HakonHarnes/img-clip.nvim" }
  require("img-clip").setup {
    default = {
      prompt_for_file_name = false,
      drag_and_drop = {
        insert_mode = true,
      },
      use_absolute_path = vim.fn.has "win32" == 1, -- default to absolute path for windows users
    },
    filetypes = {
      codecompanion = {
        prompt_for_file_name = false,
        template = "[Image]($FILE_PATH)",
        use_absolute_path = true,
      },
    },
  }
  vim.keymap.set("n", "<Leader>P", "<CMD>PasteImage<CR>", { desc = "Paste image" })
end)
