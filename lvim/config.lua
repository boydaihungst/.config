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
vim.g.navic_silence        = true
----------------------------- Option
vim.opt["foldenable"]                            = true
vim.opt.foldlevelstart                           = 99
vim.opt["foldlevel"]                             = 99
vim.opt.foldcolumn                               = '1'
vim.opt.scrolloff                                = 8
vim.opt.wrap                                     = true
vim.opt.list                                     = false
vim.opt.termguicolors                            = true
vim.opt.sessionoptions                           = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
vim.opt.fillchars                                = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
------------------------------- Lvim -------------------------
lvim.log.level                                   = 'error'
lvim.format_on_save                              = false
lvim.builtin.terminal.active                     = true
lvim.builtin.dap.active                          = true
lvim.builtin.alpha.active                        = false
lvim.builtin.project.active                      = true
-- lvim.builtin.project.detection_methods           = { "lsp" }
lvim.builtin.project.exclude_dirs                = { "**/node_modules/*" }
lvim.builtin.breadcrumbs.active                  = true
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
        hi_parameter = "@text.underline",
        handler_opts = {
          border = "rounded",
        },
        max_width = 80,
        select_signature_key = "<C-Tab>"
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
          MatchParen = { fg = "NONE", bg = "#292C34" },
          NormalFloat = { fg = "#BCC4C9", bg = "#080A0E" },
          FloatBorder = { fg = "#BCC4C9", bg = "#080A0E" }
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
  { "mg979/vim-visual-multi", keys = "<C-n>" },
  { "p00f/nvim-ts-rainbow",   dependencies = { "nvim-treesitter" } },

  -- move motion
  {
    "phaazon/hop.nvim",
    event = "BufRead",
    config = function()
      require("hop").setup()
      vim.api.nvim_set_keymap("n", "f", ":HopChar2<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "F", ":HopWord<cr>", { silent = true })
    end,
  },
  {
    "andymass/vim-matchup",
    event = "BufRead",
    -- after = { "nvim-treesitter" },
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.loaded_matchit = 1
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_hi_surround_always = 1
      vim.g.matchup_surround_enabled = 1
    end,
  },
  { "chentoast/marks.nvim",
    event = "BufRead",
    config = function()
      require 'marks'.setup {
        builtin_marks = { ".", "<", ">", "^" },

      }
    end
  },
  {
    "roobert/search-replace.nvim",
    event = "BufRead",
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
    build = ":TSUpdateSync",
    -- after = "nvim-treesitter",
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
  { "folke/lsp-colors.nvim" },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    cmd = "MarkdownPreview",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      -- auto open preview in browser when enter md buf
      vim.g.mkdp_auto_start = false
    end,
  },
  -- { "tpope/vim-repeat" },
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
    "tpope/vim-abolish"
  },
  {
    "mxsdev/nvim-dap-vscode-js",
    keys = { '<leader>d' },
    config = function()
      require("user.dap").setup()
    end,
  },
  { "haydenmeade/neotest-jest",
    -- module = { "neotest" }
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "haydenmeade/neotest-jest",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    keys = { "<leader>t" },
    -- module = { "neotest" },
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
        pre_save_cmds = {
          "tabdo NvimTreeClose",
          function()
            local dapuiLoaded, dapui = pcall(require, "dapui")
            local neotestLoaded, neotest = pcall(require, "neotest")
            local terminalLoaded, terms = pcall(require, "toggleterm.terminal")
            local bufferDelete = require('bufdelete')

            if dapui and dapuiLoaded then
              dapui.close()
            end
            if neotest and neotestLoaded then
              neotest.summary.close()
              neotest.output_panel.close()
            end
            if terms and terminalLoaded then
              local terminals = terms.get_all()
              for _, term in pairs(terminals) do
                term:close()
                if vim.api.nvim_buf_is_loaded(term.bufnr) then
                  vim.api.nvim_buf_delete(term.bufnr, { force = true })
                end
              end
            end
            local buffer_filter = function(buf)
              if vim.api.nvim_buf_is_valid(buf) and not vim.api.nvim_buf_get_option(buf, 'buflisted')
              then
                return true
              end
              return false
            end

            local unlistedBuffers = vim.tbl_filter(buffer_filter, vim.api.nvim_list_bufs())
            for _, buf in pairs(unlistedBuffers) do
              bufferDelete.bufwipeout(buf, true)
            end
          end,
        },
      })
    end,
  },
  {
    "rmagatti/session-lens",
    dependencies = { "rmagatti/auto-session", "nvim-telescope/telescope.nvim" },
    cmd = { "SearchSession" },
    config = function()
      require("session-lens").setup({
        prompt_title = "Restore Session",
      })
      require("telescope").load_extension("session-lens")
    end,
  },
  {
    "danymat/neogen",
    event = { "BufRead" },
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
    event = { "BufRead" },
    -- wants = { "promise-async" },
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      local _, ufo = pcall(require, 'ufo');
      ufo.setup {
        provider_selector = function()
          return { 'treesitter', 'indent' }
        end
      }
      vim.keymap.set("n", "zR", ufo.openAllFolds)
      vim.keymap.set("n", "zM", ufo.closeAllFolds)
    end,
  },
  {
    "nvim-treesitter/playground",
    cmd = { "TSPlaygroundToggle" }
  },
  {
    "nvim-telescope/telescope-symbols.nvim",
    cmd = { "Telescope symbols" }
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    -- after = "nvim-treesitter",
    event = { "BufRead" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require 'nvim-treesitter.configs'.setup {
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["am"] = { query = "@function.outer", desc = "Function region" },
              ["im"] = { query = "@function.inner", desc = "Function region" },
              ["ac"] = { query = "@class.outer", desc = "Class region" },
              ["ic"] = { query = "@class.inner", desc = "Class region" },
            },
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
              ["]]"] = { query = { "@function.inner", "@function.outer", "@class.inner", "@class.outer" }, desc = "Next function or class" },
            },
            goto_previous = {
              ["[["] = { query = { "@function.inner", "@function.outer", "@class.inner", "@class.outer" }, desc = "Previous function or class" },
            }
          },
        },
      }
      local loadedTextObjectPlugin, ts_repeat_move = pcall(require, "nvim-treesitter.textobjects.repeatable_move")
      if loadedTextObjectPlugin then
        -- Repeat movement with ; and ,
        -- ensure ; goes forward and , goes backward regardless of the last direction
        vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
        vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

        -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
        vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
        vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
        vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
        vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
      end
    end
  }
}
