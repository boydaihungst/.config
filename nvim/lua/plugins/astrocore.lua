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
      },
      v = {},
    },
    -- User comands
    commands = {},
    autocmds = {
      auto_quit = {},
      disable_diagnostic_environment = {
        {
          event = "BufReadPost",
          pattern = { ".env", ".env.*" },
          desc = "Disable diagnostic for environment files",
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
      virtual_text = false,
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
        -- Fix for noice.nvim
        cmdheight = 1,
      },
      o = {
        exrc = true,
        secure = true,
        clipboard = "unnamed,unnamedplus",
        -- winborder = "rounded",
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- netrw_browsex_viewer = "xdg-open",
        health = { style = "float" },
        clipboard = os.getenv "SSH_TTY" and "osc52",
      },
    },
    filetypes = {

      -- see `:h vim.filetype.add` for usage
      extension = {
        -- foo = "fooscript",
      },
      filename = {
        -- [".foorc"] = "fooscript",
      },
      pattern = {
        -- [".*/etc/foo/.*"] = "fooscript",
      },
    },
  },
}
