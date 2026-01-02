---@type LazySpec
return {
  "HakonHarnes/img-clip.nvim",
  optional = true,
  opts = {
    filetypes = {
      codecompanion = {
        prompt_for_file_name = false,
        template = "[Image]($FILE_PATH)",
        use_absolute_path = true,
      },
    },
  },
}
