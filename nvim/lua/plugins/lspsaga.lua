---@type LazySpec
return {
  -- "glepnir/lspsaga.nvim",
  "leeguooooo/lspsaga.nvim",
  branch = "fix-client-method-deprecations",
  event = "LspAttach",
  cmd = "Lspsaga",
  enabled = true,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    {
      "AstroNvim/astrolsp",
      opts = function(_, opts)
        -- disabl default mapping
        if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
        local maps = opts.mappings
        -- maps.n["<Leader>lA"] = nil
        -- maps.n["<Leader>lG"] = nil
        -- disable default aerial symbols document
        -- maps.n["<Leader>lS"] = nil

        maps.n["]d"] = { "<Cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next diagnostic" }
        maps.n["[d"] = { "<Cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Previous diagnostic" }
        -- hover
        -- maps.n["K"] = { "<Cmd>Lspsaga hover_doc<CR>", desc = "Hover symbol details", cond = "textDocument/hover" }

        -- call hierarchy
        maps.n["<Leader>lc"] =
          { "<Cmd>Lspsaga incoming_calls<CR>", desc = "Incoming calls", cond = "callHierarchy/incomingCalls" }
        maps.n["<Leader>lC"] =
          { "<Cmd>Lspsaga outgoing_calls<CR>", desc = "Outgoing calls", cond = "callHierarchy/outgoingCalls" }

        -- code action
        -- NOTE: Bug use aznhe21/actions-preview.nvim instead
        -- maps.n["<Leader>la"] =
        --   { "<Cmd>Lspsaga code_action<CR>", desc = "Code action", cond = "textDocument/codeAction" }
        -- maps.x["<Leader>la"] =
        --   { ":<C-U>Lspsaga code_action<CR>", desc = "Code action", cond = "textDocument/codeAction" }

        -- diagnostic
        maps.n["<Leader>ld"] =
          { "<Cmd>Lspsaga show_line_diagnostics ++unfocus<CR>", desc = "Diagnostics in line", cond = "" }

        -- definition
        -- maps.n["<Leader>lp"] =
        --   { "<Cmd>Lspsaga peek_definition<CR>", desc = "Peek definition", cond = "textDocument/definition" }
        maps.n["gd"] =
          { "<Cmd>Lspsaga peek_definition<CR>", desc = "Peek definition", cond = "textDocument/definition" }
        maps.n["gy"] = {
          "<Cmd>Lspsaga peek_type_definition<CR>",
          desc = "Peek type definition",
          cond = "textDocument/typeDefinition",
        }
        maps.n["grt"] = {
          "<Cmd>Lspsaga peek_type_definition<CR>",
          desc = "Peek type definition",
          cond = "textDocument/typeDefinition",
        }

        -- outline
        -- use aerial
        -- maps.n["<Leader>ls"] =
        --   { "<Cmd>Lspsaga outline<CR>", desc = "Symbols outline", cond = "textDocument/documentSymbol" }

        -- references
        -- NOTE: BUG
        -- maps.n["<Leader>lR"] = {
        --   "<Cmd>Lspsaga finder<CR>",
        --   desc = "Search references",
        --   cond = function(client)
        --     return client.supports_method "textDocument/references"
        --       or client.supports_method "textDocument/implementation"
        --   end,
        -- }

        -- rename
        maps.n["<Leader>lr"] =
          { "<Cmd>Lspsaga rename<CR>", desc = "Rename current symbol", cond = "textDocument/rename" }
        -- Close rename popup if press Esc in normal mode
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "sagarename",
          callback = function(event)
            vim.keymap.set("n", "<Esc>", "<cmd>confirm q<cr>", { buffer = event.buf, silent = true })
          end,
        })
      end,
    },
  },
  opts = function(_, opts)
    local astroui = require "astroui"
    local get_icon = function(icon) return astroui.get_icon(icon, 0, true) end
    opts.request_timeout = 2000
    opts.finder = {
      layout = "normal",
      keys = {
        shuttle = "p",
        tabnew = "",
        quit = "q",
        edit = "<C-c>o",
        vsplit = "<C-c>v",
        split = "<C-c>i",
        tabe = "<C-c>t",
        close = "<ESC>",
      },
    }
    opts.definition = {
      width = 0.8,
      height = 0.8,
      keys = {
        edit = "<C-c>o",
        vsplit = "<C-c>v",
        split = "<C-c>i",
        tabe = "<C-c>t",
        quit = "q",
      },
    }
    opts.code_action = {
      num_shortcut = true,
      show_server_name = true,
      extend_gitsigns = require("astrocore").is_available "gitsigns.nvim",
      keys = {
        -- string | table type
        quit = { "q", "<ESC>" },
        exec = "<CR>",
      },
    }
    opts.lightbulb = {
      enable = true,
      enable_in_insert = true,
      sign = false,
      sign_priority = 40,
      virtual_text = true,
    }
    opts.diagnostic = {
      show_code_action = true,
      show_source = true,
      jump_num_shortcut = true,
      --1 is max
      max_width = 0.8,
      extend_relatedInformation = true,
      -- text_hl_follow = false,
      -- border_follow = false,
      keys = {
        exec_action = "o",
        quit = "q",
        go_action = "g",
        toggle_or_jump = "<CR>",
        quit_in_show = { "q", "<ESC>" },
      },
    }
    opts.rename = {
      keys = {
        quit = "<C-k>",
        exec = "<CR>",
        select = "x",
        confirm = "<CR>",
      },
      in_select = false,
    }
    opts.outline = {
      win_position = "right",
      detail = false,

      auto_preview = true,
      auto_close = true,
      -- float or normal
      layout = "normal",
      keys = {
        quit = "q",
        toggle_or_jump = { "<CR>", "l" },
        jump = "o",
      },
    }
    opts.symbol_in_winbar = {
      enable = false,
      separator = "  ",
      -- ignore_patterns = {},
      hide_keyword = true,
      show_file = true,
      folder_level = 0,
      -- respect_root = true,
      color_mode = true,
    }
    opts.beacon = {
      enable = true,
      frequency = 7,
    }
    opts.ui = {
      title = true,
      border = "rounded",
      winblend = 0,
      code_action = get_icon "DiagnosticHint",
      expand = get_icon "FoldClosed",
      collapse = get_icon "FoldOpened",
      lines = { "┗", "┣", "┃", "━", "┏" },
      scroll_preview = {
        scroll_down = "<C-j>",
        scroll_up = "<C-k>",
      },
      -- imp_sign = get_icon "",
    }
  end,
}
