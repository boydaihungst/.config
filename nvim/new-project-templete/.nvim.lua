local prev_lsp_configs = {}
local project_root = vim.fn.getcwd()
local augroup_id = vim.api.nvim_create_augroup("Proj_" .. project_root, { clear = true })

-- list of lsp server settings apply to this project
local lsp_settings_for_this_workspace = {
  sqls = {
    -- Only settings is applied to sqls server, other options are ignored
    settings = {
      sqls = {
        connections = {
          {
            alias = "postgres sample",
            driver = "postgresql",
            dataSourceName = "postgresql://testuser:testpw123@localhost:5432/example",
          },
        },
      },
    },
  },
}

-- Add any thing which only use in this project to this callback, make sure it use buffer-local option
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup_id,
  pattern = project_root .. "/**",
  callback = function(args)
    -- Buffer-local command
    vim.api.nvim_buf_create_user_command(args.buf, "Build", function()
      print "Building project..."
      vim.cmd "split | term dotnet build"
    end, { desc = "Run project build" })

    -- Buffer-local options
    vim.bo[args.buf].shiftwidth = 4
    vim.bo[args.buf].tabstop = 4
    vim.bo[args.buf].expandtab = true
  end,
})

local function update_lsp_settings(lsp_servers_configs, is_restoring)
  for lsp_server, new_config in pairs(lsp_servers_configs) do
    local clients = vim.lsp.get_clients { name = lsp_server }

    for _, client in ipairs(clients) do
      if not is_restoring then
        -- Deep copy the current settings so we have a clean snapshot
        prev_lsp_configs[lsp_server] = vim.deepcopy(client.config.settings)
        client.config.settings = vim.tbl_deep_extend("force", client.config.settings, new_config.settings or {})
      else
        client.config.settings = new_config.settings or {}
      end

      -- Trigger update settings to lsp server
      client:notify("workspace/didChangeConfiguration", {
        settings = client.config.settings,
      })
    end
  end
end

-- 1. Try to apply immediately to any ALREADY running clients
update_lsp_settings(lsp_settings_for_this_workspace)

-- 2. Watch for NEW clients attaching (for those slow-starting servers)
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup_id, -- Uses the same group for easy cleanup
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and lsp_settings_for_this_workspace[client.name] then
      -- Apply settings only for the relevant server
      local config = { [client.name] = lsp_settings_for_this_workspace[client.name] }
      update_lsp_settings(config)
    end
  end,
})

-- Return this function to restore state of prev changed lsp servers
return function()
  -- 1. Restore LSP using the snapshot
  update_lsp_settings(prev_lsp_configs, true)

  -- 2. Kill all autocommands for this project at once
  pcall(vim.api.nvim_del_augroup_by_id, augroup_id)
end
