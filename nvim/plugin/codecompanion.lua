later(function()
  if vim.fn.executable "uv" == 1 then
    local function install_vector_deps(init)
      if vim.fn.executable "vectorcode-mcp-server" == 0 or vim.fn.executable "vectorcode-mcp-server" == 0 then
        local result = vim.system({ "uv", "tool", "install", "vectorcode[lsp,mcp]" }, { text = true }):wait()
        if result.code ~= 0 then vim.notify("Error:\n" .. result.stderr, vim.log.levels.ERROR) end
      elseif not init then
        local result = vim.system({ "uv", "tool", "upgrade", "vectorcode[lsp,mcp]" }, { text = true }):wait()
        if result.code ~= 0 then vim.notify("Error:\n" .. result.stderr, vim.log.levels.ERROR) end
      end
    end

    vim.pack.on_packchanged(
      "VectorCode",
      { "update" },
      function() install_vector_deps() end,
      "VectorCode install/update"
    )
    add {
      "https://github.com/Davidyz/VectorCode",
    }
    install_vector_deps(true)
  else
    if vim.pack.is_available "VectorCode" then vim.pack.del { "VectorCode" } end
  end

  add {
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/ravitemer/codecompanion-history.nvim",
    "https://github.com/franco-ruggeri/codecompanion-spinner.nvim",
    "https://github.com/olimorris/codecompanion.nvim",
  }
  local opts = {
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
          picker = vim.pack.is_available "telescope.nvim" and "telescope"
            or vim.pack.is_available "fzf-lua" and "fzf-lua"
            or vim.pack.is_available "snacks.nvim" and "snacks"
            or "default", --- ("telescope", "snacks", "fzf-lua", or "default")
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
        },
      },
      spinner = {},
    },
    language = "English",
    adapters = {
      acp = {
        gemini_cli = function()
          return require("codecompanion.adapters").extend("gemini_cli", {
            defaults = {
              auth_method = "oauth-personal",
              -- mcpServers = mcpServers,
              timeout = 20000, -- 20 seconds
            },
            env = {
              GEMINI_API_KEY = (function()
                if vim.env.GEMINI_API_KEY then return "GEMINI_API_KEY" end
                if vim.fn.executable "pass" == 1 then
                  local encrypted_file = vim.fn.expand "~/.password-store/llm/GEMINI_API_KEY.gpg"
                  if vim.fn.filereadable(encrypted_file) == 1 then return "cmd: pass llm/GEMINI_API_KEY" end
                end
                return "GEMINI_API_KEY"
              end)(),
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
              api_key = (function()
                if vim.env.NVIDIA_API_KEY then return "NVIDIA_API_KEY" end
                if vim.fn.executable "pass" == 1 then
                  local encrypted_file = vim.fn.expand "~/.password-store/llm/NVIDIA_API_KEY.gpg"
                  if vim.fn.filereadable(encrypted_file) == 1 then return "cmd: pass llm/NVIDIA_API_KEY" end
                end
                return "NVIDIA_API_KEY"
              end)(),
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            schema = {
              model = {
                default = "qwen/qwen3.5-397b-a17b",
              },
              temperature = {
                order = 2,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0.6,
                description = "Temperature",
                validate = function(n) return n >= 0 and n <= 1, "Must be between 0 and 1" end,
              },
              top_p = {
                order = 3,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0.95,
                description = "Top-p sampling",
                validate = function(n) return n >= 0 and n <= 1, "Must be between 0 and 1" end,
              },
              top_k = {
                order = 4,
                mapping = "parameters",
                type = "number",
                optional = true,
                description = "Top-k sampling",
                default = 20,
              },
              presence_penalty = {
                order = 5,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0,
                description = "Presence penalty",
                validate = function(n) return n >= 0 and n <= 2, "Must be between 0 and 2" end,
              },
              repetition_penalty = {
                order = 6,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 1,
                description = "Repetition penalty",
                validate = function(n) return n >= -2 and n <= 2, "Must be between -2 and 2" end,
              },
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
  }
  if vim.fn.executable "vectorcode" == 1 then
    opts.extensions = opts.extensions or {}
    opts.extensions.vectorcode = {
      opts = {
        -- prompt_library = {
        -- },
        tool_group = {
          -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
          enabled = true,
          -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
          -- if you use @vectorcode_vectorise, it'll be very handy to include
          -- `file_search` here.
          extras = {},
          collapse = false, -- whether the individual tools should be shown in the chat
        },
        tool_opts = {
          ls = {},
          vectorise = {},
          query = {
            max_num = { chunk = -1, document = -1 },
            default_num = { chunk = 50, document = 10 },
            include_stderr = false,
            use_lsp = false,
            no_duplicate = true,
            chunk_mode = false,
            summarise = {
              enabled = false,
              -- adapter = "gemini_cli",
              query_augmented = true,
            },
          },
        },
        on_setup = {
          update = true, -- set to true to enable update when `setup` is called.
          -- lsp = false,
        },
      },
    }
    if vim.tbl_get(opts, "extensions", "history", "opts") then
      opts.extensions.history.opts.memory = {
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
      }
    end
  end
  require("codecompanion").setup(opts)
  local prefix = "<Leader>A" -- or whatever your prefix variable is set to

  if wk then
    wk.add {
      { prefix, group = Config.get_custom_icon("CodeCompanion", 1, true) .. "CodeCompanion", mode = { "n", "v" } },
    }
  end

  -- Normal Mode Mappings
  vim.keymap.set("n", prefix .. "h", "<cmd>CodeCompanionHistory<cr>", { desc = "Open history" })
  vim.keymap.set("n", prefix .. "c", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle chat" })
  vim.keymap.set("n", prefix .. "p", "<cmd>CodeCompanionActions<cr>", { desc = "Open action palette" })
  vim.keymap.set("n", prefix .. "q", "<cmd>CodeCompanion<cr>", { desc = "Open inline assistant" })

  -- Visual Mode Mappings
  vim.keymap.set("v", prefix .. "s", "<cmd>CodeCompanionSummaries<cr>", { desc = "Browse summaries" })
  vim.keymap.set("v", prefix .. "a", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to chat" })
  vim.keymap.set("v", prefix .. "c", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle chat" })
  vim.keymap.set("v", prefix .. "p", "<cmd>CodeCompanionActions<cr>", { desc = "Open action palette" })
  vim.keymap.set("v", prefix .. "q", "<cmd>CodeCompanion<cr>", { desc = "Open inline assistant" })
end)
