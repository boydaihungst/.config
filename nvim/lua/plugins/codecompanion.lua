local prefix = "<Leader>A"

---@type LazySpec
return {
  "olimorris/codecompanion.nvim",
  optional = true,
  dependencies = {
    "ravitemer/codecompanion-history.nvim",
    -- Add mcphub.nvim as a dependency
    { "ravitemer/mcphub.nvim", optional = true },
    "franco-ruggeri/codecompanion-spinner.nvim",
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = {} end
        opts.mappings.n = opts.mappings.n or {}
        opts.mappings.v = opts.mappings.v or {}
        opts.mappings.n[prefix .. "h"] = { "<cmd>CodeCompanionHistory<cr>", desc = "Open history" }
        opts.mappings.v[prefix .. "s"] = { "<cmd>CodeCompanionSummaries<cr>", desc = "Browse summaries" }
      end,
    },
  },
  opts = {
    extensions = {
      history = {
        enabled = true,
        opts = {
          -- Keymap to open history from chat buffer (default: gh)
          keymap = "gh",
          -- Keymap to save the current chat manually (when auto_save is disabled)
          save_chat_keymap = "sc",
          -- Save all chats by default (disable to save only manually using 'sc')
          auto_save = true,
          -- Number of days after which chats are automatically deleted (0 to disable)
          expiration_days = 0,
          -- Picker interface (auto resolved to a valid picker)
          picker = "default", --- ("telescope", "snacks", "fzf-lua", or "default")
          ---Optional filter function to control which chats are shown when browsing
          chat_filter = nil, -- function(chat_data) return boolean end
          -- Customize picker keymaps (optional)
          -- picker_keymaps = {
          --   rename = { n = "r", i = "<M-r>" },
          --   delete = { n = "d", i = "<M-d>" },
          --   duplicate = { n = "<C-y>", i = "<C-y>" },
          -- },
          ---On exiting and entering neovim, loads the last chat on opening chat
          continue_last_chat = true,
          ---When chat is cleared with `gx` delete the chat from history
          delete_on_clearing_chat = false,
          ---Directory path to save the chats
          dir_to_save = vim.fn.stdpath "data" .. "/codecompanion-history",
          title_generation_opts = {
            adapter = "nvidia",
            model = "qwen/qwen3-235b-a22b",
          },

          -- Summary system
          summary = {
            -- Keymap to generate summary for current chat (default: "gcs")
            create_summary_keymap = "gcs",
            -- Keymap to browse summaries (default: "gbs")
            browse_summaries_keymap = "gbs",

            generation_opts = {
              adapter = "nvidia",
              model = "qwen/qwen3-235b-a22b",
              context_size = 260000, -- max tokens that the model supports
              include_references = true, -- include slash command content
              include_tool_outputs = true, -- include tool execution results
              -- system_prompt = nil, -- custom system prompt (string or function)
              -- format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
            },
          },

          -- Memory system (requires VectorCode CLI)
          memory = {
            -- Automatically index summaries when they are generated
            auto_create_memories_on_summary_generation = true,
            -- Path to the VectorCode executable
            vectorcode_exe = "vectorcode",
            -- Tool configuration
            tool_opts = {
              -- Default number of memories to retrieve
              default_num = 10,
            },
            -- Enable notifications for indexing progress
            notify = false,
            -- Index all existing memories on startup
            -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
            index_on_startup = true,
          },
        },
      },
      spinner = {},
    },
    language = "English",
    adapters = {
      acp = {
        -- TODO: wait for the next update
        gemini_cli = function()
          -- local MCPHub = require("mcphub").get_hub_instance()
          -- local mcpServers = {}
          -- if MCPHub then
          --   mcpServers = {
          --     {
          --       MCPHub = {
          --         url = "http://localhost:" .. MCPHub.port .. "/mcp",
          --       },
          --     },
          --   }
          -- end
          return require("codecompanion.adapters").extend("gemini_cli", {
            defaults = {
              auth_method = "gemini-api-key",
              -- mcpServers = mcpServers,
              timeout = 20000, -- 20 seconds
            },
            env = {
              api_key = "GEMINI_API_KEY",
            },
            -- env = {
            --   api_key = "cmd:op read op://personal/Gemini/credential --no-newline",
            -- },
          })
        end,
      },
      http = {
        nvidia = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            formatted_name = "Nvidia",
            env = {
              url = "https://integrate.api.nvidia.com",
              api_key = "NVIDIA_API_KEY",
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            schema = {
              model = {
                -- default = "openai/gpt-oss-120b",
                -- default = "deepseek-ai/deepseek-v3.1",
                default = "validqwen3-coder-480b-a35b-instruct",
                -- default = "meta/llama-4-maverick-17b-128e-instruct",
              },
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            schema = {
              model = {
                default = "gemini-2.5-flash",
              },
            },
          })
        end,
      },
    },
    strategies = {
      chat = {
        adapter = "gemini_cli",
      },
      inline = {
        adapter = "gemini_cli",
      },
      cmd = {
        adapter = "gemini_cli",
      },
    },
    display = {
      chat = {
        intro_message = "Welcome to CodeCompanion ✨!\n Press ? for options",
        separator = "─", -- The separator between the different messages in the chat buffer
        show_context = true, -- Show context (from slash commands and variables) in the chat buffer?
        show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
        show_settings = false, -- Show LLM settings at the top of the chat buffer?
        show_token_count = true, -- Show the token count for each response?
        show_tools_processing = true, -- Show the loading message when tools are being executed?
        start_in_insert_mode = false, -- Open the chat buffer in insert mode?
      },
    },
  },
}
