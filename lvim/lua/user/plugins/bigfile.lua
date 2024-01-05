lvim.builtin.bigfile = {
  active = true,
  config = {
    filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
    pattern = { "*" }, -- autocmd pattern
    features = { -- features to disable
      -- "indent_blankline",
      "illuminate",
      "lsp",
      "treesitter",
      "syntax",
      "matchparen",
      "vimopts",
      "filetype",
      "colorizer", {
      name = "colorizer", -- name
      opts = {
        defer = false, -- true if `disable` should be called on `BufReadPost` and not `BufReadPre`
      },
      disable = function() -- called to disable the feature
        vim.cmd "ColorizerDetachFromBuffer"
      end,
    }
    },
  },
}
