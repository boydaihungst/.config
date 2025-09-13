---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  optional = true,
  opts = function(_, opts)
    -- add more things to the ensure_installed table protecting against community packs modifying it
    opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
      "bash",
      "c",
      "javascript",
      "json",
      "lua",
      "python",
      "typescript",
      "tsx",
      "css",
      "rust",
      "java",
      "yaml",
      "vue",
      "query",
      "graphql",
      "markdown",
      "markdown_inline",
      "vim",
      "hyprlang",
      "git_config",
      "fish",
      "rasi",
      -- add more arguments for adding more treesitter parsers
    })
    opts.matchup = {
      enable = true,
      include_match_words = true,
    }
    vim.treesitter.language.register("bash", "kitty")
  end,
}
