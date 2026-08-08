now(function()
  add {
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "1.x" },
  }
  vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
  })
end)

later(function()
  add {
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/xzbdmw/colorful-menu.nvim",
    "https://github.com/Fildo7525/pretty_hover",
    -- sources
    "https://github.com/Kaiser-Yang/blink-cmp-git",
    "https://github.com/disrupted/blink-cmp-conventional-commits",
    "https://github.com/saghen/blink.compat",
  }

  local function has_words_before()
    local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
  end

  -- Check if there  any autopair fastwrap extmarks
  local function has_fastwrap_extmarks(bufnr)
    bufnr = bufnr or 0 -- Default to current buffer
    local fastwarp_ext, fastwarp = pcall(require, "nvim-autopairs.fastwrap")
    if not fastwarp_ext then return false end
    local line_num = vim.api.nvim_win_get_cursor(0)[1] - 1
    local extmarks = vim.api.nvim_buf_get_extmarks(
      bufnr,
      fastwarp.ns_fast_wrap,
      { line_num, 0 },
      { line_num, -1 },
      { details = false, limit = 1 }
    )

    return #extmarks > 0
  end

  ---@type function?, function?
  local icon_provider, hl_provider

  local function get_kind_icon(CTX)
    -- Evaluate icon provider
    if not icon_provider then
      local _, mini_icons = pcall(require, "mini.icons")
      if _G.MiniIcons then
        icon_provider = function(ctx)
          local is_specific_color = ctx.kind_hl and ctx.kind_hl:match "^HexColor" ~= nil
          if ctx.item.source_name == "LSP" then
            local icon, hl = mini_icons.get("lsp", ctx.kind or "")
            if icon then
              ctx.kind_icon = icon
              if not is_specific_color then ctx.kind_hl = hl end
            end
          elseif ctx.item.source_name == "Path" then
            ctx.kind_icon, ctx.kind_hl = mini_icons.get(ctx.kind == "Folder" and "directory" or "file", ctx.label)
          elseif ctx.item.source_name == "Snippets" then
            ctx.kind_icon, ctx.kind_hl = mini_icons.get("lsp", "snippet")
          end
        end
      end
      if not icon_provider then
        local lspkind_avail, lspkind = pcall(require, "lspkind")
        if lspkind_avail then
          icon_provider = function(ctx)
            if ctx.item.source_name == "LSP" then
              local icon = lspkind.symbol_map[ctx.kind]
              if icon then ctx.kind_icon = icon end
            elseif ctx.item.source_name == "Snippets" then
              local icon = lspkind.symbol_map["Snippet"]
              if icon then ctx.kind_icon = icon end
            end
          end
        end
      end
      if not icon_provider then icon_provider = function() end end
    end
    -- Evaluate highlight provider
    if not hl_provider then
      local highlight_colors_avail, highlight_colors = pcall(require, "nvim-highlight-colors")
      if highlight_colors_avail then
        local kinds
        hl_provider = function(ctx)
          if not kinds then kinds = require("blink.cmp.types").CompletionItemKind end
          if ctx.item.kind == kinds.Color then
            local doc = vim.tbl_get(ctx, "item", "documentation")
            if doc then
              local color_item = highlight_colors_avail and highlight_colors.format(doc, { kind = kinds[kinds.Color] })
              if color_item and color_item.abbr_hl_group then
                if color_item.abbr then ctx.kind_icon = color_item.abbr end
                ctx.kind_hl = color_item.abbr_hl_group
              end
            end
          end
        end
      end
      if not hl_provider then hl_provider = function() end end
    end
    -- Call resolved providers
    icon_provider(CTX)
    hl_provider(CTX)
    -- Return text and highlight information
    return { text = CTX.kind_icon .. CTX.icon_gap, highlight = CTX.kind_hl }
  end

  local blink = require "blink.cmp"
  blink.setup {
    enabled = function()
      local dap_prompt = pcall(require, "cmp-dap") -- add interoperability with cmp-dap
        and vim.tbl_contains({ "dap-repl", "dapui_watches", "dapui_hover" }, vim.bo.filetype)
      if vim.bo.buftype == "prompt" and not dap_prompt then return false end
      return vim.b.completion ~= false
    end,
    snippets = { preset = "mini_snippets" },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        -- Path completion from cwd instead of current buffer's directory
        path = {
          opts = {
            get_cwd = function(_) return vim.fn.getcwd() end,
          },
        },
      },
    },
    fuzzy = { implementation = "prefer_rust" },
    completion = {
      trigger = {
        show_on_backspace_in_keyword = true,
        show_on_insert = true,
      },
      ghost_text = {
        enabled = false,
        show_with_menu = true,
      },
      list = { selection = { preselect = false, auto_insert = true } },
      menu = {
        -- NOTE: Fix autopairs fastwrap overlapping menu
        auto_show = function(_, _) return not has_fastwrap_extmarks() end,
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        draw = {
          treesitter = { "lsp" },
          components = {
            kind_icon = {
              text = function(ctx) return get_kind_icon(ctx).text end,
              highlight = function(ctx) return get_kind_icon(ctx).highlight end,
            },
            label = {
              text = function(ctx) return require("colorful-menu").blink_components_text(ctx) end,
              highlight = function(ctx) return require("colorful-menu").blink_components_highlight(ctx) end,
            },
            source_name = {
              width = { max = 100 },
              text = function(ctx) return "(" .. ctx.source_name .. ")" end,
              highlight = "BlinkCmpSource",
            },
          },
          columns = {
            { "kind_icon" },
            { "label", gap = 1 },
            { "source_name" },
          },
        },
        ---@diagnostic disable-next-line: assign-type-mismatch
        direction_priority = function()
          local ctx = require("blink.cmp").get_context()
          local item = require("blink.cmp").get_selected_item()
          if ctx == nil or item == nil then return { "s", "n" } end

          local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
          local _multi_line = item_text:find "\n" ~= nil

          -- after showing the menu upwards, we want to maintain that direction
          -- until we re-open the menu, so store the context id in a global variable
          if _multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
            vim.g.blink_cmp_upwards_ctx_id = ctx.id
            return { "n", "s" }
          end
          return { "s", "n" }
        end,
      },
      accept = {
        auto_brackets = { enabled = true },
      },
      documentation = {
        draw = function(opts)
          if opts.item and opts.item.documentation and opts.item.documentation.value then
            local out = require("pretty_hover.parser").parse(opts.item.documentation.value)
            opts.item.documentation.value = out:string()
          end

          ---@diagnostic disable-next-line: param-type-mismatch
          opts.default_implementation(opts)
        end,
        auto_show = true,
        auto_show_delay_ms = 0,
        window = {
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        },
      },
    },
    cmdline = {
      -- NOTE: use mini.cmdline instead
      enabled = false,
      keymap = {
        ["<End>"] = { "hide", "fallback" },
      },
      completion = {
        ghost_text = { enabled = false },
        menu = {
          auto_show = true,
          draw = {
            columns = {
              { "kind_icon" },
              { "label", gap = 1 },
            },
          },
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
      },
    },
    -- NOTE: Use default nvim instead
    signature = {
      enabled = false,
      window = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },
    keymap = {
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-N>"] = { "select_next", "show" },
      ["<C-P>"] = { "select_prev", "show" },
      ["<C-J>"] = { "select_next", "fallback" },
      ["<C-K>"] = { "select_prev", "fallback" },
      ["<C-U>"] = { "scroll_documentation_up", "fallback" },
      ["<C-D>"] = { "scroll_documentation_down", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },

      ["<Tab>"] = {
        function(cmp)
          return cmp.select_next {
            auto_insert = not vim.g.Vm or vim.g.Vm.mappings_enabled == 0,
          }
        end,
        "snippet_forward",
        function(cmp)
          if has_words_before() or vim.api.nvim_get_mode().mode == "c" then cmp.show() end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        function(cmp)
          return cmp.select_prev {
            auto_insert = not vim.g.Vm or vim.g.Vm.mappings_enabled == 0,
          }
        end,
        "snippet_backward",
        function(cmp)
          if vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
        end,
        "fallback",
      },
      ["<C-j>"] = {
        "snippet_forward",
        "fallback",
      },
      ["<C-k>"] = {
        "snippet_backward",
        "fallback",
      },
      ["<CR>"] = {
        "accept",
        "fallback",
      },
    },
  }

  for _, filetype in ipairs { "octo", "gitcommit", "markdown" } do
    blink.add_filetype_source(filetype, "git")
  end
  blink.add_source_provider("git", {
    module = "blink-cmp-git",
    name = "Git",
    -- only enable th source when filetype is gitcommit, markdown, or 'octo'
    enabled = function() return vim.fn.executable "git" == 1 end,
    --- @module 'blink-cmp-git'
    --- @type blink-cmp-git.Options
    opts = {
      -- commit = {},
      -- git_centers = {
      -- github = {},
      -- gitlab = {},
      -- },
    },
  })

  for _, filetype in ipairs { "gitcommit" } do
    blink.add_filetype_source(filetype, "conventional_commits")
  end
  blink.add_source_provider("conventional_commits", {
    name = "Conventional Commits",
    module = "blink-cmp-conventional-commits",
    enabled = function() return vim.fn.executable "git" == 1 end,
    ---@module 'blink-cmp-conventional-commits'
    ---@type blink-cmp-conventional-commits.Options
    opts = {}, -- none so far
  })
end)
