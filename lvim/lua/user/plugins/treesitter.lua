lvim.builtin.treesitter.playground.enable                       = true
lvim.builtin.treesitter.context_commentstring.config.typescript = { __default = '// %s', __multiline = '/** %s */' }
lvim.builtin.treesitter.matchup                                 = {
  enable = true,
  include_match_words = true,
}
lvim.builtin.treesitter.autotag.enable                          = true

lvim.builtin.treesitter.ensure_installed = {
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
}
lvim.builtin.treesitter.rainbow = {
  enable = true,
  -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
  extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
  max_file_lines = nil, -- Do not enable for files with more than n lines, int
  -- colors = {}, -- table of hex strings
  -- termcolors = {} -- table of colour name strings
}
lvim.builtin.treesitter.matchup.enable = true
lvim.builtin.treesitter.highlight.enabled = true
