---@type LazySpec
return {
  "MeanderingProgrammer/render-markdown.nvim",
  optional = true,
  opts = {
    max_file_size = 2.0,
    preset = "obsidian",
    file_types = { "markdown", "Avante", "codecompanion", "help", "checkhealth" },
    anti_conceal = {
      -- This enables hiding any added text on the line the cursor is on.
      enabled = true,
      -- Which elements to always show, ignoring anti conceal behavior. Values can either be
      disabled_modes = { "n" },
      -- booleans to fix the behavior or string lists representing modes where anti conceal
      -- behavior will be ignored. Valid values are:
      --   head_icon, head_background, head_border, code_language, code_background, code_border
      --   dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
      -- ignore = {
      --   code_background = true,
      --   indent = true,
      --   sign = true,
      --   virtual_lines = true,
      -- },
      -- Number of lines above cursor to show.
      above = 30,
      -- Number of lines below cursor to show.
      below = 30,
    },
    code = {
      sign = false,
    },
    completions = {
      -- Settings for blink.cmp completions source
      blink = { enabled = false },
      -- Settings for coq_nvim completions source
      coq = { enabled = false },
      -- Settings for in-process language server completions
      lsp = { enabled = true },
    },
  },
}
