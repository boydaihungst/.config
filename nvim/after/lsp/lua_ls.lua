return {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        -- disable unused diagnostics
        disable = { "missing-fields", "incomplete-signature-doc", "unused-function" },
        -- Setting to a negative number will disable automatic workspace diagnostics.
        workspaceDelay = -1,
        workspaceEvent = "None",
        groupFileStatus = {
          workspace = "None",
          opened = "Opened",
        },
      },
      codeLens = {
        enable = false,
      },
      workspace = {
        checkThirdParty = false,
        maxPreload = 200,
        preloadFileSize = 50,
        -- library = vim.api.nvim_get_runtime_file("", true),
        ignoreDir = {
          ".git",
          "node_modules",
          "dist",
          "build",
        },
      },
    },
  },
}
