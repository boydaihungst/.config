local prefix = "<Leader>A"

---@type LazySpec
return {
  "olimorris/codecompanion.nvim",
  optional = true,
  keys = { prefix },
  cmd = {
    "CodeCompanion",
    "CodeCompanionHistory",
    "CodeCompanionSummaries",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCLI",
    "CodeCompanionCmd",
  },
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

          auto_generate_title = true,
          ---On exiting and entering neovim, loads the last chat on opening chat
          continue_last_chat = false,
          ---When chat is cleared with `gx` delete the chat from history
          delete_on_clearing_chat = false,
          ---Directory path to save the chats
          dir_to_save = vim.fn.stdpath "data" .. "/codecompanion-history",
          title_generation_opts = {
            adapter = "nvidia",
            model = "qwen/qwen3.5-397b-a17b",
          },

          -- Summary system
          summary = {
            -- Keymap to generate summary for current chat (default: "gcs")
            create_summary_keymap = "gcs",
            -- Keymap to browse summaries (default: "gbs")
            browse_summaries_keymap = "gbs",

            generation_opts = {
              adapter = "nvidia",
              model = "qwen/qwen3.5-397b-a17b",
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
        gemini_cli = function()
          return require("codecompanion.adapters").extend("gemini_cli", {
            commands = {
              flash = {
                "gemini",
                "--experimental-acp",
                -- "-m",
                -- "gemini-3-pro-preview",
              },
              pro = {
                "gemini",
                "--experimental-acp",
                -- "-m",
                -- "gemini-3-pro-preview",
              },
            },
            defaults = {
              auth_method = "oauth-personal",
              -- mcpServers = mcpServers,
              timeout = 20000, -- 20 seconds
            },
            env = {
              -- api_key = "GEMINI_API_KEY",
            },
          })
        end,
      },
      http = {
        nvidia = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "nvidia",
            formatted_name = "Nvidia",
            roles = {
              llm = "assistant",
              user = "user",
              tool = "tool",
            },
            env = {
              url = "https://integrate.api.nvidia.com",
              api_key = "NVIDIA_API_KEY",
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            schema = {
              model = {
                default = "qwen/qwen3.5-397b-a17b",
              },
              -- temperature = {
              --   order = 2,
              --   mapping = "parameters",
              --   type = "number",
              --   optional = true,
              --   default = 0.6,
              --   desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
              --   validate = function(n) return n >= 0 and n <= 1, "Must be between 0 and 1" end,
              -- },
              -- top_p = {
              --   order = 3,
              --   mapping = "parameters",
              --   type = "number",
              --   optional = true,
              --   default = 0.95,
              --   desc = "An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. We generally recommend altering this or temperature but not both.",
              --   validate = function(n) return n >= 0 and n <= 1, "Must be between 0 and 1" end,
              -- },
              -- top_k = {
              --   order = 4,
              --   mapping = "parameters",
              --   type = "number",
              --   optional = true,
              --   default = 20,
              --   desc = "An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. We generally recommend altering this or temperature but not both.",
              -- },
              -- presence_penalty = {
              --   order = 5,
              --   mapping = "parameters",
              --   type = "number",
              --   optional = true,
              --   default = 0,
              --   desc = "Number between 0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.",
              --   validate = function(n) return n >= 0 and n <= 2, "Must be between 0 and 2" end,
              -- },
              -- repetition_penalty = {
              --   order = 6,
              --   mapping = "parameters",
              --   type = "number",
              --   optional = true,
              --   default = 1,
              --   desc = "Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.",
              --   validate = function(n) return n >= -2 and n <= 2, "Must be between -2 and 2" end,
              -- },
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            schema = {
              model = {
                default = "gemini-3-pro-preview",
              },
            },
          })
        end,
      },
    },
    interactions = {
      chat = {
        adapter = "nvidia",
        auto_scroll = false,
        icons = {
          chat_context = "📎️",
        },
        fold_context = true,
        variables = {
          ["buffer"] = {
            opts = {
              -- Always sync the buffer by sharing its "diff"
              -- Or choose "all" to share the entire buffer
              default_params = "diff",
            },
          },
        },
        default_rules = "default",
      },
      inline = {
        adapter = "nvidia",
        default_rules = "default",
      },
      cmd = {
        adapter = "nvidia",
      },
    },
    display = {
      chat = {
        intro_message = "Welcome to CodeCompanion ✨!\n Press ? for options",
        separator = "─", -- The separator between the different messages in the chat buffer
        show_context = true, -- Show context (from slash commands and variables) in the chat buffer?
        show_header_separator = true, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
        show_settings = false, -- Show LLM settings at the top of the chat buffer?
        show_token_count = true, -- Show the token count for each response?
        show_tools_processing = true, -- Show the loading message when tools are being executed?
        start_in_insert_mode = false, -- Open the chat buffer in insert mode?
      },
    },
  },
}
