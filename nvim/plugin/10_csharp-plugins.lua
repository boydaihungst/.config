later(function()
  local function setup_dotnet_tools()
    local home = vim.uv.os_homedir()
    local sep = vim.uv.os_uname().sysname == "Windows_NT" and ";" or ":"
    local tools_path = home .. "/.dotnet/tools"
    if vim.uv.os_uname().sysname == "Windows_NT" then tools_path = tools_path:gsub("/", "\\") end
    if not string.find(vim.env.PATH, tools_path, 1, true) then vim.env.PATH = vim.env.PATH .. sep .. tools_path end
  end

  setup_dotnet_tools()

  local is_dotnet_available = vim.fn.executable "dotnet" == 1
  local is_dev_tools_available
  local is_ef_cli_available = vim.fn.executable "dotnet-ef" == 1
  local is_easydotnet_cli_available = vim.fn.executable "dotnet-easydotnet" == 1

  local install_external_deps = function()
    if not is_dotnet_available then return vim.notify "Easy-dotnet requires dotnet installed" end

    if not is_ef_cli_available then
      vim.schedule(function() vim.notify "Installing: dotnet entity framework" end)
      local result = vim.system({ "dotnet", "tool", "install", "-g", "dotnet-ef" }, { text = true }):wait()
      if result.code == 0 then
        vim.schedule(function() vim.notify "Installed successfully: dotnet entity framework" end)
        is_ef_cli_available = true
      else
        vim.schedule(function() vim.notify("Error:\n" .. result.stderr, vim.log.levels.ERROR) end)
      end
    end

    if not is_easydotnet_cli_available then
      vim.schedule(function() vim.notify "Installing: EasyDotnet" end)
      local result = vim.system({ "dotnet", "tool", "install", "-g", "EasyDotnet" }, { text = true }):wait()
      if result.code == 0 then
        vim.schedule(function() vim.notify "Installed successfully: EasyDotnet" end)
        is_easydotnet_cli_available = true
      else
        vim.schedule(function() vim.notify("Error:\n" .. result.stderr, vim.log.levels.ERROR) end)
      end
    end
  end

  vim.pack.on_packchanged(
    "easy-dotnet.nvim",
    { "install", "update" },
    install_external_deps,
    "Easy-dotnet install/update"
  )
  install_external_deps()

  add {
    -- "https://github.com/Decodetalkers/csharpls-extended-lsp.nvim",
    "https://github.com/GustavEikaas/easy-dotnet.nvim",
    "https://github.com/seblyng/roslyn.nvim",
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "1.x" },
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/mfussenegger/nvim-dap",
  }

  require("roslyn").setup {
    silent = true,
  }
  require("easy-dotnet").setup {
    managed_terminal = {
      auto_hide = true, -- auto hides terminal if exit code is 0
      auto_hide_delay = 1000, -- delay before auto hiding, 0 = instant
    },
    -- Optional configuration for external terminals (matches nvim-dap structure)
    external_terminal = nil,
    lsp = {
      enabled = false, -- we use c_sharp_ls or roslyn instead
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
      if vim.pack.is_available "toggleterm.nvim" and _G.toggleterm then
        _G.toggleterm.toggle_term_cmd { cmd = command, direction = "float" }
        return
      end
      vim.cmd "vsplit"
      vim.cmd("term " .. command)
    end,
    -- Disable mappings for csproj and fsproj, when use dev-tools custom actions instead
    csproj_mappings = (function()
      if is_dev_tools_available ~= nil then return not is_dev_tools_available end
      is_dev_tools_available = vim.pack.is_available "dev-tools.nvim"
      return not is_dev_tools_available
    end)(),
    fsproj_mappings = (function()
      if is_dev_tools_available ~= nil then return not is_dev_tools_available end
      is_dev_tools_available = vim.pack.is_available "dev-tools.nvim"
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
    picker = vim.pack.is_available "telescope.nvim" and "telescope"
      or vim.pack.is_available "fzf-lua" and "fzf"
      or vim.pack.is_available "snacks.nvim" and "snacks"
      or "basic",
  }
  local prefix = "<leader>le"
  if MiniFiles then
    Config.new_autocmd("User", "MiniFilesBufferCreate", function(args)
      local buf_id = args.data.buf_id
      vim.keymap.set("n", prefix .. "n", function()
        local fs_entry = MiniFiles.get_fs_entry(buf_id)
        if fs_entry == nil then return vim.notify "Cursor not on valid entry" end
        local path = vim.fs.dirname(fs_entry.path)

        MiniFiles.close()
        require("easy-dotnet").create_new_item(path, function() MiniFiles.open(path) end)
      end, { buf = buf_id, desc = "Create file via .NET" })
    end, "Create file via .NET in minifiles")
  end

  local blink_avail, blink = pcall(require, "blink.cmp")
  if blink_avail then
    blink.add_filetype_source("msbuild", "easy-dotnet")
    blink.add_source_provider("easy-dotnet", {
      name = "easy-dotnet",
      enabled = true,
      module = "easy-dotnet.completion.blink",
      score_offset = 10000,
      async = true,
    })
  end

  if wk and MiniIcons then
    wk.add {
      { prefix, group = MiniIcons.get_icon("filetype", "cs") .. " Dotnet", mode = { "n" } },
    }
  end

  Config.new_autocmd("BufReadPost", "*.fsproj", function(args)
    local bufnr = args.buf
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    ---@type vim.keymap.set.Opts
    local key_opts = { buf = bufnr, silent = true }
    -- Entity framework
    vim.keymap.set("n", prefix .. "r", function()
      local easy_dotnet_proj = require "easy-dotnet.fsproj-mappings"
      coroutine.wrap(function() easy_dotnet_proj.add_project_reference(bufname) end)()
    end, vim.tbl_extend("force", key_opts, { desc = "Add project reference" }))
  end, ".NET mappings fsproj")

  Config.new_autocmd("BufReadPost", "*.csproj", function(args)
    local bufnr = args.buf
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    ---@type vim.keymap.set.Opts
    local key_opts = { buf = bufnr, silent = true }
    -- Entity framework
    vim.keymap.set("n", prefix .. "r", function()
      local easy_dotnet_proj = require "easy-dotnet.csproj-mappings"
      coroutine.wrap(function() easy_dotnet_proj.add_project_reference(bufname) end)()
    end, vim.tbl_extend("force", key_opts, { desc = "Add project reference" }))
  end, ".NET mappings csproj")

  Config.new_autocmd("LspAttach", nil, function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Only apply if the server is Roslyn
    if client and (client.name == "roslyn" or client.name == "easy_dotnet") then
      -- Fix indent
      vim.bo[args.buf].indentexpr = "GetCSIndent(v:lnum)"
      local bufnr = args.buf
      -- local bufname = vim.api.nvim_buf_get_name(bufnr)
      ---@type vim.keymap.set.Opts
      local key_opts = { buf = bufnr, silent = true }

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

      if is_ef_cli_available then
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
  end, ".NET mappings csproj")
end)
