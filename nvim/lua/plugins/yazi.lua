---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = {
    { "folke/snacks.nvim" },
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        local maps, prefix = opts.mappings, "<Leader>"

        maps.n[prefix .. "-"] = {
          "<cmd>Yazi cwd<cr>",
          desc = "Open yazi - CWD",
        }
        maps.n[prefix .. "o"] = {
          "<cmd>Yazi<cr>",
          desc = "Open yazi - current file",
        }
      end,
    },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-s>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-f>",
      replace_in_directory = "<c-g>",
      cycle_open_buffers = "<tab>",
      copy_relative_path_to_selected_files = "<c-y>",
      send_to_quickfix_list = "<c-q>",
      change_working_directory = "<c-\\>",
    },
    floating_window_scaling_factor = 0.7,
    -- open visible splits as yazi tabs for easy navigation. Requires a yazi
    -- version more recent than 2024-08-11
    -- https://github.com/mikavilpas/yazi.nvim/pull/359
    open_multiple_tabs = true,
    -- use_ya_for_events_reading = true,
    highlight_groups = {
      -- See https://github.com/mikavilpas/yazi.nvim/pull/180
      hovered_buffer = { link = "CursorLine" },
      -- See https://github.com/mikavilpas/yazi.nvim/pull/351
      hovered_buffer_in_same_directory = nil,
    },
  },
}
