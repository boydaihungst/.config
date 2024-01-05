lvim.builtin.treesitter.playground.enable                       = true
lvim.builtin.treesitter.context_commentstring.config.typescript = { __default = '// %s', __multiline = '/** %s */' }
lvim.builtin.treesitter.matchup                                 = {
  enable = true,
  include_match_words = true,
}
lvim.builtin.treesitter.autotag.enable                          = true

lvim.builtin.treesitter.ensure_installed                        = {
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
  "query"
}
lvim.builtin.treesitter.rainbow                                 = {
  enable = true,
  -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
  extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
  max_file_lines = 2000, -- Do not enable for files with more than n lines, int
  -- colors = {}, -- table of hex strings
  -- termcolors = {} -- table of colour name strings
}
lvim.builtin.treesitter.matchup.enable                          = true
lvim.builtin.treesitter.highlight                               = {
  enable = true, -- false will disable the whole extension
  additional_vim_regex_highlighting = false,
  disable = function(lang, buf)
    if vim.tbl_contains({ "latex" }, lang) then
      return true
    end
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    if vim.tbl_contains({ "typescript", "vue", "javascript" }, lang) and ok and stats and stats.size > (50 * 1024) --50Kb
    then
      return true
    end
    -- other files: 1Mb
    local status_ok, big_file_detected = pcall(vim.api.nvim_buf_get_var, buf, "bigfile_disable_treesitter")
    return status_ok and big_file_detected
  end,
}
