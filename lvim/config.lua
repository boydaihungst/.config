require("user.plugins.bigfile")
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
require("user.plugins.illuminate")
require("user.plugins.telescope")
---------------------------- Global ---------------------------
vim.g.netrw_browsex_viewer        = "xdg-open"
vim.g.navic_silence               = true
----------------------------- Option
vim.opt.mouse                     = "h"
vim.opt["foldenable"]             = true
vim.opt.foldlevelstart            = 99
vim.opt["foldlevel"]              = 99
vim.opt.foldcolumn                = '1'
vim.opt.scrolloff                 = 8
vim.opt.wrap                      = true
vim.opt.list                      = false
vim.opt.termguicolors             = true
vim.opt.sessionoptions            = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.fillchars                 = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
------------------------------- Lvim -------------------------

lvim.log.level                    = 'error'
lvim.format_on_save               = false
lvim.builtin.terminal.active      = true
lvim.builtin.dap.active           = true
lvim.builtin.alpha.active         = false
lvim.builtin.project.active       = false
-- lvim.builtin.project.detection_methods           = { "lsp" }
lvim.builtin.project.exclude_dirs = { "**/node_modules/*" }
lvim.builtin.breadcrumbs.active   = true
lvim.builtin.alpha.mode           = "dashboard"
lvim.builtin.terminal.shell       = "fish"
lvim.builtin.terminal.auto_scroll = false
lvim.builtin.indentlines.active   = true
-- lvim.builtin.autopairs.enable_check_bracket_line = true
lvim.builtin.autopairs.ts_config  = {
  lua = { "string", "source" },
  javascript = { "string", "template_string" },
  java = false,
  typescript = { "string", "template_string" },
  vue = { "string", "template_string" },
}

