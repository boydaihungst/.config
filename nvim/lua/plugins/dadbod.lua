local prefix = "<leader>D"
---@type LazySpec
return {
  "kristijanhusak/vim-dadbod-ui",
  optional = true,
  dependencies = {
    { "AstroNvim/astroui", opts = { icons = { Database = "" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
        local maps = opts.mappings
        maps.n[prefix] = { desc = require("astroui").get_icon("Database", 1, true) .. "Database" }
        maps.n[prefix .. "u"] = { "<CMD>DBUIToggle<CR>", desc = "Toggle UI" }
        maps.n[prefix .. "n"] = { "<CMD>DBUIAddConnection<CR>", desc = "Add New Connection" }
        maps.n[prefix .. "f"] = { "<CMD>DBUIFindBuffer<CR>", desc = "Find Buffer" }
        maps.n[prefix .. "f"] = { "<CMD>DBUIFindBuffer<CR>", desc = "Find Buffer" }

        if not opts.autocmds then opts.autocmds = {} end

        opts.autocmds.dadbod_mappings = {
          {
            event = "FileType",
            pattern = "sql",
            desc = "Custom dadbod mappings for sql buffers",
            group = "dadbod_mappings",
            callback = function()
              local sql_keymap_opts = { buffer = true }
              vim.keymap.set(
                "n",
                prefix .. "o",
                "<Plug>(DBUI_SelectLine)<cr>",
                vim.tbl_extend("force", sql_keymap_opts, { desc = "Open/Toggle Drawer options" })
              )
              vim.keymap.set(
                "n",
                prefix .. "<CR>",
                "<Plug>(DBUI_SelectLine)<cr>",
                vim.tbl_extend("force", sql_keymap_opts, { desc = "Open/Toggle Drawer options" })
              )
              vim.keymap.set(
                "n",
                prefix .. "S",
                "<Plug>(DBUI_SelectLineVsplit)<cr>",
                vim.tbl_extend("force", sql_keymap_opts, { desc = "Open in vertical split" })
              )
              vim.keymap.set(
                "n",
                prefix .. "d",
                "<Plug>(DBUI_DeleteLine)<cr>",
                vim.tbl_extend("force", sql_keymap_opts, { desc = "Delete buffer or saved sql" })
              )
              vim.keymap.set(
                "n",
                prefix .. "R",
                "<Plug>(DBUI_Redraw)<cr>",
                vim.tbl_extend("force", sql_keymap_opts, { desc = "Redraw" })
              )
              vim.keymap.set(
                "n",
                prefix .. "A",
                "<Plug>(DBUI_AddConnection)<cr>",
                vim.tbl_extend("force", sql_keymap_opts, { desc = "Add connection" })
              )
              vim.keymap.set(
                "n",
                prefix .. "H",
                "<Plug>(DBUI_ToggleDetails)<cr>",
                vim.tbl_extend("force", sql_keymap_opts, { desc = "Toggle database details" })
              )
            end,
          },
        }
        -- Global settings (vim.g)
        opts.options.g = {
          db_ui_auto_execute_table_helpers = 0,
          db_ui_disable_progress_bar = 1,
          db_ui_winwidth = 60,
          -- db_ui_disable_mappings = 1, -- Disable all mappings
          -- db_ui_disable_mappings_dbui = 1, -- Disable mappings in DBUI drawer
          -- db_ui_disable_mappings_dbout = 1, -- Disable mappings in DB output
          db_ui_disable_mappings_sql = 1, -- Disable mappings in SQL buffers
          -- db_ui_disable_mappings_javascript = 1, -- Disable mappings in Javascript buffers (for Mongodb)
        }
      end,
    },
  },
}
