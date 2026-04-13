---@type LazySpec
return {
  "HawkinsT/pathfinder.nvim",
  opts = {
    -- Search behaviour
    file_forward_limit = 0, -- Search from the cursor until the specified number of lines (for files)
    url_forward_limit = 0, -- Search from the cursor until the specified number of lines (for URLs/repos/flakes)
    scan_unenclosed_words = true, -- Include plain-text (non-delimited) file paths
    use_column_numbers = true, -- Use both line and column numbers (if supplied) for cursor movements
    open_mode = "edit", -- Open files in the current buffer (:edit), accepts string or function
    reuse_existing_window = true, -- If file is already open, go to its active window (don't reopen)
    gF_count_behaviour = "nextfile", -- [count]gF will open the next file at line `count`
    validate_urls = false, -- If true, require all url targets for next/prev_url() to resolve (slow)

    -- File resolution settings
    max_path_length = 4096, -- The maximum allowed length of any path to be scanned
    tilde_as_project_root = true, -- If true, also treat "~/..." as the working directory (e.g. project root)
    associated_filetypes = {}, -- File extensions that should be tried (also see `suffixesadd`)
    url_providers = { -- List of software forges to try when resolving owner/repo links
      "https://github.com/%s.git",
    },
    flake_providers = { -- List of Nix flake targets, e.g. github:owner/repo
      github = "https://github.com/%s",
      gitlab = "https://gitlab.com/%s",
      sourcehut = "https://git.sr.ht/%s",
    },
    enclosure_pairs = { -- Define all file path delimiters to search between
      ["("] = ")",
      ["{"] = "}",
      ["["] = "]",
      ["<"] = ">",
      ['"'] = '"',
      ["'"] = "'",
      ["`"] = "`",
    },
    url_enclosure_pairs = nil, -- If set, this will supersede enclosure_pairs for URL picking
    includeexpr = nil, -- Helper function to set `includeexpr`
    ft_overrides = {}, -- Filetype-specific settings

    -- User interaction
    remap_default_keys = true, -- Remap `gf`, `gF`, and `<leader>gf` to Pathfinder's functions
    offer_multiple_options = true, -- If multiple valid files with the same name are found, prompt for action
    pick_from_all_windows = true, -- Provide `select_file()` and `select_file_line()` targets across all visible windows
    selection_keys = { "a", "s", "d", "f", "j", "k", "l" }, -- Keys to use for selection in `select_file()` and `select_file_line()`
    tmux_mode = vim.env.TMUX ~= nil, -- If true and in a tmux session, visual selection applies to the last active tmux pane
  },
}
