---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        toml = { "taplo" },
        markdown = { "markdown-toc", "prettierd", stop_after_first = false },
        sh = { "shfmt" },
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
      },
      -- Set the log level. Use `:ConformInfo` to see the location of the log file.
      log_level = vim.log.levels.OFF,
      -- Conform will notify you when a formatter errors
      notify_on_error = true,
      -- Conform will notify you when no formatters are available for the buffer
      notify_no_formatters = true,
      -- Custom formatters and overrides for built-in formatters
    },
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>lI"] = { "<Cmd>ConformInfo<CR>", desc = "Formatter information" },
            },
          },
        },
      },
    },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    enabled = false,
  },
  {
    "nvimtools/none-ls.nvim",
    enabled = false,
  },
}
