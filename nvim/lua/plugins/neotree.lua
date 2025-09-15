---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  optional = true,
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        -- maps.n["<Leader>e"] = { "<Cmd>Neotree toggle reveal_force_cwd<CR>", desc = "Toggle Explorer" }
        maps.n["<Leader>e"] = {
          function()
            if vim.bo.filetype == "neo-tree" then
              vim.cmd.Neotree "close"
            else
              vim.cmd "Neotree toggle reveal_force_cwd"
            end
          end,
          desc = "Toggle Explorer",
        }
      end,
    },
  },
  opts = {
    popup_border_style = "rounded",
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function(_)
          vim.cmd [[
              setlocal number relativenumber
              setlocal nu rnu
            ]]
        end,
      },
      {
        event = "neo_tree_popup_input_ready",
        handler = function(args)
          -- map <esc> to enter normal mode (by default closes prompt)
          -- don't forget `opts.buffer` to specify the buffer of the popup.
          vim.keymap.set("i", "<esc>", vim.cmd.stopinsert, { noremap = true, buffer = args.bufnr })
        end,
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true,
      },
    },
    commands = {
      child_or_open = function(state)
        local node = state.tree:get_node()
        if node:has_children() then
          if not node:is_expanded() then -- if unexpanded, expand
            state.commands.toggle_node(state)
          else -- if expanded and has children, seleect the next child
            if node.type == "file" then
              state.commands.open_with_window_picker(state)
            else
              require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
            end
          end
        else -- if has no children
          state.commands.open_with_window_picker(state)
        end
      end,
    },
    window = {
      auto_expand_width = false,
      width = "fit_content",
      mappings = {
        ["<Tab>"] = { "toggle_preview", config = { use_float = false, use_image_nvim = true, use_snacks_image = true } },
        ["/"] = "",
        ["H"] = "prev_source",
        ["L"] = "next_source",
        ["<M-h>"] = "toggle_hidden",
      },
    },

    nesting_rules = {},
    filesystem = {
      window = {
        mappings = {
          ["f"] = nil,
          ["<ESC>"] = "clear_filter",
        },
      },
      filtered_items = {
        visible = true, -- when true, they will just be displayed differently than normal items
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false,
        hide_by_name = {
          ".DS_Store",
          "thumbs.db",
          "node_modules",
        },
        hide_by_pattern = {
          --"*.meta",
          --"*/src/*/tsconfig.json",
        },
        always_show = { -- remains visible even if other settings would normally hide it
          --".gitignored",
        },
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          --".DS_Store",
          --"thumbs.db",
        },
        never_show_by_pattern = { -- uses glob style patterns
          --".null-ls_*",
        },
        follow_current_file = {
          enabled = true,
        },
      },
    },
    open_files_do_not_replace_types = {
      "terminal",
      "Trouble",
      "qf",
      "quickfix",
      "edgy",
      "help",
      "netrw",
      "NvimTree",
      "lazy",
      "mason",
      "oil",
      "neo-tree",
      "dapui_scopes",
      "dapui_breakpoints",
      "dapui_watches",
      "dapui_console",
      "dap-repl",
      "neotest-summary",
      "neotest-output-panel",
      "edgy",
      "edgy",
      "grug-far",
      "grug-far-history",
      "grug-far-help",
      "diff",
      "undotree",
      "markdown.gpchat",
      "toggleterm",
      "DressingSelect",
      "TelescopePrompt",
      "Outline",
      "prompt",
    }, -- when opening files, do not use windows containing these filetypes or buftypes
  },
}
