local prefix = "<Leader>A"

---@type LazySpec
return {
  "ravitemer/mcphub.nvim",
  optional = true,
  enabled = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "Joakker/lua-json5", build = "./install.sh" },
  },
  build = "npm -g install mcp-hub@latest",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = {} end
        opts.mappings.n = opts.mappings.n or {}
        opts.mappings.v = opts.mappings.v or {}
        opts.mappings.n[prefix .. "m"] = { "<cmd>MCPHub<cr>", desc = "Toggle MCPHub" }
        opts.mappings.v[prefix .. "m"] = { "<cmd>MCPHub<cr>", desc = "Toggle MCPHub" }
      end,
    },
    {
      "olimorris/codecompanion.nvim",
      optional = true,
      opts = {
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              -- MCP Tools
              make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
              show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
              add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
              show_result_in_chat = true, -- Show tool results directly in chat buffer
              format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
              -- MCP Resources
              make_vars = true, -- Convert MCP resources to #variables for prompts
              -- MCP Prompts
              make_slash_commands = true, -- Add MCP prompts as /slash commands
            },
          },
        },
      },
    },
  },
  opts = {
    -- port = 37373,
    -- cmd = os.getenv "HOME" .. "/.yarn/bin/mcp-hub",
    config = vim.fn.expand "~/.vscode/mcp.json",
    json_decode = "json5",
    global_env = {
      -- Array-style: uses os.getenv("VAR")
      "DBUS_SESSION_BUS_ADDRESS",
      -- Hash-style: explicit value
      "GITHUB_PERSONAL_ACCESS_TOKEN",
      "GEMINI_API_KEY",
    },
    workspace = {
      enabled = true, -- Default: true
      look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" },
      reload_on_dir_changed = true, -- Auto-switch on directory change
      port_range = { min = 40000, max = 41000 }, -- Port range for workspace hubs
      -- get_port = nil, -- Optional function for custom port assignment
    },
    auto_approve = function(params)
      -- Auto-approve GitHub issue reading
      if params.server_name == "github" and params.tool_name == "get_issue" then
        return true -- Auto approve
      end

      -- Block access to private repos
      if params.arguments.repo == "private" then
        return "You can't access my private repo" -- Error message
      end

      -- Auto-approve safe file operations in current project
      if
        params.tool_name == "read_file"
        or params.tool_name == "find_files"
        or params.tool_name == "list_directory"
      then
        local path = params.arguments.path or ""
        if path:match("^" .. vim.fn.getcwd()) then
          return true -- Auto approve
        end
      end

      if params.tool_name == "read_multiple_files" then
        local paths = params.arguments.paths or {}
        for _, path in ipairs(paths) do
          if path:match("^" .. vim.fn.getcwd()) then
            return true -- Auto approve
          end
        end
      end

      -- Block access to sudo commands
      if params.tool_name == "execute_command" then
        if params.command:match("^" .. "sudo") then return "You can't use sudo" end
      end

      -- Check if tool is configured for auto-approval in servers.json
      if params.is_auto_approved_in_server then
        return true -- Respect servers.json configuration
      end

      return false -- Show confirmation prompt
    end,
    log = {
      level = vim.log.levels.ERROR,
      to_file = false,
      file_path = nil,
      prefix = "MCPHub",
    },
  },
}
