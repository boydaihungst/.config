local is_dev_tools_available
local is_ef_available = vim.fn.executable "dotnet-ef" == 1

---@type LazySpec
return {
  "GustavEikaas/easy-dotnet.nvim",
  cmd = { "Dotnet" },
  enabled = true,
  build = function()
    if not vim.fn.executable "dotnet" then error "Easy-dotnet requires dotnet installed" end
    if not is_ef_available then
      vim.system({ "dotnet", "tool", "install", "-g", "dotnet-ef" }, { text = true }, function(obj)
        if obj.code == 0 then
          vim.notify "Installed successfully: dotnet entity framework"
          is_ef_available = true
        else
          vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
        end
      end)
    else
      vim.system({ "dotnet", "tool", "update", "-g", "dotnet-ef" }, { text = true }, function(obj)
        if obj.code == 0 then
          vim.notify "Updated successfully: dotnet entity framework"
        else
          vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
        end
      end)
    end
    if not vim.fn.executable "dotnet-easydotnet" == 1 then
      vim.system({ "dotnet", "tool", "install", "-g", "dotnet-easydotnet" }, { text = true }, function(obj)
        if obj.code == 0 then
          vim.notify "Installed successfully: EasyDotnet"
          is_ef_available = true
        else
          vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
        end
      end)
    else
      vim.system({ "dotnet", "tool", "update", "-g", "dotnet-easydotnet" }, { text = true }, function(obj)
        if obj.code == 0 then
          vim.notify "Updated successfully: EasyDotnet"
        else
          vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
        end
      end)
    end
  end,

  opts = {
    managed_terminal = {
      auto_hide = true, -- auto hides terminal if exit code is 0
      auto_hide_delay = 1000, -- delay before auto hiding, 0 = instant
    },
    -- Optional configuration for external terminals (matches nvim-dap structure)
    external_terminal = nil,
    lsp = {
      enabled = (function()
        local _, astrocore = pcall(require, "astrocore")
        return not astrocore.is_available "roslyn.nvim"
      end)(), -- Enable builtin roslyn lsp
      preload_roslyn = true, -- Start loading roslyn before any buffer is opened
      roslynator_enabled = true, -- Automatically enable roslynator analyzer
      easy_dotnet_analyzer_enabled = true, -- Enable roslyn analyzer from easy-dotnet-server
      auto_refresh_codelens = true,
      analyzer_assemblies = {}, -- Any additional roslyn analyzers you might use like SonarAnalyzer.CSharp
      config = {},
    },
    debugger = {
      -- Path to custom coreclr DAP adapter
      -- easy-dotnet-server falls back to its own netcoredbg binary if bin_path is nil
      bin_path = vim.fn.executable "netcoredbg" == 1 and vim.fn.exepath "netcoredbg",
      console = "integratedTerminal", -- Controls where the target app runs: "integratedTerminal" (Neovim buffer) or "externalTerminal" (OS window)
      apply_value_converters = true,
      auto_register_dap = true,
      mappings = {
        open_variable_viewer = { lhs = "T", desc = "open variable viewer" },
      },
    },
    ---@type TestRunnerOptions
    test_runner = {
      auto_start_testrunner = false,
      mappings = {
        run_test_from_buffer = { lhs = "<leader>Tc", desc = "Run test under cursor" },
        get_build_errors = { lhs = "<leader>e", desc = "get build errors" },
        peek_stack_trace_from_buffer = { lhs = "<leader>TT", desc = "peek stack trace from buffer" },
        debug_test_from_buffer = { lhs = "<leader>d", desc = "run test from buffer" },
        debug_test = { lhs = "<leader>Td", desc = "debug test" },
        go_to_file = { lhs = "g", desc = "go to file" },
        run_all = { lhs = "<leader>R", desc = "run all tests" },
        run = { lhs = "<leader>r", desc = "run test" },
        peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
        expand = { lhs = "o", desc = "expand" },
        expand_node = { lhs = "E", desc = "expand node" },
        collapse_all = { lhs = "W", desc = "collapse all" },
        close = { lhs = "q", desc = "close testrunner" },
        refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
        cancel = { lhs = "<C-c>", desc = "cancel in-flight operation" },
      },
    },
    ---@param action "test" | "restore" | "build" | "run"
    terminal = function(path, action, args)
      local _, astrocore = pcall(require, "astrocore")

      args = args or ""
      local commands = {
        run = function() return string.format("dotnet run --project %s %s", path, args) end,
        test = function() return string.format("dotnet test %s %s", path, args) end,
        restore = function() return string.format("dotnet restore %s %s", path, args) end,
        build = function() return string.format("dotnet build %s %s", path, args) end,
        watch = function() return string.format("dotnet watch --project %s %s", path, args) end,
      }
      local command = commands[action]()
      if require("easy-dotnet.extensions").isWindows() == true then command = command .. "\r" end
      if astrocore then
        if astrocore.is_available "toggleterm.nvim" then
          astrocore.toggle_term_cmd { cmd = command, direction = "float" }
          return
        end
      end
      vim.cmd "vsplit"
      vim.cmd("term " .. command)
    end,
    -- Disable mappings for csproj and fsproj, when use dev-tools custom actions instead
    csproj_mappings = (function()
      local _, astrocore = pcall(require, "astrocore")
      if is_dev_tools_available ~= nil then return not is_dev_tools_available end
      is_dev_tools_available = astrocore.is_available "dev-tools.nvim"
      return not is_dev_tools_available
    end)(),
    fsproj_mappings = (function()
      local _, astrocore = pcall(require, "astrocore")
      if is_dev_tools_available ~= nil then return not is_dev_tools_available end
      is_dev_tools_available = astrocore.is_available "dev-tools.nvim"
      return not is_dev_tools_available
    end)(),
    auto_bootstrap_namespace = {
      --block_scoped, file_scoped
      type = "block_scoped",
      enabled = true,
      use_clipboard_json = {
        behavior = "prompt", --'auto' | 'prompt' | 'never',
        register = "+", -- which register to check
      },
    },
    -- choose which picker to use with the plugin
    -- possible values are "telescope" | "fzf" | "snacks" | "basic"
    -- if no picker is specified, the plugin will determine
    -- the available one automatically with this priority:
    -- telescope -> fzf -> snacks ->  basic
    picker = "snacks",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "mfussenegger/nvim-dap",
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = {} end
        local prefix = "<leader>le"
        opts.mappings.n = opts.mappings.n or {}
        opts.mappings.v = opts.mappings.v or {}
        opts.mappings.n[prefix] = { desc = "Dotnet" }
        -- Add custom key mappings here
        opts.autocmds.easydotnet_keymap = {
          {
            event = "BufReadPost",
            pattern = "*.fsproj",
            callback = function(args)
              local bufnr = args.buf
              local bufname = vim.api.nvim_buf_get_name(bufnr)
              ---@type vim.keymap.set.Opts
              local key_opts = { buffer = bufnr, silent = true }
              -- Entity framework
              vim.keymap.set("n", prefix .. "r", function()
                local easy_dotnet_proj = require "easy-dotnet.fsproj-mappings"
                coroutine.wrap(function() easy_dotnet_proj.add_project_reference(bufname) end)()
              end, vim.tbl_extend("force", key_opts, { desc = "Add project reference" }))
            end,
          },
          {
            event = "BufReadPost",
            pattern = "*.csproj",
            callback = function(args)
              local bufnr = args.buf
              local bufname = vim.api.nvim_buf_get_name(bufnr)
              ---@type vim.keymap.set.Opts
              local key_opts = { buffer = bufnr, silent = true }
              -- Entity framework
              vim.keymap.set("n", prefix .. "r", function()
                local easy_dotnet_proj = require "easy-dotnet.csproj-mappings"
                coroutine.wrap(function() easy_dotnet_proj.add_project_reference(bufname) end)()
              end, vim.tbl_extend("force", key_opts, { desc = "Add project reference" }))
            end,
          },
          {
            event = "LspAttach",
            desc = "Dotnet keymaps",
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)

              -- Only apply if the server is Roslyn
              if client and (client.name == "roslyn" or client.name == "easy_dotnet") then
                local bufnr = args.buf
                -- local bufname = vim.api.nvim_buf_get_name(bufnr)
                ---@type vim.keymap.set.Opts
                local key_opts = { buffer = bufnr, silent = true }

                -- Add Package
                vim.keymap.set(
                  "n",
                  prefix .. "a",
                  "<cmd>Dotnet add package<cr>",
                  vim.tbl_extend("force", key_opts, { desc = "Nuget packages (add)" })
                )

                -- Remove Package
                vim.keymap.set(
                  "n",
                  prefix .. "r",
                  "<cmd>Dotnet remove package<cr>",
                  vim.tbl_extend("force", key_opts, { desc = "Nuget packages (remove)" })
                )

                -- Secrets
                vim.keymap.set(
                  "n",
                  prefix .. "s",
                  "<cmd>Dotnet secrets<cr>",
                  vim.tbl_extend("force", key_opts, { desc = "Dotnet secrets" })
                )

                if is_ef_available then
                  -- Entity framework
                  vim.keymap.set(
                    "n",
                    prefix .. "d",
                    function() vim.api.nvim_feedkeys(":Dotnet ef database ", "nit", true) end,
                    vim.tbl_extend("force", key_opts, { desc = "Entity Framework database" })
                  )
                  vim.keymap.set(
                    "n",
                    prefix .. "m",
                    function() vim.api.nvim_feedkeys(":Dotnet ef migrations ", "nit", true) end,
                    vim.tbl_extend("force", key_opts, { desc = "Entity Framework migration" })
                  )
                end
              end
            end,
          },
        }
      end,
    },
    {
      "yarospace/dev-tools.nvim",
      optional = true,
      opts = {
        actions = {},
      },
    },
    {
      "saghen/blink.cmp",
      optional = true,
      opts = {
        sources = {
          default = { "easy-dotnet" },
          providers = {
            ["easy-dotnet"] = {
              name = "easy-dotnet",
              enabled = true,
              module = "easy-dotnet.completion.blink",
              score_offset = 10000,
              async = true,
            },
          },
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      optional = true,
      opts = function(_, opts)
        if opts.ensure_installed ~= "all" then
          opts.ensure_installed =
            require("astrocore").list_insert_unique(opts.ensure_installed, { "json", "xml", "sql" })
        end
      end,
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      optional = true,
      opts = {
        filesystem = {
          window = {
            mappings = {
              -- Make the mapping anything you want
              ["<C-p>"] = "create_dotnet",
            },
          },
          commands = {
            ["create_dotnet"] = function(state)
              local node = state.tree:get_node()
              local path = node.type == "directory" and node.path or vim.fs.dirname(node.path)
              require("easy-dotnet").create_new_item(
                path,
                function() require("neo-tree.sources.manager").refresh(state.name) end
              )
            end,
          },
        },
      },
    },
    -- Disable cpu and memory usage panel
    -- {
    --   "rcarriga/nvim-dap-ui",
    --   optional = true,
    --   opts = {
    --     layouts = {
    --       {
    --         elements = {
    --           { id = "easy-dotnet_cpu", size = 0.5 }, -- CPU usage panel (50% of layout)
    --           { id = "easy-dotnet_mem", size = 0.5 }, -- Memory usage panel (50% of layout)
    --         },
    --         size = 35, -- Width of the sidebar
    --         position = "right",
    --       },
    --     },
    --   },
    -- },
  },
}
