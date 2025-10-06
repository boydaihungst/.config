---@type LazySpec
return {
  "folke/noice.nvim",
  optional = true,
  enabled = true,
  opts = {
    lsp = {
      hover = {
        enabled = false,
      },
      signature = {
        enabled = false,
      },
      progress = { enabled = true, view = "mini" }, -- Optional: If you want less clutter
    },
    presets = {
      bottom_search = false, -- use a classic bottom cmdline for search
      command_palette = true, -- If you're using a command palette (e.g., dressing.nvim)
      long_message_to_split = false, -- long messages will be sent to a split
      lsp_doc_border = true,
    },
    messages = {
      enabled = true, -- Ensure messages are enabled
      view_search = false, -- view for search count messages. Set to `false` to disable
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "search_count",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "Starting Supermaven" },
            { find = "Supermaven Free Tier" },
            -- disable deprecated message
            { find = 'is deprecated. Run ":checkhealth vim.deprecated' },
            -- { find = "deprecated" },
          },
        },
        skip = true,
      },
      -- Hide recoding message -> use heirline instead
      {
        filter = {
          event = "msg_showmode",
          find = "recording",
        },
        view = "mini",
        skip = true,
      },
      {
        filter = {
          event = "msg_show",
          find = "Hop %d char:",
        },
        view = "mini",
      },
      {
        filter = { event = "msg_showmode" },
        view = "mini",
      },
    },
  },
}
