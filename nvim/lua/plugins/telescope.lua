-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Telescope

---@type LazySpec
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-media-files.nvim",
    },
    -- the first parameter is the plugin specification
    -- the second is the table of options as set up in Lazy with the `opts` key
    opts = {
      defaults = {
        wrap_results = true,
        scroll_strategy = "limit",
        preview = {
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
        },
      },
    },
    config = function(plugin, opts)
      -- run the core AstroNvim configuration function with the options table
      require "astronvim.plugins.configs.telescope" (plugin, opts)

      -- require telescope and load extensionsas necessary
      require("telescope").load_extension "media_files"
    end,
  },
}
