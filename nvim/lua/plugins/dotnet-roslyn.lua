local is_dotnet_available = vim.fn.executable "dotnet" == 1
---@type LazySpec
return {
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = {
      registries = {
        "github:Crashdummyy/mason-registry",
        "github:boydaihungst/mason-registry",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "c_sharp" })
      end
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      if is_dotnet_available then
        opts.ensure_installed =
          require("astrocore").list_insert_unique(opts.ensure_installed, { "roslyn", "msbuild_project_tools_server" })
      end
    end,
    dependencies = {
      {
        "AstroNvim/astrolsp",
        opts = {
          config = {
            msbuild_project_tools_server = {
              cmd = { "msbuild_project_tools_server" },
              -- Configure default capabilities
            },
          },
        },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      if is_dotnet_available then
        opts.ensure_installed = require("astrocore").list_insert_unique(
          opts.ensure_installed,
          { "roslyn", "csharpier", "msbuild_project_tools_server" }
        )
      end
    end,
  },

  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      silent = true,
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "coreclr" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      if is_dotnet_available then
        opts.ensure_installed =
          require("astrocore").list_insert_unique(opts.ensure_installed, { "csharpier", "netcoredbg" })
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "Nsidorenco/neotest-vstest",
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = {
          options = {
            g = {
              --- @type neotest_vstest.Config
              neotest_vstest = {
                build_opts = {
                  -- Arguments that will be added to all `dotnet build` and `dotnet msbuild` commands
                  additional_args = {},
                },
                -- If project contains directories which are not supposed to be searched for solution files
                discovery_directory_filter = function(search_path)
                  -- ignore hidden directories
                  return search_path:match "/%."
                end,
                -- if no obvious parent solution is found, broadly scan downward for solution files from current path. This can freeze Neovim when started from broad directories.
                broad_recursive_discovery = true,
                timeout_ms = 30 * 5 * 1000, -- number of milliseconds to wait before timeout while communicating with adapter client
              },
            },
          },
        },
      },
    },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-vstest"(require("astrocore").plugin_opts "neotest-vstest"))
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
    },
  },
}
