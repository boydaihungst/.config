---@type LazySpec
return {
  "MeanderingProgrammer/render-markdown.nvim",
  optional = true,
  enabled = false,
  opts = {
    max_file_size = 2.0,
    preset = "obsidian",
    render_modes = { "n", "c", "t" },
    file_types = { "saga_codeaction", "markdown", "Avante", "codecompanion", "help", "checkhealth" },
    anti_conceal = {
      -- This enables hiding any added text on the line the cursor is on.
      enabled = false,
      -- Which elements to always show, ignoring anti conceal behavior. Values can either be
      -- disabled_modes = { "n" },
      -- booleans to fix the behavior or string lists representing modes where anti conceal
      -- behavior will be ignored. Valid values are:
      --   head_icon, head_background, head_border, code_language, code_background, code_border
      --   dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
      -- Number of lines above cursor to show.
      above = 0,
      -- Number of lines below cursor to show.
      below = 0,
    },
    overrides = {
      buflisted = {
        [true] = {
          anti_conceal = {
            enabled = true,
          },
        },
        [false] = {
          code = {
            language = false,
          },
        },
      },
      filetype = {},
      buftype = {},
    },
    code = {
      sign = false,
    },
    link = {
      custom = {
        web = { pattern = "^http", icon = "󰖟 " },
        discord = { pattern = "discord%.com", icon = "󰙯 " },
        github = { pattern = "github%.com", icon = "󰊤 " },
        gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
        google = { pattern = "google%.com", icon = "󰊭 " },
        neovim = { pattern = "neovim%.io", icon = " " },
        reddit = { pattern = "reddit%.com", icon = "󰑍 " },
        stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
        wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
        youtube = { pattern = "youtube%.com", icon = "󰗃 " },
      },
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
