---@type vim.lsp.Config
return {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        extraEnv = { CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev" },
        extraArgs = { "--profile", "rust-analyzer" },
      },
      files = {
        exclude = {
          ".direnv",
          ".git",
          "target",
        },
      },
      check = {
        -- command = "clippy",
        -- extraArgs = {
        --   "--no-deps",
        -- },

        -- Use cargo check instead of cargo clippy. Better performance in large projects
        check = { command = "check", extraArgs = {} },
      },
    },
  },
}
