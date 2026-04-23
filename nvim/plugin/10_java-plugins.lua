-- Language-based supported plugins should add to this file

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
