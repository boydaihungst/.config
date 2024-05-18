return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    enable_cursor_hijack = true,
    open_files_do_not_replace_types = {
      "terminal",
      "Trouble",
      "qf",
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
    }, -- when opening files, do not use windows containing these filetypes or buftypes
    window = {
      auto_expand_width = true,
    },

    nesting_rules = {
      ["package.json"] = {
        pattern = "^package%.json$", -- <-- Lua pattern
        files = { "package-lock.json", "yarn*" }, -- <-- glob pattern
      },
      ["go"] = {
        pattern = "(.*)%.go$", -- <-- Lua pattern with capture
        files = { "%1_test.go" }, -- <-- glob pattern with capture
      },
      ["js-extended"] = {
        pattern = "(.+)%.js$",
        files = { "%1.js.map", "%1.min.js", "%1.d.ts" },
      },
      ["docker"] = {
        pattern = "^dockerfile$",
        ignore_case = true,
        files = { ".dockerignore", "docker-compose.*", "dockerfile*" },
      },
    },
    filesystem = {
      -- hijack_netrw_behavior = "open_default",
      -- cwd_target = {
      --   sidebar = "global",
      --   current = "global",
      -- },
      filtered_items = {
        visible = false, -- when true, they will just be displayed differently than normal items
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
      },
    },
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function(_)
          vim.opt_local.signcolumn = "auto"
          vim.opt_local.foldcolumn = "0"
          vim.opt_local.relativenumber = true
        end,
      },
    },
  },
}
