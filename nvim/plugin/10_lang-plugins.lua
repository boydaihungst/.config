-- Language-based supported plugins should add to this file

on_filetype({ "sql", "mysql" }, function()
  add { "https://github.com/nanotee/sqls.nvim" }

  --Remember to disable sqls lsp auto start in 05_lsp-servers.lua
  vim.lsp.config("sqls", {})
  vim.lsp.enable "sqls"
end)

on_filetype({
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
  "tsx",
  "vue",
  "svelte",
  "astro",
}, function()
  add {
    "https://github.com/dmmulroy/ts-error-translator.nvim",
  }
  require("ts-error-translator").setup {}
end)

-- Schema for json, yaml, etc.
on_event(
  { "BufReadPre" },
  { "*.yaml", "*.yml", ",*.json", "*.jsonc" },
  function()
    add {
      "https://github.com/b0o/schemastore.nvim",
    }
  end
)

on_filetype("yaml.ansible", function()
  add {
    "https://github.com/pearofducks/ansible-vim",
  }
end)

on_event("BufRead~package.json", function()
  add {
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/vuki656/package-info.nvim",
  }
  require("package-info").setup {
    highlights = {
      up_to_date = {
        fg = "#3C4048",
        ctermfg = 237,
      },
      outdated = {
        fg = "#d19a66",
        bold = true,
      },
      invalid = {
        fg = "#ee4b2b",
        bold = true,
      },
    },
    icons = {
      enable = true,
      style = {
        up_to_date = " ", -- Icon for up to date dependencies
        outdated = " ", -- Icon for outdated dependencies
        invalid = " ", -- Icon for invalid dependencies
      },
    },
    notifications = false, -- Whether to display notifications when running commands
    autostart = true, -- Whether to autostart when `package.json`  opened
    hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
    hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
    -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
    -- The plugin will try to auto-detect the package manager based on
    -- `yarn.lock` or `package-lock.json`. If none are found it will use the
    -- provided one, if nothing  provided it will use `yarn`
    package_manager = "npm",
  }
end)

-- Add keymaps for any lsp server that support inline completion
later(function()
  if vim.lsp.inline_completion.is_enabled() then
    Config.new_autocmd("LspAttach", nil, function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client:supports_method "textDocument/inlineCompletion" then
        vim.keymap.set(
          "i",
          "<C-l>",
          function() vim.lsp.inline_completion.get() end,
          { desc = "Accept inline completion" }
        )

        -- Switch to previous inline completion
        vim.keymap.set(
          "i",
          "<C-[>",
          function() vim.lsp.inline_completion.select { wrap = true, count = -1 } end,
          { desc = "Switch to previous inline completion" }
        )

        -- Switch to next inline completion
        vim.keymap.set(
          "i",
          "<C-]>",
          function() vim.lsp.inline_completion.select { wrap = true, count = 1 } end,
          { desc = "Switch to next inline completion" }
        )
        vim.api.nvim_del_augroup_by_name "nvim-inline-completion"
      end
    end, "Set keymaps for when a lsp support ", "nvim-inline-completion")
  end
end)

-- Extra command for vtsls
later(function()
  Config.new_autocmd("LspAttach", nil, function(args)
    if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "vtsls" then
      add { "https://github.com/yioneko/nvim-vtsls" }
      require("vtsls")._on_attach(args.data.client_id, args.buf)
      vim.api.nvim_del_augroup_by_name "nvim_vtsls"
    end
  end, "Load nvim-vtsls with vtsls", "nvim_vtsls")
end)

-- :TSC command to check type for typescript
on_filetype(
  { "typescript", "javascript", "typescriptreact", "javascriptreact", "tsx", "vue", "svelte", "astro" },
  function()
    add { "https://github.com/dmmulroy/tsc.nvim" }
    require("tsc").setup {}
  end
)

