-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      openhelpinvertical = {
        {
          event = "FileType",
          pattern = "help",
          desc = "",
          group = "openhelpinvertical",
          callback = function() vim.api.nvim_command "wincmd L" end,
        },
      },
      disable_diagnostic_environment = {
        {
          event = "BufEnter",
          pattern = ".env*",
          desc = "",
          group = "disable_diagnostic_environment",
          callback = function(args) vim.diagnostic.disable(args.buf) end,
        },
      },
      filetypedetect = {
        {
          event = { "BufRead", "BufNewFile" },
          pattern = "*/sway/config.d/*",
          group = "filetypedetect",
          callback = function() vim.api.nvim_command "set filetype=swayconfig" end,
        },
        {
          event = { "BufRead", "BufNewFile" },
          pattern = "*/waybar/config",
          group = "filetypedetect",
          callback = function() vim.api.nvim_command "set filetype=json" end,
        },
      },
    },
    rooter = {
      ignore = {
        dirs = {
          "*/.cargo/*",
          ".node_modules/*",
          ".cache/*",
          "dist/*",
        },
      },
      autochdir = true,
    },
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 2000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
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
        cmdheight = 1,
        whichwrap = "lh",
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        mkdp_filetypes = { "markdown" },
        -- auto open preview in browser when enter md buf
        mkdp_auto_start = false,
        netrw_browsex_viewer = "xdg-open",
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    filetypes = {
      pattern = {
        -- ["%.env%.[%w_.-]+"] = "dotenv",
      },
    },
  },
}
