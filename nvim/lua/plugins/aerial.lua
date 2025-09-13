---@type LazySpec
return {
  "stevearc/aerial.nvim",
  optional = true,
  opts = {
    close_automatic_events = { "unfocus", "unsupported" },
    highlight_on_hover = true,
    -- Jump to symbol in source window when the cursor moves
    autojump = true,

    -- Automatically open aerial when entering supported buffers.
    -- This can be a function (see :help aerial-open-automatic)
    open_automatic = false,

    -- -- Use symbol tree for folding. Set to true or false to enable/disable
    -- -- Set to "auto" to manage folds if your previous foldmethod was 'manual'
    -- -- This can be a filetype map (see :help aerial-filetype-map)
    manage_folds = false,
    --
    -- -- When you fold code with za, zo, or zc, update the aerial tree as well.
    -- -- Only works when manage_folds = true
    link_folds_to_tree = true,
    --
    -- -- Fold code when you open/collapse symbols in the tree.
    -- -- Only works when manage_folds = true
    link_tree_to_folds = true,
  },
}
