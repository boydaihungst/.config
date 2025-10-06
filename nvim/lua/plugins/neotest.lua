---@type LazySpec
return {
  {
    -- https://github.com/nvim-neotest/neotest-jest
    "nvim-neotest/neotest-jest",
    optional = true,
    opts = {
      -- neotest-jest options here
      -- Use function if need

      -- jestCommand = "npm test --",
      -- jestConfigFile = "custom.jest.config.ts",
      -- env = { CI = true },
      -- cwd = function(path) return vim.fn.getcwd() end,

      -- Running tests in watch mode
      -- jestCommand = require('neotest-jest.jest-util').getJestCommand(vim.fn.expand '%:p:h') .. ' --watch',

      -- Parameterized tests, disable discovery in neotest
      -- jest_test_discovery = true,

      -- Monorepos
      -- jestConfigFile = function(file)
      --   if string.find(file, "/packages/") then
      --     return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
      --   end
      --
      --   return vim.fn.getcwd() .. "/jest.config.ts"
      -- end,
      --
      -- Also, if your monorepo set up requires you to run a specific test file with cwd on the package directory (like when you have a lerna setup for example), you might also have to tweak things a bit:
      -- cwd = function(file)
      --   if string.find(file, "/packages/") then
      --     return string.match(file, "(.-/[^/]+/)src")
      --   end
      --   return vim.fn.getcwd()
      -- end
    },
  },
  {
    "nvim-neotest/neotest-vitest",
    optional = true,
    opts = {
      -- Filter directories when searching for test files. Useful in large projects (see Filter directories notes).
      -- filter_dir = function(name, rel_path, root) return name ~= "node_modules" end,

      -- Stricter file parsing to determine test files
      ---Custom criteria for a file path to determine if it is a vitest test file.
      ---@async
      ---@param file_path string Path of the potential vitest test file
      ---@return boolean
      -- is_test_file = function(file_path)
      --   -- Check if the project is "my-peculiar-project"
      --   if string.match(file_path, "my-peculiar-project") then
      --     -- Check if the file path includes something else
      --     if string.match(file_path, "/myapp/") then
      --       -- eg. only files in __tests__ are to be considered
      --       return string.match(file_path, "__tests__")
      --     end
      --   end
      --   return false
      -- end,
      --
      -- Filter directories
      ---Filter directories when searching for test files
      ---@async
      ---@param name string Name of directory
      ---@param rel_path string Path to directory, relative to root
      ---@param root string Root directory of project
      ---@return boolean
      -- filter_dir = function(name, rel_path, root)
      --   local full_path = root .. "/" .. rel_path
      --
      --   if root:match "projects/my-large-monorepo" then
      --     if full_path:match "^unit_tests" then
      --       return true
      --     else
      --       return false
      --     end
      --   else
      --     return name ~= "node_modules"
      --   end
      -- end,
      --
      --
      -- Watch mode mappings, opts = function(_, opts) -> opts.autocmds.neotest_vitest =...
      -- vim.api.nvim_set_keymap(
      --   "n",
      --   "<leader>twr",
      --   "<cmd>lua require('neotest').run.run({ vitestCommand = 'vitest --watch' })<cr>",
      --   { desc = "Run Watch" }
      -- ),
      --
      -- vim.api.nvim_set_keymap(
      --   "n",
      --   "<leader>twf",
      --   "<cmd>lua require('neotest').run.run({ vim.fn.expand('%'), vitestCommand = 'vitest --watch' })<cr>",
      --   { desc = "Run Watch File" }
      -- ),
    },
  },
  -- {
  --   "nvim-neotest/neotest",
  --   optional = true,
  --   dependencies = { "rcasia/neotest-bash", config = function() end },
  --   opts = function(_, opts)
  --     if not opts.adapters then opts.adapters = {} end
  --     table.insert(opts.adapters, require "neotest-bash"(require("astrocore").plugin_opts "neotest-bash"))
  --   end,
  -- },
}