------------------------------- Autocmd --------------------------
vim.cmd([[
  autocmd FileType help wincmd L
  augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
  augroup END
  autocmd VimLeavePre * lua require('session_manager').autosave_session()
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
    event = { "VeryLazy" },
    config = function()
      lvim.lsp.on_attach_callback = function(_, bufnr)
        require "lsp_signature".on_attach({
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
        }, bufnr)
      end
    end
  },
  -- theme
  {
    'navarasu/onedark.nvim',
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
          MatchParen = { fg = "NONE", bg = "NONE", fmt = "underline" },
          NormalFloat = { fg = "#BCC4C9", bg = "#080A0E" },
          FloatBorder = { fg = "#BCC4C9", bg = "#080A0E" },
          NvimSurroundHighlight = { fg = "#080A0E", bg = "#8ebd6b" },
          TelescopeMatching = { fg = "#8ebd6b", bg="NONE", fmt = "bold" },
          TelescopeSelectionCaret = { fg = "#BCC4C9", bg="NONE" },
          TelescopeMultiSelection = { fg = "#BCC4C9", bg="NONE" },
        }
      })
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function()
          local links = {
            ['@lsp.type.namespace'] = '@namespace',
            ['@lsp.type.type'] = '@type',
            ['@lsp.type.class'] = '@type',
            ['@lsp.type.enum'] = '@type',
            ['@lsp.type.interface'] = '@type',
            ['@lsp.type.struct'] = '@structure',
            ['@lsp.type.parameter'] = '@parameter',
            ['@lsp.type.variable'] = '@variable',
            ['@lsp.type.property'] = '@property',
            ['@lsp.type.enumMember'] = '@constant',
            ['@lsp.type.function'] = '@function',
            ['@lsp.type.method'] = '@method',
            ['@lsp.type.macro'] = '@macro',
            ['@lsp.type.decorator'] = '@function',
          }
          for newgroup, oldgroup in pairs(links) do
            vim.api.nvim_set_hl(0, newgroup, { link = oldgroup, default = true })
          end
        end
      })
      vim.cmd([[colorscheme onedark]])
    end
  },
  {
    "glepnir/lspsaga.nvim",
    -- event = { "LspAttach" },
    cmd = { "Lspsaga" },
    lazy = true,
    config = function()
      require("lspsaga").setup({
        preview = {
          lines_above = 10,
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
            quit = "q",
          },
        },
        symbol_in_winbar = {
          enable = true,
          separator = "  ",
          -- ignore_patterns = {},
          hide_keyword = true,
          show_file = true,
          folder_level = 1,
          respect_root = true,
          color_mode = true,
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
          -- kind = {},
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
    "NvChad/nvim-colorizer.lua",
    lazy = true,
    event = "VimEnter",
    config = function()
      require("colorizer").setup {
        filetypes = { "*" },
        user_default_options = {
          RGB = true,      -- #RGB hex codes
          RRGGBB = true,   -- #RRGGBB hex codes
          RRGGBBAA = true, -- #RRGGBBAA hex codes
          rgb_fn = true,   -- CSS rgb() and rgba() functions
          hsl_fn = true,   -- CSS hsl() and hsla() functions
          css = true,      -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = true,   -- Enable all CSS *functions*: rgb_fn, hsl_fn
        }

      }
    end,
  },
  -- multiple cursors position
  { "mg979/vim-visual-multi", event = "BufEnter" },
  {
    "lincheney/nvim-ts-rainbow",
    event = "BufEnter",
    -- lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter", "xiaoxin-sky/tree-sitter-vue" },
  },
  {
    "phaazon/hop.nvim",
    config = function()
      local hop = require('hop')
      hop.setup()
    end,
  },
  {
    "chentoast/marks.nvim",
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
        show_numbers = true,    -- Enable 'number' for the window while peeking
        show_cursorline = true, -- Enable 'cursorline' for the window while peeking
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "BufEnter",
  },
  -- Show current focused function at top

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
        lastplace_ignore_buftype = { "quickfix", "nofile", "terminal" },
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
  {
    "kylechui/nvim-surround",
    event = "BufEnter",
    config = function()
      require("nvim-surround").setup()
    end
  },
  { "famiu/bufdelete.nvim",   lazy = false,      cmd = { "BDeletePre", "BDeletePost", } },
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
    "Shatur/neovim-session-manager",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    config = function()
      local Path = require('plenary.path')
      local session_config = require('session_manager.config')
      local session_manager = require('session_manager');
      session_manager.setup({
        sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
        autoload_mode = session_config.AutoloadMode.LastSession,     -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
        autosave_last_session = true,                                -- Automatically save last session on exit and on session switch.
        autosave_ignore_not_normal = false,                          -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
        autosave_ignore_dirs = {},                                   -- A list of directories where the session will not be autosaved.
        autosave_ignore_filetypes = {                                -- All buffers of these file types will be closed before the session is saved.
          'gitcommit',
          'gitrebase',
        },
        autosave_ignore_buftypes = {},                                             -- All buffers of these bufer types will be closed before the session is saved.
        autosave_only_in_session = false,                                          -- Always autosaves session. If true, only autosaves after a session is active.
        max_path_length = 80,                                                      -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
      })
      local config_group = vim.api.nvim_create_augroup('SessionManagerCustom', {}) -- A global group for all your config autocommands

      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = "SessionSavePre",
        group = config_group,
        callback = function()
          local nvimtreeLoaded, nvimtreeView = pcall(require, "nvim-tree.view")
          local dapuiLoaded, dapui = pcall(require, "dapui")
          local neotestLoaded, neotest = pcall(require, "neotest")
          local terminalLoaded, terms = pcall(require, "toggleterm.terminal")
          local bufferDeleteLoaded, bufferDelete = pcall(require, 'bufdelete')
          local lspSagaOutlineLoaded, lspSagaOutline = pcall(require, "lspsaga.outline")

          -- close lsp saga outline
          if lspSagaOutlineLoaded and lspSagaOutline and lspSagaOutline.winid and vim.api.nvim_win_is_valid(lspSagaOutline.winid) then
            vim.cmd([[
                Lspsaga outline
              ]])
          end
          -- close dap UI
          if dapui and dapuiLoaded then
            dapui.close()
          end
          -- close nvim tree
          if nvimtreeLoaded and nvimtreeView then
            vim.cmd([[
                NvimTreeClose
              ]])
          end
          -- close neo test UI
          if neotest and neotestLoaded then
            neotest.summary.close()
            neotest.output_panel.close()
          end
          -- close terminal
          if terms and terminalLoaded then
            local terminals = terms.get_all()
            for _, term in pairs(terminals) do
              term:close()
              if vim.api.nvim_buf_is_loaded(term.bufnr) then
                vim.api.nvim_buf_delete(term.bufnr, { force = true })
              end
            end
          end
          -- close unlisted buffers
          local buffer_filter = function(buf)
            if vim.api.nvim_buf_is_valid(buf) and not vim.api.nvim_buf_get_option(buf, 'buflisted')
            then
              return true
            end
            return false
          end
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
      })
    end
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
        -- provider_selector = function()
        --   return { 'treesitter', 'indent' }
        -- end
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
              ["am"] = { query = "@function.outer", desc = "function outer region" },
              ["im"] = { query = "@function.inner", desc = "function inner region" },
              ["ac"] = { query = "@class.outer", desc = "Class outer region" },
              ["ic"] = { query = "@class.inner", desc = "class inner region" },
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
              ["]]"] = { query = { "@function.inner", "@function.outer", "@class.inner", "@class.outer" }, desc =
              "Next function or class" },
            },
            goto_previous = {
              ["[["] = { query = { "@function.inner", "@function.outer", "@class.inner", "@class.outer" }, desc =
              "Previous function or class" },
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
  },
  {
    "hrsh7th/cmp-emoji",
    lazy = true,
    event = { "InsertEnter" }
  },
  {
    "petertriho/cmp-git",
    lazy = true,
    event = { "InsertEnter" }
  },
  {
    "FelipeLema/cmp-async-path"
  },
  {
    "David-Kunz/cmp-npm",
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = "json",
    config = function()
      require('cmp-npm').setup({})
    end
  },
  {
    'kevinhwang91/nvim-hlslens',
    lazy = true,
    event = "BufEnter",
    config = function()
      require('hlslens').setup()

      local kopts = { noremap = true, silent = true }

      vim.api.nvim_set_keymap('n', 'n',
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts)
      vim.api.nvim_set_keymap('n', 'N',
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts)
      vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

      -- vim.api.nvim_set_keymap('n', '<Leader>l', '<Cmd>noh<CR>', kopts)
    end
  },
  {
    "winston0410/range-highlight.nvim",
    dependencies = { "winston0410/cmd-parser.nvim" },
    config = function()
      require 'range-highlight'.setup {}
    end
  },
  {
    "yorickpeterse/nvim-pqf",
    lazy = true,
    event = { "BufEnter" },
    config = function()
      require('pqf').setup({
        signs = {
          error = lvim.icons.diagnostics.Error,
          warning = lvim.icons.diagnostics.Warning,
          info = lvim.icons.diagnostics.Information,
          hint = lvim.icons.diagnostics.Hint
        },
        max_filename_length = 30,
      })
    end
  }
}
