-- Language-based supported plugins should add to this file

on_event("BufRead~Cargo.toml", function()
  add { "https://github.com/Saecki/crates.nvim" }
  require("crates").setup {
    completion = {
      crates = { enabled = true },
    },
    lsp = {
      enabled = true,
      on_attach = function(client, bufnr) end,
      actions = true,
      completion = true,
      hover = true,
    },
  }
end)

-- This plugin already has lazy-loading
later(function()
  -- Project-local config via rust-analyzer.json file
  add { { src = "https://github.com/mrcjkb/rustaceanvim", version = vim.version.range "9.x" } }

  local adapter
  local codelldb_installed = pcall(function() return require("mason-registry").get_package "codelldb" end)
  local cfg = require "rustaceanvim.config"
  if codelldb_installed then
    local codelldb_path = vim.fn.exepath "codelldb"
    local this_os = vim.uv.os_uname().sysname

    local liblldb_path = vim.fn.expand "$MASON/share/lldb"
    if vim.fn.isdirectory(liblldb_path) == 0 then liblldb_path = vim.fn.expand "$MASON/opt/lldb" end
    if vim.fn.isdirectory(liblldb_path) == 0 then return vim.notify("Could not find lldb lib", vim.log.levels.ERROR) end
    -- The path in windows is different
    if this_os:find "Windows" then
      liblldb_path = liblldb_path .. "\\bin\\lldb.dll"
    else
      -- The liblldb extension is .so for linux and .dylib for macOS
      liblldb_path = liblldb_path .. "/lib/liblldb" .. (this_os == "Linux" and ".so" or ".dylib")
    end
    adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
  else
    adapter = cfg.get_codelldb_adapter()
  end

  local rust_analyzer_lsp_config = vim.lsp.config["rust_analyzer"] or {}
  rust_analyzer_lsp_config.root_dir = nil
  local server = {
    ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
    settings = function(project_root, default_settings)
      local rust_avalyzer_lsp_config_setting = rust_analyzer_lsp_config.settings or {}

      local merge_table = vim.tbl_deep_extend("force", default_settings or {}, rust_avalyzer_lsp_config_setting)

      -- Merge the settings from `rustaceanvim` first.
      local ra = require "rustaceanvim.config.server"
      local settings = ra.load_rust_analyzer_settings(project_root, {
        settings_file_pattern = "rust-analyzer.json",
        default_settings = merge_table,
      })

      -- Merge the settings again from `codesettings` if available. This is
      -- the recommended way of sharing project-local settings with VSCode
      -- in newer versions of `rustaceanvim`.
      local codesettings_avail, codesettings = pcall(require, "codesettings")
      if codesettings_avail then
        settings = codesettings.with_local_settings("rust-analyzer", { settings = settings }).settings
      end
      return settings
    end,
  }
  local final_server = vim.tbl_deep_extend("force", rust_analyzer_lsp_config, server)
  local opts = {
    server = final_server,
    dap = { adapter = adapter, load_rust_types = true },
    tools = { enable_clippy = false },
  }
  vim.g.rustaceanvim = vim.tbl_deep_extend("force", opts, vim.g.rustaceanvim or {
    -- https://github.com/mrcjkb/rustaceanvim#gear-advanced-configuration
  })
end)
