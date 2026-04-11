---@type LazySpec
return {
  "j-hui/fidget.nvim",
  lazy = true,
  event = "LspAttach",
  opts = {
    -- Options related to LSP progress subsystem
    progress = {
      ignore = {}, -- List of LSP servers to ignore

      -- Options related to how LSP progress messages are displayed as notifications
      display = {
        render_limit = 5, -- How many LSP messages to show at once
        done_ttl = 1, -- How long a message should persist after completion
        done_icon = "✔", -- Icon shown when all LSP progress tasks are complete
        done_style = "Constant", -- Highlight group for completed LSP tasks
        -- Icon shown when LSP progress tasks are in progress
        progress_icon = { "dots" },
        -- Highlight group for in-progress LSP tasks
        progress_style = "WarningMsg",
        group_style = "Title", -- Highlight group for group name (LSP server name)
        icon_style = "Question", -- Highlight group for group icons
        overrides = { -- Override options from the default notification config
          rust_analyzer = { name = "rust-analyzer" },
        },
      },

      -- Options related to Neovim's built-in LSP client
      lsp = {
        progress_ringbuf_size = 0, -- Configure the nvim's LSP progress ring buffer size
        log_handler = false, -- Log `$/progress` handler invocations (for debugging)
      },
    },
  },
}
