local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

---@type LazySpec
return {
  "saghen/blink.cmp",
  version = "^1",
  optional = true,
  dependencies = {
    {
      "Kaiser-Yang/blink-cmp-git",
      dependencies = { "nvim-lua/plenary.nvim" },
      lazy = true,
    },
    { "disrupted/blink-cmp-conventional-commits", lazy = true },
    { "xzbdmw/colorful-menu.nvim", lazy = true },
    -- ... other dependencies
  },

  opts = {
    sources = {
      -- add 'git' to the list
      default = { "conventional_commits", "git" },
      providers = {
        git = {
          module = "blink-cmp-git",
          name = "Git",
          -- only enable this source when filetype is gitcommit, markdown, or 'octo'
          enabled = function() return vim.tbl_contains({ "octo", "gitcommit", "markdown" }, vim.bo.filetype) end,
          --- @module 'blink-cmp-git'
          --- @type blink-cmp-git.Options
          opts = {
            commit = {
              -- You may want to customize when it should be enabled
              -- The default will enable this when `git` is found and `cwd` is in a git repository
              -- enable = function() end
              -- You may want to change the triggers
              -- triggers = { ':' },
            },
            git_centers = {
              github = {
                -- Those below have the same fields with `commit`
                -- Those features will be enabled when `git` and `gh` (or `curl`) are found and
                -- remote contains `github.com`
                -- issue = {
                --     get_token = function() return '' end,
                -- },
                -- pull_request = {
                --     get_token = function() return '' end,
                -- },
                -- mention = {
                --     get_token = function() return '' end,
                --     get_documentation = function(item)
                --         local default = require('blink-cmp-git.default.github')
                --             .mention.get_documentation(item)
                --         default.get_token = function() return '' end
                --         return default
                --     end
                -- }
              },
              gitlab = {
                -- Those below have the same fields with `commit`
                -- Those features will be enabled when `git` and `glab` (or `curl`) are found and
                -- remote contains `gitlab.com`
                -- issue = {
                --     get_token = function() return '' end,
                -- },
                -- NOTE:
                -- Even for `gitlab`, you should use `pull_request` rather than`merge_request`
                -- pull_request = {
                --     get_token = function() return '' end,
                -- },
                -- mention = {
                --     get_token = function() return '' end,
                --     get_documentation = function(item)
                --         local default = require('blink-cmp-git.default.gitlab')
                --            .mention.get_documentation(item)
                --         default.get_token = function() return '' end
                --         return default
                --     end
                -- }
              },
            },
          },
        },
        conventional_commits = {
          name = "Conventional Commits",
          module = "blink-cmp-conventional-commits",
          enabled = function() return vim.bo.filetype == "gitcommit" end,
          ---@module 'blink-cmp-conventional-commits'
          ---@type blink-cmp-conventional-commits.Options
          opts = {}, -- none so far
        },
      },
    },
    cmdline = {
      keymap = {
        -- recommended, as the default keymap will only show and select the next item
        ["<Tab>"] = {
          -- function(cmp)
          --   if cmp.is_ghost_text_visible() and not cmp.is_menu_visible() then return cmp.accept() end
          -- end,
          "show_and_insert",
          "select_next",
        },
        ["<CR>"] = {
          function(cmp)
            if cmp.is_ghost_text_visible() and not cmp.is_menu_visible() then return cmp.accept() end
          end,
          "accept_and_enter",
          "fallback",
        },
        ["<Left>"] = {},
        ["<Right>"] = {},
      },
      completion = {
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
    signature = {
      enabled = true,
      window = {
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        treesitter_highlighting = true,
        show_documentation = true,
      },
    },
    keymap = {
      ["<Tab>"] = {
        function(cmp) return cmp.select_next { auto_insert = vim.b.visual_multi ~= 1 } end,
        "snippet_forward",
        function(cmp)
          if has_words_before() or vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        function(cmp) return cmp.select_prev { auto_insert = vim.b.visual_multi ~= 1 } end,
        "snippet_backward",
        function(cmp)
          if vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
        end,
        "fallback",
      },
      ["<C-j>"] = {
        function(cmp) return cmp.select_prev { auto_insert = vim.b.visual_multi ~= 1 } end,
        "snippet_backward",
        "fallback",
      },
      ["<C-k>"] = {
        function(cmp) return cmp.select_next { auto_insert = vim.b.visual_multi ~= 1 } end,
        "snippet_forward",
        "fallback",
      },
      ["<CR>"] = {
        "accept",
        "fallback",
      },
    },
    -- fuzzy = {
    --   sorts = {
    --     function(a, b)
    --       if (a.client_name == nil or b.client_name == nil) or (a.client_name == b.client_name) then return end
    --       return b.client_name == "emmet_ls"
    --     end,
    --     -- default sorts
    --     "exact",
    --     "score",
    --     "sort_text",
    --   },
    --
    --   use_frecency = false,
    --   use_proximity = false,
    --   max_typos = function() return 0 end,
    -- },
    completion = {
      trigger = {
        show_on_backspace_in_keyword = true,
        show_on_insert = true,
      },
      ghost_text = {
        enabled = true,
        show_with_menu = true,
      },
      list = { selection = { preselect = false, auto_insert = true } },
      documentation = {
        draw = function(opts)
          if opts.item and opts.item.documentation then
            local hover_parser = require "pretty_hover.parser"
            local parsed_ok, result = pcall(function() return hover_parser.parse(opts.item.documentation.value) end)
            if parsed_ok and result then opts.item.documentation.value = result:string() end
          end

          opts.default_implementation(opts)
        end,
      },
      menu = {
        draw = {
          columns = {
            { "kind_icon" },
            { "label", gap = 1 },
            { "source_name" },
          },
          components = {
            label = {
              text = function(ctx)
                local highlights_info = require("colorful-menu").blink_highlights(ctx)
                if highlights_info ~= nil then
                  -- Or you want to add more item to label
                  return highlights_info.label
                else
                  return ctx.label
                end
              end,
              highlight = function(ctx)
                local highlights = {}
                local highlights_info = require("colorful-menu").blink_highlights(ctx)
                if highlights_info ~= nil then highlights = highlights_info.highlights end
                for _, idx in ipairs(ctx.label_matched_indices) do
                  table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                end
                -- Do something else
                return highlights
              end,
            },
            source_name = {
              width = { max = 100 },
              text = function(ctx) return "(" .. ctx.source_name .. ")" end,
              highlight = "BlinkCmpSource",
            },
          },
        },
        direction_priority = function()
          local ctx = require("blink.cmp").get_context()
          local item = require("blink.cmp").get_selected_item()
          if ctx == nil or item == nil then return { "s", "n" } end

          local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
          local is_multi_line = item_text:find "\n" ~= nil

          -- after showing the menu upwards, we want to maintain that direction
          -- until we re-open the menu, so store the context id in a global variable
          if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
            vim.g.blink_cmp_upwards_ctx_id = ctx.id
            return { "n", "s" }
          end
          return { "s", "n" }
        end,
      },
    },
  },
}
