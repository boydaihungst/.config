on_event("LspAttach", function()
  add {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    { src = "https://github.com/boydaihungst/lspsaga.nvim", version = "main" },
  }
  if vim.version().minor < 12 then return end
  local opts = {}
  local get_icon = function(icon) return Config.get_custom_icon(icon, 0, true) end
  opts.request_timeout = 2000
  opts.finder = {
    layout = "float",
    keys = {
      -- Switch between preview and lt result windows
      shuttle = { "<C-h>", "<C-l>" },
      edit = "o",
      vsplit = "<C-w>v",
      split = "<C-w>s",
      tabe = "<C-c>t",
      close = { "q", "<ESC>" },
      quit = { "q", "<ESC>" },
      go_peek = { "l", "h" },
      toggle_or_open = "<CR>",
    },
    default = "ref+imp+tyd",
    filter = {},
    methods = {
      ["tyd"] = "textDocument/typeDefinition",
      ["dec"] = "textDocument/declaration",
    },
  }
  opts.definition = {
    width = 0.8,
    height = 0.7,
    keys = {
      edit = "<C-c>o",
      vsplit = "<C-w>v",
      split = "<C-w>s",
      tabe = "<C-c>t",
      quit = "q",
      close = "<ESC>",
    },
  }
  opts.code_action = {
    num_shortcut = true,
    show_server_name = true,
    max_width = 0.8,
    max_height = 0.6,
    extend_gitsigns = pcall(require, "gitsigns.nvim"),
    wrap_around = true,
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
      eslint = 500,
      eslint_d = 500,
    },
  }
  opts.lightbulb = {
    enable = true,
    enable_in_insert = true,
    sign = true,
    sign_priority = 40,
    virtual_text = false,
    ignore = {
      clients = {
        "dev-tools",
      },
      ft = { "nvim-undotree" },
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
      exec_action = "<CR>",
      quit = "q",
      send_to_quickfix = "<C-q>",
      toggle_or_jump = "<CR>",
      quit_in_show = { "q", "<ESC>" },
    },
  }
  -- NOTE: Need to set symbols_in_winbar.enable = true
  opts.implement = {
    enable = true,
    sign = true,
    -- code language/filetype
    -- lang = { "typescript" },
    virtual_text = false,
    priority = 100,
  }
  opts.callhierarchy = {
    layout = "float",
    left_width = 0.2,
    keys = {
      edit = "o",
      vsplit = "v",
      split = "s",
      tabe = "t",
      close = { "q", "<ESC>" },
      quit = { "q", "<ESC>" },
      shuttle = "[w",
      toggle_or_req = "u",
    },
  }
  opts.typehierarchy = {
    layout = "float",
    left_width = 0.2,
    keys = {
      edit = "o",
      vsplit = "<C-w>v",
      split = "<C-w>s",
      tabe = "<C-t>",
      close = { "q", "<ESC>" },
      quit = { "q", "<ESC>" },
      shuttle = { "<C-h>", "<C-l>" },
      toggle_or_req = "u",
    },
  }

  opts.rename = {
    keys = {
      quit = "<C-q>",
      exec = "<CR>",
      select = "x",
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
    -- imp_sign = get_icon "",
  }
  opts.scroll_preview = {
    scroll_down = "<C-j>",
    scroll_up = "<C-k>",
  }

  require("lspsaga").setup(opts)

  vim.lsp.buf.incoming_calls = function() vim.cmd "Lspsaga incoming_calls" end
  vim.lsp.buf.outgoing_calls = function() vim.cmd "Lspsaga outgoing_calls" end
  vim.lsp.buf.code_action = function() vim.cmd "Lspsaga code_action" end
  local original_rename = vim.lsp.buf.rename
  vim.lsp.buf.rename = function(new_name, ...)
    if not new_name then
      require("lspsaga.rename"):lsp_rename(...)
    else
      original_rename(new_name, ...)
    end
  end
  vim.lsp.buf.definition = function()
    local _, i18n = pcall(require, "i18n")
    if i18n and i18n._activated then
      if i18n.i18n_definition() or i18n.i18n_definition_next_locale() then return end
    end
    vim.cmd "Lspsaga peek_definition"
  end
  vim.lsp.buf.implementation = function() vim.cmd "Lspsaga finder imp" end
  vim.lsp.buf.references = function()
    local _, i18n = pcall(require, "i18n")
    if i18n and i18n._activated and i18n.i18n_key_usages() then return end
    vim.cmd "Lspsaga finder ref"
  end
  vim.lsp.buf.type_definition = function() vim.cmd "Lspsaga peek_type_definition" end
  vim.lsp.buf.typehierarchy = function(kind)
    if kind == "subtypes" then
      vim.cmd "Lspsaga subtypes"
    else
      vim.cmd "Lspsaga supertypes"
    end
  end
  vim.lsp.buf.declaration = function() vim.cmd "Lspsaga peek_declaration" end
end)
