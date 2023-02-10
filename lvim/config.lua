require("user.null-ls")
require("user.keybind")
require("user.plugins.cmp")
require("user.plugins.treesitter")
require("user.plugins.lualine")
require("user.plugins.bufferline")
require("user.plugins.ufo")
require("user.plugins.lspconfig")
require("user.plugins.nvimtree")
require("user.plugins.which-key")
---------------------------- Global ---------------------------
vim.g.netrw_browsex_viewer = "xdg-open"
vim.g.catppuccin_flavour   = "mocha"
----------------------------- Option
vim.opt["foldenable"]      = true
vim.opt.foldlevelstart     = 99
vim.opt["foldlevel"]       = 99
vim.opt.foldcolumn         = '1'
vim.opt.scrolloff          = 8
vim.opt.wrap               = true
vim.opt.list               = true
vim.opt.termguicolors      = true
vim.opt.sessionoptions     = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
vim.opt.fillchars          = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

------------------------------- Lvim -------------------------
lvim.format_on_save                              = false
lvim.builtin.terminal.active                     = true
lvim.builtin.dap.active                          = true
lvim.builtin.alpha.active                        = true
lvim.builtin.project.active                      = true
lvim.builtin.breadcrumbs.active                  = false
lvim.builtin.alpha.mode                          = "dashboard"
lvim.builtin.terminal.shell                      = "fish"
lvim.builtin.terminal.auto_scroll                = false
lvim.builtin.autopairs.enable_check_bracket_line = true
------------------------------- Autocmd --------------------------
vim.cmd([[
  autocmd FileType help wincmd L
  augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
  augroup END
]])
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help" },
  command = "wincmd L",
})
------------------------------- Plugins ---------------------------
lvim.plugins = {
  {
    "ray-x/lsp_signature.nvim",
    config = function()
      require('lsp_signature').setup({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        hint_prefix = " ",
        -- floating_window = false,
        hint_enable = false,
        hi_parameter = "LspSignatureActiveParameter",
        handler_opts = {
          border = "rounded",
        },
        max_width = 80,
        select_signature_key = "<C-tab>"
      })

    end
  },
  -- theme
  { 'navarasu/onedark.nvim',
    config = function()
      require('onedark').setup({
        style = 'darker',
        -- transparent = true,
        colors = {
          black = "#0e1013",
          bg0 = "#080A0E",
          bg_d = "#080A0E",
          bg_blue = "#61afef",
          bg_yellow = "#e8c88c",
          fg = "#BCC4C9",
          purple = "#bf68d9",
          green = "#8ebd6b",
          orange = "#cc9057",
          blue = "#4fa6ed",
          yellow = "#e2b86b",
          cyan = "#48b0bd",
          red = "#e55561",
          grey = "#535965",
          light_grey = "#7a818e",
          dark_cyan = "#266269",
          dark_red = "#8b3434",
          dark_yellow = "#835d1a",
          dark_purple = "#7e3992",
          diff_add = "#272e23",
          diff_delete = "#2d2223",
          diff_change = "#172a3a",
          diff_text = "#274964",
        },
        highlights = {
          SignColumn = { fg = "#BCC4C9", bg = "#080A0E" },
          Normal = { fg = "#BCC4C9", bg = "#080A0E" },
          Terminal = { fg = "#BCC4C9", bg = "#080A0E" },
          EndOfBuffer = { fg = "#BCC4C9", bg = "#080A0E" },
          FoldColumn = { fg = "#BCC4C9", bg = "#080A0E" },
          Folded = { fg = "#BCC4C9", bg = "#282c34" },
          MatchParen = { fg = "NONE", bg = "#292C34" }
        }
      })

      vim.cmd([[colorscheme onedark]])
      lvim.colorscheme = "onedark"
    end
  },
  -- background color for RGB hex codes
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ "*" }, {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
      })
    end,
  },
  -- multiple cursors position
  { "mg979/vim-visual-multi" },
  { "p00f/nvim-ts-rainbow", event = "BufRead", requires = { "nvim-treesitter" } },

  -- move motion
  {
    "phaazon/hop.nvim",
    event = "BufRead",
    setup = function()
      vim.api.nvim_set_keymap("n", "f", ":HopChar2<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "F", ":HopWord<cr>", { silent = true })
    end,
    config = function()
      require("hop").setup()
    end,
  },
  {
    "andymass/vim-matchup",
    event = "VimEnter",
    after = { "nvim-treesitter" },
    setup = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.loaded_matchit = 1
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_hi_surround_always = 1
      vim.g.matchup_surround_enabled = 1
    end,
  },
  { "chentoast/marks.nvim",
    config = function()
      require 'marks'.setup {
        builtin_marks = { ".", "<", ">", "^" },

      }
    end
  },
  {
    "roobert/search-replace.nvim",
    config = function()
      require("search-replace").setup({
        -- optionally override defaults
        default_replace_single_buffer_options = "gcI",
        default_replace_multi_buffer_options = "egcI",
      })
    end,
  },
  -- jump to lines
  {
    "nacro90/numb.nvim",
    event = "BufRead",
    config = function()
      require("numb").setup({
        show_numbers = true, -- Enable 'number' for the window while peeking
        show_cursorline = true, -- Enable 'cursorline' for the window while peeking
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  -- Show current focused function at top
  {
    "romgrk/nvim-treesitter-context",
    run = ":TSUpdateSync",
    after = "nvim-treesitter",
    config = function()
      require("treesitter-context").setup({
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        throttle = true, -- Throttles plugin updates (may improve performance)
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          default = {
            "class",
            "function",
            "method",
            "for",
            "while",
            "if",
            "switch",
            "case",
            "else",
          },
        },
      })
    end,
  },
  -- support missing lsp colorscheme supports
  { "folke/lsp-colors.nvim", event = "BufRead" },
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
    cmd = "MarkdownPreview",
    setup = function()
      vim.g.mkdp_filetypes = { "markdown" }
      -- auto open preview in browser when enter md buf
      vim.g.mkdp_auto_start = false
    end,
  },
  { "tpope/vim-repeat" },
  {
    "ethanholz/nvim-lastplace",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help", "terminal" },
        lastplace_ignore_filetype = {
          "gitcommit",
          "gitrebase",
          "svn",
          "hgcommit",
          "NvimTree",
          "spectre_panel",
          "ctrlsf",
        },
        lastplace_open_folds = false,
      })
    end,
  },
  { "tpope/vim-surround" },
  { "famiu/bufdelete.nvim" },
  {
    "tpope/vim-abolish",
  },
  {
    "mxsdev/nvim-dap-vscode-js",
    config = function()
      require("user.dap").setup()
    end,
  },
  {
    "nvim-neotest/neotest",
    requires = {
      "haydenmeade/neotest-jest",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest")({
            -- jestCommand = "yarn test --",
            -- jestConfigFile = "jest.config.js",
            -- env = { CI = true },
            -- cwd = function(_)
            --   return vim.fn.getcwd()
            -- end,
          }),
        },
      })
    end,
  },
  {
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup({
        log_level = "error",
        auto_save_enabled = true,
        auto_restore_enabled = true,
        auto_session_enable_last_session = true,
        auto_session_allowed_dirs = { "~/git/*" },
        post_save_cmds = {
          "tabdo NvimTreeClose",
          function()
            local _, dapui = pcall(require, "dapui")
            local _, neotest = pcall(require, "neotest")
            local _, terms = pcall(require, "toggleterm.terminal")
            if dapui then
              dapui.close()
            end
            if neotest then
              neotest.summary.close()
              neotest.output_panel.close()
            end
            if terms then
              local terminals = terms.get_all()
              for _, term in pairs(terminals) do
                term:close()
                term:send('exit')
                if vim.api.nvim_buf_is_loaded(term.bufnr) then
                  vim.api.nvim_buf_delete(term.bufnr, { force = true })
                end
              end
            end
          end,
        },
      })
    end,
  },
  {
    "rmagatti/session-lens",
    requires = { "rmagatti/auto-session", "nvim-telescope/telescope.nvim" },
    config = function()
      require("session-lens").setup({
        prompt_title = "Restore Session",
      })
      require("telescope").load_extension("session-lens")
    end,
  },
  {
    "danymat/neogen",
    config = function()
      require('neogen').setup {
        snippet_engine = "luasnip",
        enable_placeholders = false,
        languages = {
          lua = {
            template = {
              annotation_convention = "ldoc",
            }
          },
          typescriptreact = {
            template = {
              annotation_convention = "tsdoc",
            }
          },
          typescript = {
            template = {
              annotation_convention = "tsdoc",
            }
          },
        }
      }
    end
  },
  {
    "kevinhwang91/nvim-ufo",
    -- opt = true,
    -- event = { "BufReadPre" },
    wants = { "promise-async" },
    requires = { "kevinhwang91/promise-async" },
    config = function()
      require("ufo").setup {
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end
      }
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
    end,
  },
  {
    "nvim-treesitter/playground",
  },
  {
    "nvim-telescope/telescope-symbols.nvim"
  },

}
