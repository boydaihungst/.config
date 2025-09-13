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
    },
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>lI"] = { "<Cmd>ConformInfo<CR>", desc = "Formatter information" }
        end,
      },
    },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    enabled = false,
  },
}
