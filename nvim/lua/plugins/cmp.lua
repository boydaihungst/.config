---@type LazySpec
return {
  {
    "tzachar/cmp-tabnine",
    as = "cmp_tabnine",
    build = "./install.sh",
    -- dependencies = "hrsh7th/nvim-cmp",
    lazy = true,
    event = "InsertEnter",
    config = function()
      require("cmp_tabnine.config"):setup {
        max_lines = 1000,
        max_num_results = 20,
        sort = true,
        run_on_every_keystroke = true,
        snippet_placeholder = "..",
        ignored_file_types = {
          -- default is not to ignore
          -- uncomment to ignore in lua:
          -- lua = true
        },
        show_prediction_strength = true,
        min_percent = 0,
      }
    end,
  },
  {
    "David-Kunz/cmp-npm",
    ft = { "json" },
    dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
    config = function() require("cmp-npm").setup {} end,
  },
  {
    "hrsh7th/cmp-emoji",
    lazy = true,
    event = { "InsertEnter" },
  },
  {
    "petertriho/cmp-git",
    lazy = true,
    ft = { "gitcommit", "octo" },
  },
  {
    "FelipeLema/cmp-async-path",
    lazy = true,
    event = { "InsertEnter" },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "onsails/lspkind.nvim",
      "FelipeLema/cmp-async-path",
      "petertriho/cmp-git",
      "hrsh7th/cmp-emoji",
      "tzachar/cmp-tabnine",
      "David-Kunz/cmp-npm",
    },
    opts = function(_, opts)
      local cmp = require "cmp"
      local lspkind = require "lspkind"
      local astroui = require "astroui"
      opts.sources = cmp.config.sources {
        {
          name = "nvim_lsp",
          entry_filter = function(entry, ctx)
            local kind = require("cmp.types.lsp").CompletionItemKind[entry:get_kind()]
            if kind == "Snippet" and ctx.prev_context.filetype == "java" then return false end
            return true
          end,
          priority = 1000,
        },
        { name = "async_path", priority = 900, option = {
          trailing_slash = true,
        } },
        { name = "luasnip", priority = 800 },
        { name = "npm", keyword_length = 3, priority = 700 },
        { name = "cmp_tabnine", priority = 600 },
        { name = "git", priority = 500 },
        {
          name = "emoji",
          trigger_characters = { ":" },
          priority = 400,
        },
        { name = "buffer", priority = 300 },
      }
      opts.formatting = {
        fields = { "kind", "abbr", "menu" },
        max_width = 0,
        kind_icons = lspkind.symbol_map,
        source_names = {
          nvim_lsp = "(LSP)",
          emoji = "(Emoji)",
          path = "(Path)",
          calc = "(Calc)",
          cmp_tabnine = "(Tabnine)",
          vsnip = "(Snippet)",
          luasnip = "(Snippet)",
          buffer = "(Buffer)",
          tmux = "(TMUX)",
          copilot = "(Copilot)",
          treesitter = "(TreeSitter)",
        },
        duplicates = {
          buffer = 1,
          path = 1,
          nvim_lsp = 0,
          luasnip = 1,
        },
        duplicates_default = 0,
        format = function(entry, vim_item)
          local max_width = 0
          if max_width ~= 0 and #vim_item.abbr > max_width then
            vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. astroui.get_icon "Ellipsis"
          end
          vim_item.kind = opts.formatting.kind_icons[vim_item.kind]

          if entry.source.name == "cmp_tabnine" then
            vim_item.kind = "󰚩"
            vim_item.kind_hl_group = "CmpItemKindTabnine"
          end

          if entry.source.name == "crates" then
            vim_item.kind = ""
            vim_item.kind_hl_group = "CmpItemKindCrate"
          end

          if entry.source.name == "lab.quick_data" then
            vim_item.kind = ""
            vim_item.kind_hl_group = "CmpItemKindConstant"
          end

          if entry.source.name == "emoji" then
            vim_item.kind = ""
            vim_item.kind_hl_group = "CmpItemKindEmoji"
          end
          vim_item.menu = opts.formatting.source_names[entry.source.name]
          vim_item.dup = opts.formatting.duplicates[entry.source.name] or opts.formatting.duplicates_default
          return vim_item
        end,
      }
      opts.completion = {
        ---@usage The minimum length of a word to complete on.
        keyword_length = 1,
      }
      opts.completion.autocomplete = {
        require("cmp.types").cmp.TriggerEvent.TextChanged,
        require("cmp.types").cmp.TriggerEvent.InsertEnter,
        completeopt = "menu,menuone,noinsert,noselect",
      }
      return opts
    end,
  },
}
