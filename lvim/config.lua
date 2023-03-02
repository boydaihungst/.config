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
vim.g.netrw_browsex_viewer                       = "xdg-open"
vim.g.navic_silence                              = true
vim.env.LVIM_DEV_MODE                            = false
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
lvim.builtin.alpha.active                        = true
lvim.builtin.project.active                      = true
-- lvim.builtin.project.detection_methods           = { "lsp" }
lvim.builtin.project.exclude_dirs                = { "**/node_modules/*" }
lvim.builtin.breadcrumbs.active                  = false
lvim.builtin.alpha.mode                          = "dashboard"
lvim.builtin.terminal.shell                      = "fish"
lvim.builtin.terminal.auto_scroll                = false
lvim.builtin.autopairs.enable_check_bracket_line = true
lvim.builtin.autopairs.ts_config                 = {
  lua = { "string", "source" },
  javascript = { "string", "template_string" },
  java = false,
  typescript = { "string", "template_string" },
}

------------------------------- Autocmd --------------------------
vim.cmd([[
  autocmd FileType help wincmd L
  augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
  augroup END
  autocmd VimLeavePre * SaveSession
]])
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help" },
  command = "wincmd L",
})

lvim.colorscheme = "onedark"

------------------------------- Plugins ---------------------------
lvim.plugins = {
  {
    "ray-x/lsp_signature.nvim",
    lazy = true,
    event = "BufEnter",
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
    lazy = not vim.startswith(lvim.colorscheme, "onedark"),
    priority = 1000,
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
          MatchParen = { fg = "NONE", bg = "#282c34" },
          NormalFloat = { fg = "#BCC4C9", bg = "#080A0E" },
          FloatBorder = { fg = "#BCC4C9", bg = "#080A0E" }
        }
      })
      vim.cmd([[colorscheme onedark]])
    end
  },
  {
    "glepnir/lspsaga.nvim",
    cmd = { "Lspsaga" },
    lazy = true,
    config = function()
      require("lspsaga").setup({
        preview = {
          lines_above = 0,
          lines_below = 10,
        },
        scroll_preview = {
          scroll_down = "<C-j>",
          scroll_up = "<C-k>",
        },
        request_timeout = 2000,
        finder = {
          --percentage
          max_height = 0.5,
          keys = {
            jump_to = 'p',
            edit = { 'o', '<CR>' },
            vsplit = 's',
            split = 'i',
            tabe = '',
            tabnew = '',
            quit = { 'q', '<ESC>' },
            close_in_preview = '<ESC>'
          },
        },
        definition = {
          edit = "<C-c>o",
          vsplit = "<C-c>v",
          split = "<C-c>i",
          tabe = "<C-c>t",
          quit = 'q',
        },
        code_action = {
          num_shortcut = true,
          show_server_name = true,
          extend_gitsigns = true,
          keys = {
            -- string | table type
            quit = { 'q', '<ESC>' },
            exec = "<CR>",
          },
        },
        lightbulb = {
          enable = true,
          enable_in_insert = true,
          sign = true,
          sign_priority = 40,
          virtual_text = false,
        },
        diagnostic = {
          on_insert = false,
          on_insert_follow = false,
          insert_winblend = 0,
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,
          --1 is max
          max_width = 0.7,
          custom_fix = nil,
          custom_msg = nil,
          text_hl_follow = false,
          border_follow = false,
          keys = {
            exec_action = "o",
            quit = "q",
            go_action = "g"
          },
        },
        rename = {
          quit = "<ESC>",
          exec = "<CR>",
          mark = "x",
          confirm = "<CR>",
          in_select = false,
        },
        outline = {
          win_position = "right",
          win_with = "",
          win_width = 30,
          show_detail = true,
          auto_preview = true,
          auto_refresh = true,
          auto_close = true,
          custom_sort = nil,
          keys = {
            jump = "l",
            expand_collapse = "h",
            quit = "q",
          },
        },
        symbol_in_winbar = {
          enable = true,
          separator = "  ",
          ignore_patterns = {},
          hide_keyword = true,
          show_file = true,
          folder_level = 2,
          respect_root = false,
          color_mode = false,
        },
        beacon = {
          enable = true,
          frequency = 7,
        },
        ui = {
          -- This option only works in Neovim 0.9
          title = true,
          -- Border type can be single, double, rounded, solid, shadow.
          border = "rounded",
          winblend = 0,
          expand = "",
          collapse = "",
          code_action = "💡",
          incoming = " ",
          outgoing = " ",
          hover = ' ',
          kind = {},
        },
      })
    end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      --Please make sure you install markdown and markdown_inline parser
      { "nvim-treesitter/nvim-treesitter" },

    }
  },
  -- background color for RGB hex codes
  {
    "norcalli/nvim-colorizer.lua",
    lazy = true,
    event = "VimEnter",
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
  { "mg979/vim-visual-multi", event = "BufEnter" },
  { "p00f/nvim-ts-rainbow",   event = "BufEnter", dependencies = { "nvim-treesitter" } },
  {
    "phaazon/hop.nvim",
    -- event = "BufRead",
    cmd = { "HopChar2", "HopWord" },
    config = function()
      require("hop").setup()
    end,
  },
  {
    "andymass/vim-matchup",
    event = "BufEnter",
    after = { "nvim-treesitter" },
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.loaded_matchit = 1
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_hi_surround_always = 1
      vim.g.matchup_surround_enabled = 1
    end,
  },
  { "chentoast/marks.nvim",
    event = "BufEnter",
    config = function()
      require 'marks'.setup {
        builtin_marks = { ".", "<", ">", "^" },

      }
    end
  },
  {
    "roobert/search-replace.nvim",
    event = "BufEnter",
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
    event = "BufEnter",
    config = function()
      require("numb").setup({
        show_numbers = true, -- Enable 'number' for the window while peeking
        show_cursorline = true, -- Enable 'cursorline' for the window while peeking
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  -- Show current focused function at top
  {
    "romgrk/nvim-treesitter-context",
    build = ":TSUpdateSync",
    event = "BufEnter",
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
  {
    "ethanholz/nvim-lastplace",
    event = "BufEnter",
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
  { "tpope/vim-surround", event = "BufEnter",
  },
  { "famiu/bufdelete.nvim", lazy = true, cmd = { "BDeletePre", "BDeletePost", } },
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
  {
    "nvim-neotest/neotest",
    dependencies = {
      "haydenmeade/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    keys = { "<leader>t" },
    config = function()
      require("neotest").setup({
        summary = {
          mappings = {
            attach = "a",
            clear_marked = "M",
            clear_target = "T",
            debug = "d",
            debug_marked = "D",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "l",
            mark = "m",
            next_failed = "]]",
            output = "o",
            prev_failed = "[[",
            run = "r",
            run_marked = "R",
            short = "O",
            stop = "u",
            target = "t"
          }
        },
        adapters = {
          require('neotest-vitest'),
          -- require("neotest-jest")({
          --   -- jestCommand = "yarn test --",
          --   jestConfigFile = "jest.config.js",
          --   env = { CI = true },
          --   cwd = function(_)
          --     return vim.fn.getcwd()
          --   end,

          -- }),
        },
      })
    end,
  },
  {
    "rmagatti/auto-session",
    commit = "c8b2f4048f846387361bd04cc185bf1aa7d2e3d1",
    lazy = false,
    config = function()
      require("auto-session").setup({
        log_level = "info",
        auto_session_enabled = true,
        auto_session_create_enabled = true,
        auto_save_enabled = true,
        auto_restore_enabled = true,
        auto_session_enable_last_session = true,
        -- auto_session_allowed_dirs = { "~/git/*" },
        -- cwd_change_handling = {
        --   restore_upcoming_session = false,
        -- },
        pre_save_cmds = {
          function()
            local nvimtreeLoaded, nvimtreeView = pcall(require, "nvim-tree.view")
            local dapuiLoaded, dapui = pcall(require, "dapui")
            local neotestLoaded, neotest = pcall(require, "neotest")
            local terminalLoaded, terms = pcall(require, "toggleterm.terminal")
            local bufferDeleteLoaded, bufferDelete = pcall(require, 'bufdelete')
            local lspSagaOutlineLoaded, lspSagaOutline = pcall(require, "lspsaga.outline")
            if lspSagaOutlineLoaded and lspSagaOutline and lspSagaOutline.winid and vim.api.nvim_win_is_valid(lspSagaOutline.winid) then
              vim.cmd([[
                Lspsaga outline
              ]])
            end
            if dapui and dapuiLoaded then
              dapui.close()
            end
            if nvimtreeLoaded and nvimtreeView then
              vim.cmd([[
                NvimTreeClose
              ]])
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
            -- close unlisted buffers
            local unlistedBuffers = vim.tbl_filter(buffer_filter, vim.api.nvim_list_bufs())
            for _, buf in pairs(unlistedBuffers) do
              if bufferDeleteLoaded then
                bufferDelete.bufwipeout(buf, true)
              end
            end
            -- close floating windows
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local config = vim.api.nvim_win_get_config(win)
              if config.relative ~= '' then
                vim.api.nvim_win_close(win, false)
              end
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
    keys = {
      { "gb", nil, 'n' },
      { "gb", nil, 'v' },
      { "gb", nil, 'x' },
    },
    cmd = { "Neogen", "Neogen func", "Neogen class", "Neogen type" },
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
    event = "BufEnter",
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
    enabled = lvim.builtin.telescope.active
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    -- after = "nvim-treesitter",
    event = "BufEnter",
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
