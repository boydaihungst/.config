-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
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
      -- add more arguments for adding more treesitter parsers
    })
    -- opts.context_commentstring.config.typescript = {
    --   __default = "// %s",
    --   __multiline = "** %s */",
    -- }
    opts.matchup = {
      enable = true,
      include_match_words = true,
    }
  end,
}