later(function()
  local uname = (vim.uv or vim.loop).os_uname()
  local is_linux_arm = uname.sysname == "Linux" and (uname.machine == "aarch64" or vim.startswith(uname.machine, "arm"))

  Config.new_autocmd("LspAttach", nil, function(args)
    if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
      add { "https://github.com/p00f/clangd_extensions.nvim" }
      require "clangd_extensions"
      vim.keymap.set(
        "n",
        "<Leader>lw",
        "<Cmd>ClangdSwitchSourceHeader<CR>",
        { desc = "Switch source/header file", buf = args.buf }
      )
      vim.api.nvim_del_augroup_by_name "clangd_extensions"
    end
  end, "Load clangd_extensions and add keymaps with clangd", "clangd_extensions")

  if is_linux_arm then
    -- Force enable clangd for arm arch. Because we don't install clangd from mason
    -- We use built-in clangd arm instead
    vim.lsp.enable "clangd"
  end
end)

on_filetype({ "c", "cpp", "objc", "objcpp", "cuda", "proto" }, function()
  add {
    "https://github.com/Civitasv/cmake-tools.nvim",
  }
  require("cmake-tools").setup {}
end)

on_filetype("python", function()
  if not (vim.fn.executable "fd" == 1 or vim.fn.executable "fdfind" == 1 or vim.fn.executable "fd-find" == 1) then
    add {
      "https://github.com/linux-cultist/venv-selector.nvim",
    }
    require("venv-selector").setup {}
  end

  add {
    "https://github.com/mfussenegger/nvim-dap-python",
  }
  local path = vim.fn.exepath "debugpy-adapter"
  if path == "" then path = vim.fn.exepath "uv" end
  if path == "" then path = vim.fn.exepath "python" end
  require("dap-python").setup(path, {})
end)

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

on_filetype("java", function()
  add {
    "https://github.com/mfussenegger/nvim-jdtls",
  }

  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = vim.fn.stdpath "data" .. "/site/java/workspace-root/" .. project_name
  vim.fn.mkdir(workspace_dir, "p")

  if not (vim.fn.has "mac" == 1 or vim.fn.has "unix" == 1 or vim.fn.has "win32" == 1) then
    vim.notify("jdtls: Could not detect valid OS", vim.log.levels.ERROR)
  end

  local opts = {
    cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-javaagent:" .. vim.fn.expand "$MASON/share/jdtls/lombok.jar",
      "-Xms1g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",
      "-jar",
      vim.fn.expand "$MASON/share/jdtls/plugins/org.eclipse.equinox.launcher.jar",
      "-configuration",
      vim.fn.expand "$MASON/share/jdtls/config",
      "-data",
      workspace_dir,
    },
    root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }),
    settings = {
      -- format = {
      --   enabled = true,
      --   settings = { -- you can use your preferred format style
      --     url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
      --     profile = "GoogleStyle",
      --   },
      -- },
      java = {
        eclipse = { downloadSources = true },
        configuration = {
          -- NOTE: Lower version of jdk if you faced any error, currently openjdk-25 won't work, but openjdk-21 works
          -- runtimes = {
          --   {
          --     name = "OpenJDK-21",
          --     path = "/opt/openjdk-bin-21/",
          --   },
          -- },
          updateBuildConfiguration = "interactive",
        },
        maven = { downloadSources = true },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        inlayHints = { parameterNames = { enabled = "all" } },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
      },
    },
    init_options = {
      bundles = {
        vim.fn.expand "$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
        -- unpack remaining bundles
        (table.unpack or unpack)(vim.split(vim.fn.glob "$MASON/share/java-test/*.jar", "\n", {})),
      },
    },
    handlers = {
      ["$/progress"] = function() end, -- disable progress updates.
    },
    filetypes = { "java" },
    on_attach = function(client, bufnr) require("jdtls").setup_dap { hotcodereplace = "auto" } end,
  }
  if opts.root_dir and opts.root_dir ~= "" then
    require("jdtls").start_or_attach(opts)
  else
    vim.notify("jdtls: root_dir not found. Please specify a root marker", vim.log.levels.ERROR)
  end

  -- create autocmd to load main class configs on LspAttach.
  -- This ensures that the LSP is fully attached.
  -- See https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
  Config.new_autocmd("LspAttach", "*.java", function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- ensure that only the jdtls client is activated
    if client and client.name == "jdtls" then require("jdtls.dap").setup_dap_main_class_configs() end
  end)
end)
