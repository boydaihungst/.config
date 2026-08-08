---@type LazySpec
return {
  "s1n7ax/nvim-window-picker",
  main = "window-picker",
  lazy = true,
  optional = true,
  opts = {
    hint = "floating-big-letter",
    picker_config = {
      statusline_winbar_picker = { use_winbar = "smart" },
    },
    filter_rules = {
      -- when there is only one window available to pick from, use that window
      -- without prompting the user to select
      autoselect_one = true,

      -- whether you want to include the window you are currently on to window
      -- selection or not
      include_current_win = false,

      -- whether to include windows marked as unfocusable
      include_unfocusable_windows = false,

      -- filter using buffer options
      bo = {
        -- if the file type is one of following, the window will be ignored
        filetype = {
          "NvimTree",
          "neo-tree",
          "notify",
          "snacks_notif",
          "aerial",
          "undotree",
          "dapui_scopes",
          "dapui_breakpoints",
          "dapui_stacks",
          "dapui_watches",
          "dap_repl",
          "dapui_console",
          "neotest-summary",
          "neotest-output-panel",
          "dbui",
          "codecompanion",
          -- Still not work as expected
          "OverseerList",
          "comment-box",
          "grug-far",
          "qf",
          "sagaoutline",
        },

        -- if the file type is one of following, the window will be ignored
        buftype = { "terminal", "quickfix", "prompt", "help", "nofile" },
      },

      -- filter using window options
      wo = {},

      -- if the file path contains one of following names, the window
      -- will be ignored
      file_path_contains = {},

      -- if the file name contains one of following names, the window will be
      -- ignored
      file_name_contains = {},
    },
  },
}
