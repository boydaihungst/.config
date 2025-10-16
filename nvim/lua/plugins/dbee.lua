local prefix = "<leader>D"
---@type LazySpec
return {
  "kndndrj/nvim-dbee",
  enabled = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
    { "AstroNvim/astroui", opts = { icons = { Database = "" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
        local maps = opts.mappings
        maps.n[prefix] = { desc = require("astroui").get_icon("Database", 1, true) .. "Database" }
        maps.n[prefix .. "u"] = { function() require("dbee").toggle() end, desc = "Toggle UI" }
      end,
    },
  },
  build = function() require("dbee").install() end,
  opts = function(_, opts)
    opts.sources = {
      -- EnvSource loads connection from an environment variable.
      -- export DBEE_CONNECTIONS='[
      --     {
      --         "name": "DB from env",
      --         "url": "username:password@tcp(host)/database-name",
      --         "type": "mysql"
      --     }
      -- ]'
      -- require("dbee.sources").EnvSource:new "DBEE_CONNECTIONS",

      -- FileSource loads connections from a given json file. It also supports editing and adding connections interactively
      require("dbee.sources").FileSource:new(vim.fn.stdpath "cache" .. "/dbee/persistence.json"),
    }
    -- extra table helpers per connection type
    -- every helper value is a go-template with values set for
    -- "Table", "Schema" and "Materialization"
    opts.extra_helpers = {
      -- example:
      -- ["postgres"] = {
      --   ["List All"] = "select * from {{ .Table }}",
      -- },
    }

    -- drawer window config
    opts.drawer = {
      -- show help or not
      disable_help = false,
      -- mappings for the buffer
      mappings = {
        -- manually refresh drawer
        { key = "R", mode = "n", action = "refresh" },
        -- actions perform different stuff depending on the node:
        -- action_1 opens a note or executes a helper
        { key = "<CR>", mode = "n", action = "action_1" },
        -- action_2 renames a note or sets the connection as active manually
        { key = "r", mode = "n", action = "action_2" },
        -- action_3 deletes a note or connection (removes connection from the file if you configured it like so)
        { key = "dd", mode = "n", action = "action_3" },
        -- these are self-explanatory:
        { key = "h", mode = "n", action = "collapse" },
        { key = "l", mode = "n", action = "expand" },
        { key = "o", mode = "n", action = "toggle" },
        -- mappings for menu popups:
        { key = "<CR>", mode = "n", action = "menu_confirm" },
        { key = "y", mode = "n", action = "menu_yank" },
        { key = "<Esc>", mode = "n", action = "menu_close" },
        { key = "q", mode = "n", action = "menu_close" },
      },
    }

    -- results window config
    opts.result = {
      -- see drawer comment.
      -- window_options = {},
      -- buffer_options = {},

      -- number of rows in the results set to display per page
      page_size = 100,

      -- whether to focus the result window after a query
      focus_result = false,

      -- progress (loading) screen options
      progress = {
        -- spinner to use in progress display
        spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        -- prefix to display before the timer
        text_prefix = "Executing...",
      },

      -- mappings for the buffer
      mappings = {
        -- next/previous page
        { key = "L", mode = "", action = "page_next" },
        { key = "H", mode = "", action = "page_prev" },
        { key = "E", mode = "", action = "page_last" },
        { key = "F", mode = "", action = "page_first" },
        -- yank rows as csv/json
        { key = "yaj", mode = "n", action = "yank_current_json" },
        { key = "yaj", mode = "v", action = "yank_selection_json" },
        { key = "yaJ", mode = "", action = "yank_all_json" },
        { key = "yac", mode = "n", action = "yank_current_csv" },
        { key = "yac", mode = "v", action = "yank_selection_csv" },
        { key = "yaC", mode = "", action = "yank_all_csv" },

        -- cancel current call execution
        { key = "<C-c>", mode = "", action = "cancel_call" },
      },
    }

    -- editor window config
    opts.editor = {
      -- see drawer comment.
      -- window_options = {},
      -- buffer_options = {},

      -- directory where to store the scratchpads.
      --directory = "path/to/scratchpad/dir",

      -- mappings for the buffer
      mappings = {
        -- run what's currently selected on the active connection
        { key = "BB", mode = "v", action = "run_selection" },
        -- run the whole file on the active connection
        { key = "BB", mode = "n", action = "run_file" },
        -- run what's under the cursor to the next newline
        { key = "<CR>", mode = "n", action = "run_under_cursor" },
      },
    }

    -- call log window config
    opts.call_log = {
      -- see drawer comment.
      -- window_options = {},
      -- buffer_options = {},

      -- mappings for the buffer
      mappings = {
        -- show the result of the currently selected call record
        { key = "<CR>", mode = "", action = "show_result" },
        -- cancel the currently selected call (if its still executing)
        { key = "<C-c>", mode = "", action = "cancel_call" },
      },

      -- candies (icons and highlights)
      disable_candies = false,
      candies = {
        -- all of these represent call states
        unknown = {
          icon = "", -- this or first letters of state
          icon_highlight = "NonText", -- highlight of the state
          text_highlight = "", -- highlight of the rest of the line
        },
        executing = {
          icon = "󰑐",
          icon_highlight = "Constant",
          text_highlight = "Constant",
        },
        executing_failed = {
          icon = "󰑐",
          icon_highlight = "Error",
          text_highlight = "",
        },
        retrieving = {
          icon = "",
          icon_highlight = "String",
          text_highlight = "String",
        },
        retrieving_failed = {
          icon = "",
          icon_highlight = "Error",
          text_highlight = "",
        },
        archived = {
          icon = "",
          icon_highlight = "Title",
          text_highlight = "",
        },
        archive_failed = {
          icon = "",
          icon_highlight = "Error",
          text_highlight = "",
        },
        canceled = {
          icon = "",
          icon_highlight = "Error",
          text_highlight = "",
        },
      },
    }

    -- window layout
    opts.window_layout = require("dbee.layouts").Default:new {
      call_log_height = 10,
      drawer_width = 40,
      result_height = 10,
      on_switch = "close",
    }
  end,
}
