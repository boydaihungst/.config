return {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        -- disable unused diagnostics
        disable = { "missing-fields", "incomplete-signature-doc", "unused-function" },
      },
      codeLens = {
        enable = false,
      },
    },
  },
}
