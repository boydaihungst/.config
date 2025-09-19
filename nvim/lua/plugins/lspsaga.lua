---@type LazySpec
return {
  "boydaihungst/lspsaga.nvim",
  branch = "main",
  event = "LspAttach",
  cmd = "Lspsaga",
  -- Miniumum version of nvim = 0.12
  enabled = function() return vim.version().minor >= 12 end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    {
      "AstroNvim/astrolsp",
      opts = function(_, opts)
        local astrocore = require "astrocore"
        -- disabl default mapping
        if not opts.mappings then opts.mappings = astrocore.empty_map_table() end
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
        maps.n["<Leader>la"] =
          { "<Cmd>Lspsaga code_action<CR>", desc = "Code action", cond = "textDocument/codeAction" }
        maps.x["<Leader>la"] =
          { ":<C-U>Lspsaga code_action<CR>", desc = "Code action", cond = "textDocument/codeAction" }

        -- diagnostic
        maps.n["<Leader>ld"] = { "<Cmd>Lspsaga show_line_diagnostics ++unfocus<CR>", desc = "Diagnostics in line" }

        -- definition
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
        maps.n["<Leader>li"] = {
          function()
            -- Recursive function to flatten capabilities table
            local function flatten_table(tbl, prefix, result)
              result = result or {}
              prefix = prefix or ""

              for k, v in pairs(tbl) do
                local key = prefix ~= "" and (prefix .. "." .. k) or k
                if type(v) == "table" then
                  flatten_table(v, key, result)
                else
                  table.insert(result, key)
                end
              end

              return result
            end

            -- Get client capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- Flatten and print all capability names
            local all_caps = flatten_table(capabilities)
            table.sort(all_caps)

            print "All LSP capability names:"
            for _, name in ipairs(all_caps) do
              print(name)
            end
          end,
          desc = "Lsp infomation",
        }

        -- outline
        -- NOTE: BUG use aerial instead
        -- maps.n["<Leader>ls"] =
        --   { "<Cmd>Lspsaga outline<CR>", desc = "Symbols outline", cond = "textDocument/documentSymbol" }

        -- references
        maps.n["<Leader>lR"] = {
          "<Cmd>Lspsaga finder def+ref+imp+tyd<CR>",
          desc = "Search Def+Imp+Ref+typeDef",
          cond = function(client)
            return client.supports_method "textDocument/references"
              or client.supports_method "textDocument/implementation"
              or client.supports_method "textDocument/typeDefinition"
          end,
        }

        -- rename
        maps.n["<Leader>lr"] =
          { "<Cmd>Lspsaga rename<CR>", desc = "Rename current symbol", cond = "textDocument/rename" }
        -- Close rename popup if press Esc in normal mode
        -- vim.api.nvim_create_autocmd("FileType", {
        --   pattern = "sagarename",
        --   callback = function(event)
        --     vim.keymap.set("n", "<Esc>", "<cmd>confirm q<cr>", { buffer = event.buf, silent = true })
        --   end,
        -- })
      end,
    },
  },
  opts = function(_, opts)
    local astrocore = require "astrocore"
    local astroui = require "astroui"
    local get_icon = function(icon) return astroui.get_icon(icon, 0, true) end
    opts.request_timeout = 2000
    opts.finder = {
      layout = "float",
      keys = {
        shuttle = "p",
        quit = { "q", "<ESC>" },
        edit = "<C-c>o",
        vsplit = "<C-c>v",
        split = "<C-c>i",
        tabe = "<C-c>t",
        close = { "q", "<ESC>" },
        go_peek = "l",
        toggle_or_open = "<CR>",
      },
      default = "disabledef+ref+imp+tyd",
      filter = {},
      methods = {
        ["tyd"] = "textDocument/typeDefinition",
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
      extend_gitsigns = astrocore.is_available "gitsigns.nvim",
      keys = {
        -- string | table type
        quit = { "q", "<ESC>" },
        exec = "<CR>",
      },
      -- code action will display from high > low priority
      server_priority = {
        default = 1000,
        gitsigns = 100,
        ["dev-tools"] = 400,
      },
    }
    opts.lightbulb = {
      enable = true,
      enable_in_insert = true,
      sign = false,
      sign_priority = 40,
      virtual_text = true,
      ignore = {
        clients = {
          astrocore.is_available "dev-tools.nvim" and "dev-tools",
        },
        ft = {},
      },
    }
    opts.diagnostic = {
      show_code_action = true,
      show_source = true,
      jump_num_shortcut = true,
      auto_preview = true,
      show_layout = "float",
      show_normal_height = 10,
      max_width = 0.8,
      max_height = 0.6,
      max_show_width = 0.9,
      max_show_height = 0.6,
      wrap_long_lines = true,
      diagnostic_only_current = false,
      extend_relatedInformation = true,
      keys = {
        focus_code_action = "<C-c>o",
        exec_action = "o",
        quit = "q",
        toggle_or_jump = "<CR>",
        quit_in_show = { "q", "<ESC>" },
      },
    }
    -- NOTE: Need to set symbols_in_winbar.enable = true
    opts.implement = {
      enable = false,
      sign = true,
      -- code language/filetype
      -- lang = { "typescript" },
      virtual_text = false,
      priority = 100,
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
      enable = true,
      separator = "  ",
      ignore_patterns = {
        "^oil$",
      },
      hide_keyword = true,
      show_file = false,
      folder_level = 0,
      -- respect_root = true,
      color_mode = true,
    }
    -- Blink highlight after jump
    opts.beacon = {
      enable = true,
      -- Higher value means shorter blink, 1-10
      frequency = 8,
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
