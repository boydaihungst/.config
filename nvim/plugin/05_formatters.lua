local formatters_cfg = {
  formatters_by_ft = {
    fish = { "fish_indent" },
    toml = { "taplo" },
    markdown = { "markdown-toc", "prettierd", stop_after_first = false },
    ["markdown.mdx"] = { "markdown-toc", "prettierd", stop_after_first = false },
    cs = { "csharpier" },
    sh = { "shfmt", "shellcheck" },
    zsh = { "shfmt", "shellcheck" },
    lua = { "stylua", stop_after_first = false },
    nginx = { "nginxfmt" },

    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    vue = { "prettierd" },
    css = { "prettierd" },
    scss = { "prettierd" },
    less = { "prettierd" },
    html = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    yaml = { "prettierd" },
    graphql = { "prettierd" },
    handlebars = { "prettierd" },
    svelte = { "prettierd" },
    astro = { "prettierd" },
    htmlangular = { "prettierd" },
    proto = { "buf" },
    python = { "black", "isort" },
    sql = { "sqlfluff" },
  },
  formatters = {
    -- nginxfmt = {
    --   -- Change where to find the command
    --   command = os.getenv "HOME" .. "/.venv/bin/nginxfmt",
    -- },
    taplo = {
      -- prepend_args = { "-o", "" },
      env = {
        TAPLO_CONFIG = os.getenv "HOME" .. "/.config/.taplo.toml",
      },
    },
    ["clang-format"] = {},
    stylua = {
      prepend_args = { "--syntax", "LuaJIT" },
    },
    sqlfluff = {
      require_cwd = false,
    },
  },
}

later(function()
  add { "https://github.com/stevearc/conform.nvim" }
  local conform = require "conform"
  conform.setup(vim.tbl_deep_extend("force", {
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter  available
      lsp_format = "fallback",
    },
    format_on_save = function(bufnr)
      if vim.F.if_nil(vim.b[bufnr].autoformat, vim.g.autoformat, true) then return { lsp_format = "fallback" } end
    end,
    -- Set the log level. Use `:ConformInfo` to see the location of the log file.
    log_level = vim.log.levels.OFF,
    -- Conform will notify you when a formatter errors
    notify_on_error = true,
    -- Conform will notify you when no formatters are available for the buffer
    notify_no_formatters = true,
  }, formatters_cfg))

  vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = {
        start = { args.line1, 0 },
        ["end"] = { args.line2, end_line:len() },
      }
    end
    conform.format { async = true, range = range }
  end, { desc = "Format buffer", range = true })

  vim.keymap.set("n", "<Leader>lC", "<Cmd>ConformInfo<CR>", { desc = "Formatter information" })
  vim.keymap.set("n", "<Leader>lf", "<Cmd>Format<CR>", { desc = "Format" })
end)
