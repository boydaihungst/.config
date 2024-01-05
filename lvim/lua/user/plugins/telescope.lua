lvim.builtin.telescope.defaults.wrap_results     = true
lvim.builtin.telescope.theme                     = "center"
lvim.builtin.telescope.defaults.sorting_strategy = "ascending"
lvim.builtin.telescope.defaults.scroll_strategy  = "limit"
lvim.builtin.telescope.defaults.wrap_results     = true
lvim.builtin.telescope.defaults.layout_config    = {
  bottom_pane = {
    height = 25,
    preview_cutoff = 120,
    prompt_position = "top"
  },
  center = {
    height = 0.3,
    preview_cutoff = 40,
    prompt_position = "top",
    width = 0.9
  },
  cursor = {
    height = 0.9,
    preview_cutoff = 40,
    width = 0.8
  },
  horizontal = {
    height = 0.9,
    preview_cutoff = 120,
    prompt_position = "top",
    preview_width = 0.5,
    scroll_speed = 5,
    width = 0.9
  },
  vertical = {
    height = 0.9,
    preview_cutoff = 40,
    prompt_position = "bottom",
    width = 0.8
  }
}
lvim.builtin.telescope.defaults.preview          = {
  treesitter = false,
  -- filesize_limit = 1,
  timeout = 250,
  -- truncate for preview
  filesize_hook = function(filepath, bufnr, opts)
    local path = require("plenary.path"):new(filepath)
    -- opts exposes winid
    local height = vim.api.nvim_win_get_height(opts.winid)
    local lines = vim.split(path:head(height), "[\r]?\n")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end,
}
