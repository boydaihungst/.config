-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing
---@type LazySpec
return {
  "AstroNvim/astrocore",
  version = false,
  branch = "v3",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        -- navigate buffer tabs with `H` and `L`
        L = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        H = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        -- toggle highlighting
        ["<Leader>h"] = {
          "<cmd>nohlsearch<CR>",
          desc = "No Highlight",
        },
        ["<Leader>q"] = { "<Cmd>confirm qall<CR>", desc = "Exit AstroNvim" },
        ["<Leader>Q"] = { "<Cmd>confirm q<CR>", desc = "Quit Window" },
        -- -- toggle quickfix
        -- ["<C-Q>"] = {
        --   function() require("qf").toggle_qf "q" end,
        --   desc = "Toggle Quickfix",
        -- },
        -- ["<Leader>xq"] = {
        --   function() require("qf").toggle_qf "q" end,
        --   desc = "Quickfix List",
        -- },
        -- -- toggle quicklist
        -- ["<Leader>xl"] = {
        --   function() require("qf").toggle_qf "l" end,
        --   desc = "Location List",
        -- },
      },
      v = {},
    },
    -- User comands
    commands = {},
    autocmds = {
      auto_quit = {},
      -- Overwrite default auto_quit: https://github.com/AstroNvim/AstroNvim/blob/2bb2fa9a01311ae7f9bfebf7b3ae996bcc4717be/lua/astronvim/plugins/_astrocore_autocmds.lua#L25
      -- auto_quit = {
      --   {
      --     event = "BufEnter",
      --     desc = "Quit AstroNvim if more than one window is open and only sidebar windows are list",
      --     callback = function()
      --       local wins = vim.api.nvim_tabpage_list_wins(0)
      --       local sidebar_fts = {
      --         aerial = true,
      --         ["neo-tree"] = true,
      --         undotree = true,
      --         dapui_scopes = true,
      --         dapui_breakpoints = true,
      --         dapui_stacks = true,
      --         dapui_watches = true,
      --         ["dap-repl"] = true,
      --         dapui_console = true,
      --         ["neotest-summary"] = true,
      --         ["neotest-output-panel"] = true,
      --         dbui = true,
      --         codecompanion = true,
      --         -- Still not work as expected
      --         OverseerList = true,
      --         ["comment-box"] = true,
      --         ["grug-far"] = true,
      --         ["qf"] = true,
      --       }
      --       for _, winid in ipairs(wins) do
      --         if vim.api.nvim_win_is_valid(winid) then
      --           local bufnr = vim.api.nvim_win_get_buf(winid)
      --           local filetype = vim.bo[bufnr].filetype
      --           local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
      --           -- If any visible windows are not sidebars, early return
      --           if not sidebar_fts[filetype] and buftype ~= "nofile" then
      --             return
      --             -- If the visible window is a sidebar
      --           else
      --             -- only count filetypes once, so remove a found sidebar from the detection
      --             sidebar_fts[filetype] = nil
      --           end
      --         end
      --       end
      --       if #vim.api.nvim_list_tabpages() > 1 then
      --         vim.cmd.tabclose()
      --       else
      --         vim.cmd.qall()
      --       end
      --     end,
      --   },
      -- },
      disable_diagnostic_environment = {
        {
          event = "BufReadPost",
          pattern = { ".env", ".env.*" },
          desc = "Disable diagnostic for environment files",
          -- group = "disable_diagnostic_environment",
          callback = function(args) vim.diagnostic.enable(false, { bufnr = args.buf }) end,
        },
      },
    },
    -- git_worktrees = {
    --   {
    --     toplevel = vim.env.HOME .. "/.config",
    --     gitdir = vim.env.HOME .. "/git/config",
    --   },
    -- },
    rooter = {
      -- list of detectors in order of prevalence, elements can be:
      --   "lsp" : lsp detection
      --   string[] : a list of directory patterns to look for
      --   fun(bufnr: integer): string|string[] : a function that takes a buffer number and outputs detected roots
      detector = {
        "lsp", -- highest priority is getting workspace from running language servers
        { ".git", "_darcs", ".hg", ".bzr", ".svn" }, -- next check for a version controlled parent directory
        { "lua", "MakeFile", "package.json", "lazy-lock.json", "yazi.toml", "hyprland.conf" }, -- lastly check for known project root files
      },
      ignore = {
        servers = { "taplo" }, -- list of language server names to ignore (Ex. { "efm" })
        dirs = { -- list of directory patterns (Ex. { "~/.cargo/*" })
          "*/.cargo/*",
          ".node_modules/*",
          ".cache/*",
          "dist/*",
          "/mnt/remote/*",
          "*.ass",
        },
      },
      autochdir = true,
    },
    -- https://github.com/folke/lazydev.nvim
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000, enabled = true }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = false, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = true, -- sets vim.opt.wrap
        mouse = "h",
        whichwrap = "lh",
        scrolloff = 10,
        shada = { "!", "'1000", "<1000", "s10", "h" },
      },
      o = {
        exrc = true,
        secure = true,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        mkdp_filetypes = { "markdown" },
        -- auto open preview in browser when enter md buf
        mkdp_auto_start = false,
        -- netrw_browsex_viewer = "xdg-open",
        matchup_surround_enabled = 1,
        cmdheight = 1,
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    filetypes = {
      pattern = {},
    },
  },
}
