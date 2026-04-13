---@type LazySpec
return {
  "stevearc/conform.nvim",
  event = "User AstroFile",
  cmd = "ConformInfo",
  opts = {
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function(bufnr)
      if vim.F.if_nil(vim.b[bufnr].autoformat, vim.g.autoformat, true) then return { lsp_format = "fallback" } end
    end,
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
    { "williamboman/mason.nvim", optional = true },
  },
  specs = {
    { "AstroNvim/astrolsp", optional = true, opts = { formatting = { disabled = true } } },
    { "jay-babu/mason-null-ls.nvim", optional = true, opts = { methods = { formatting = false } } },
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>lI"] = { "<Cmd>ConformInfo<CR>", desc = "Formatter information" },
            ["<Leader>lf"] = { function() vim.cmd.Format() end, desc = "Format buffer" },
            ["<Leader>lc"] = { function() vim.cmd.ConformInfo() end, desc = "Conform information" },
            ["<Leader>uf"] = {
              function()
                vim.b.autoformat = not vim.F.if_nil(vim.b.autoformat, vim.g.autoformat, true)
                require("astrocore").notify(
                  string.format("Buffer autoformatting %s", vim.b.autoformat and "on" or "off")
                )
              end,
              desc = "Toggle autoformatting (buffer)",
            },
            ["<Leader>uF"] = {
              function()
                vim.g.autoformat, vim.b.autoformat = not vim.F.if_nil(vim.g.autoformat, true), nil
                require("astrocore").notify(
                  string.format("Global autoformatting %s", vim.g.autoformat and "on" or "off")
                )
              end,
              desc = "Toggle autoformatting (global)",
            },
          },
        },
        options = { opt = { formatexpr = "v:lua.require'conform'.formatexpr()" } },
        commands = {
          Format = {
            function(args)
              local range = nil
              if args.count ~= -1 then
                local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
                range = {
                  start = { args.line1, 0 },
                  ["end"] = { args.line2, end_line:len() },
                }
              end
              require("conform").format { async = true, range = range }
            end,
            desc = "Format buffer",
            range = true,
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
  },
}
