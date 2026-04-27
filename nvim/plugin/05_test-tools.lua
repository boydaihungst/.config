later(function()
  vim.g.neotest_vstest = {
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
  }

  add {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/antoinemadec/FixCursorHold.nvim",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/nvim-neotest/neotest",
  }
  local neotest = require "neotest"
  -- NOTE: We don't use virtual text (init.lua)
  -- vim.diagnostic.config({
  --   virtual_text = {
  --     format = function(diagnostic)
  --       local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
  --       return message
  --     end,
  --   },
  -- }, vim.api.nvim_create_namespace 'neotest')

  local opts = {
    floating = { border = vim.o.winborder },
    -- Add adapter and comsumer in 10_lang_pluginslua
    adapters = {},
  }

  if vim.g.icons_enabled == false then
    opts.icons = {
      failed = "X",
      notify = "!",
      passed = "O",
      running = "*",
      skipped = "-",
      unknown = "?",
      watching = "W",
    }
  end

  neotest.setup(opts)
  local prefix = "<Leader>T"
  local watch_prefix = prefix .. "W"
  local get_file_path = function() return vim.fn.expand "%" end
  local get_project_path = function() return vim.fn.getcwd() end

  -- Neotest Main Mappings
  vim.keymap.set("n", prefix .. "t", function() neotest.run.run() end, { desc = "Run test" })
  ---@diagnostic disable-next-line: missing-fields
  vim.keymap.set("n", prefix .. "d", function() neotest.run.run { strategy = "dap" } end, { desc = "Debug test" })
  vim.keymap.set(
    "n",
    prefix .. "f",
    function() neotest.run.run(get_file_path()) end,
    { desc = "Run all tests in file" }
  )
  vim.keymap.set(
    "n",
    prefix .. "p",
    function() neotest.run.run(get_project_path()) end,
    { desc = "Run all tests in project" }
  )
  vim.keymap.set("n", prefix .. "<CR>", function() neotest.summary.toggle() end, { desc = "Test Summary" })
  vim.keymap.set("n", prefix .. "o", function() neotest.output.open() end, { desc = "Output hovered test" })
  vim.keymap.set("n", prefix .. "O", function() neotest.output_panel.toggle() end, { desc = "Toggle Output window" })

  -- Navigation
  vim.keymap.set("n", "]T", function() neotest.jump.next() end, { desc = "Next test" })
  vim.keymap.set("n", "[T", function() neotest.jump.prev() end, { desc = "Prev test" })

  -- Watch Mappings
  vim.keymap.set("n", watch_prefix .. "t", function() neotest.watch.toggle() end, { desc = "Toggle watch test" })
  vim.keymap.set(
    "n",
    watch_prefix .. "f",
    function() neotest.watch.toggle(get_file_path()) end,
    { desc = "Toggle watch all test in file" }
  )
  vim.keymap.set(
    "n",
    watch_prefix .. "p",
    function() neotest.watch.toggle(get_project_path()) end,
    { desc = "Toggle watch all tests in project" }
  )
  ---@diagnostic disable-next-line: missing-parameter
  vim.keymap.set("n", watch_prefix .. "S", function() neotest.watch.stop() end, { desc = "Stop all watches" })

  if wk then
    wk.add {
      { prefix, group = Config.get_custom_icon("Tests", 1, true) .. "Tests" },
      { watch_prefix, group = Config.get_custom_icon("Watch", 1, true) .. "Watch" },
    }
  end
end)

later(function()
  add { "https://github.com/nvim-lua/plenary.nvim", "https://github.com/andythigpen/nvim-coverage" }

  local coverage = require "coverage"
  coverage.setup {}
  local tests_prefix = "<Leader>T"
  local coverage_prefix = tests_prefix .. "C"
  if wk then
    -- group names
    wk.add {
      { coverage_prefix, group = Config.get_custom_icon("Coverage", 1, true) .. "Coverage" },
    }
  end

  vim.keymap.set("n", coverage_prefix .. "t", function() coverage.toggle() end, { desc = "Toggle coverage" })

  vim.keymap.set("n", coverage_prefix .. "s", function() coverage.summary() end, { desc = "Show coverage summary" })

  vim.keymap.set("n", coverage_prefix .. "c", function() coverage.clear() end, { desc = "Clear coverage" })

  vim.keymap.set("n", coverage_prefix .. "l", function() coverage.load(true) end, { desc = "Load and show coverage" })
end)
