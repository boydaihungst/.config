---@type LazySpec
return {
  "otavioschwanck/arrow.nvim",
  lazy = true,
  event = "VeryLazy",
  dependencies = {
    { "nvim-mini/mini.icons" },
  },
  opts = {
    show_icons = true,
    leader_key = "M", -- Recommended to be a single key
    buffer_leader_key = "m", -- Per Buffer Mappings
    always_show_path = false,
    separate_by_branch = true, -- Bookmarks will be separated by git branch
    hide_handbook = false, -- set to true to hide the shortcuts on menu.
    separate_save_and_remove = true, -- if true, will remove the toggle and create the save/remove keymaps.
    save_key = "cwd", -- what will be used as root to save the bookmarks. Can be also `git_root` and `git_root_bare`.
    global_bookmarks = false, -- if true, arrow will save files globally (ignores separate_by_branch)
    index_keys = "123456789zxcbnmZXVBNM,afghjklAFGHJKLwrtyuiopWRTYUIOP", -- keys mapped to bookmark index, i.e. 1st bookmark will be accessible by 1, and 12th - by c
    mappings = {
      edit = "e",
      delete_mode = "d",
      clear_all_items = "C",
      toggle = "s", -- used as save if separate_save_and_remove is true
      open_vertical = "v",
      open_horizontal = "-",
      quit = "q",
      remove = "x", -- only used if separate_save_and_remove is true
      next_item = "]",
      prev_item = "[",
    },
    window = { -- controls the appearance and position of an arrow window (see nvim_open_win() for all options)
      width = "auto",
      height = "auto",
      row = "auto",
      col = "auto",
      border = "rounded",
    },
    per_buffer_config = {
      lines = 4, -- Number of lines showed on preview.
      sort_automatically = true, -- Auto sort buffer marks.
      satellite = { -- default to nil, display arrow index in scrollbar at every update
        enable = true,
        overlap = true,
        priority = 1000,
      },
      -- zindex = 10, --default 50
      -- treesitter_context = {
      --   line_shift_down = 2,
      -- }, -- it can be { line_shift_down = 2 }, currently not usable, for detail see https://github.com/otavioschwanck/arrow.nvim/pull/43#issue-2236320268
    },
  },
}
