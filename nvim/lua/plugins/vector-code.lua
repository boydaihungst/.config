return {
  "Davidyz/VectorCode",
  build = function()
    if not vim.fn.executable "uv" then error "The VectorCode pack requires uv installed" end
    vim.system({ "uv", "tool", "install", "vectorcode[lsp,mcp]" }, { text = true }, function(obj)
      if obj.code == 0 then
        vim.notify("Installed successfully: vectorcode\n" .. obj.stdout)
      else
        vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
      end
    end)
    vim.system({ "uv", "tool", "upgrade", "vectorcode[lsp,mcp]" }, { text = true }, function(obj)
      if obj.code == 0 then
        vim.notify("Updated successfully: vectorcode\n" .. obj.stdout)
      else
        vim.notify("Error:\n" .. obj.stderr, vim.log.levels.ERROR)
      end
    end)
  end,
  version = "*", -- optional, depending on whether you're on nightly or release
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "VectorCode", -- if you're lazy-loading VectorCode
  specs = {
    {
      "olimorris/codecompanion.nvim",
      optional = true,
      opts = {
        extensions = {
          vectorcode = {
            opts = {
              -- prompt_library = {
              --   {
              -- ["Neovim Tutor"] = {
              --   -- this is for demonstration only.
              --   -- "Neovim Tutor" is shipped with this plugin
              --   -- and you don't need to add it in the config
              --   -- unless you're not happy with the defaults.
              --   project_root = vim.env.VIMRUNTIME,
              --   file_patterns = { "lua/**/*.lua", "doc/**/*.txt" },
              --   -- system_prompt = ...,
              --   -- user_prompt = ...,
              -- },
              -- },
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
          },
        },
      },
    },
  },
}
