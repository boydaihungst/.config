later(function()
  add {
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/jay-babu/mason-nvim-dap.nvim",
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/theHamsta/nvim-dap-virtual-text",
    "https://github.com/rcarriga/nvim-dap-ui",
    "https://github.com/Weissle/persistent-breakpoints.nvim",
    "https://github.com/LiadOz/nvim-dap-repl-highlights",
    --deps
    "https://github.com/nvim-treesitter/nvim-treesitter", -- dep of nvim-dap-repl-highlights
    "https://github.com/nvim-neotest/nvim-nio",
  }

  local dap = require "dap"
  local dapui = require "dapui"
  local dap_persist_bp = require "persistent-breakpoints"
  -- NOTE: Call this any where after is ok
  require("mason-nvim-dap").setup {
    automatic_installation = true,
    handlers = {
      -- function(config)
      --   -- all sources with no handler get passed here
      --   -- Keep original functionality
      --   require("mason-nvim-dap").default_setup(config)
      -- end,
      -- firefox = function(config)
      --   config.adapters = {
      --     {
      --       name = "Firefox: Debug",
      --       type = "firefox",
      --       request = "launch",
      --       reAttach = true,
      --       url = "http://localhost:3000",
      --       webRoot = "${workspaceFolder}",
      --       firefoxExecutable = vim.fn.exepath "zen-browser",
      --     },
      --   }
      --   require("mason-nvim-dap").default_setup(config) -- don't forget this!
      -- end,
    },
    -- NOTE: Use mason-installer-tools
    -- ensure_installed = nil,
  }
  -- add highlight support for dap repl
  require("nvim-dap-repl-highlights").setup()
  -- NOTE: Call this any where after is ok
  require("nvim-dap-virtual-text").setup {
    virt_text_pos = "eol",
    virt_text_win_col = 70,
    commented = false,
    all_references = true,
    enabled_commands = true,
  }

  dap_persist_bp.setup {
    load_breakpoints_event = { "BufReadPost" },
  }
  -- NOTE: Call this any where after is ok
  -- Dap UI setup
  -- For more information, see |:help nvim-dap-ui|
  ---@diagnostic disable-next-line: missing-fields
  dapui.setup {
    -- Set icons to characters that are more likely to work in every terminal.
    --    Feel free to remove or use ones that you like more! :)
    --    Don't feel like these are good choices.
    icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
    ---@diagnostic disable-next-line: missing-fields
    controls = {
      icons = {
        -- pause = "⏸",
        -- play = "▶",
        -- step_into = "⏎",
        -- step_over = "⏭",
        -- step_out = "⏮",
        -- step_back = "b",
        -- run_last = "▶▶",
        -- terminate = "⏹",
        -- disconnect = "⏏",
      },
    },
  }

  dap.listeners.after.event_initialized["dapui_config"] = dapui.open
  dap.listeners.before.event_terminated["dapui_config"] = dapui.close
  dap.listeners.before.event_exited["dapui_config"] = dapui.close

  -- Add source to blink.cmp
  local blink_avail, blink = pcall(require, "blink.cmp")
  if blink_avail then
    for _, dap_ft in ipairs { "dap-repl", "dapui_watches", "dapui_hover" } do
      blink.add_filetype_source(dap_ft, "dap")
    end
    blink.add_source_provider("dap", {
      name = "dap",
      module = "blink.compat.source",
      score_offset = 100,
    })
  end

  if vim.pack.is_available "json5" then
    -- Use json5 to parse vscode json
    require("dap.ext.vscode").json_decode = require("json5").parse
  end

  --[[
 -   ╭─────────────────────────────────────────────────────────╮
 -   │                                                         │
 -   │                  Function Key Mappings                  │
 -   │                                                         │
 -   ╰─────────────────────────────────────────────────────────╯
]]

  vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "Debugger: Start" })
  vim.keymap.set("n", "<F17>", function() dap.terminate() end, { desc = "Debugger: Stop (Shift+F5)" })
  vim.keymap.set(
    "n",
    "<F21>",
    function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
    { desc = "Debugger: Conditional Breakpoint (Shift+F9)" }
  )
  vim.keymap.set("n", "<F29>", function() dap.restart_frame() end, { desc = "Debugger: Restart (Ctrl+F5)" })
  vim.keymap.set("n", "<F6>", function() dap.pause() end, { desc = "Debugger: Pause" })
  vim.keymap.set(
    "n",
    "<F9>",
    function() require("persistent-breakpoints.api").toggle_breakpoint() end,
    { desc = "Debugger: Toggle Breakpoint" }
  )
  vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "Debugger: Step Over" })
  vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "Debugger: Step Into" })
  vim.keymap.set("n", "<F23>", function() dap.step_out() end, { desc = "Debugger: Step Out (Shift+F11)" })

  -- Leader Mappings
  vim.keymap.set(
    "n",
    "<Leader>db",
    function() require("persistent-breakpoints.api").toggle_breakpoint() end,
    { desc = "Toggle Breakpoint (F9)" }
  )
  vim.keymap.set(
    "n",
    "<Leader>dB",
    function() require("persistent-breakpoints.api").clear_all_breakpoints() end,
    { desc = "Clear Breakpoints" }
  )
  vim.keymap.set("n", "<Leader>dc", function() dap.continue() end, { desc = "Start/Continue (F5)" })
  vim.keymap.set(
    "n",
    "<Leader>dC",
    function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
    { desc = "Conditional Breakpoint (S-F9)" }
  )
  vim.keymap.set("n", "<Leader>di", function() dap.step_into() end, { desc = "Step Into (F11)" })
  vim.keymap.set("n", "<Leader>do", function() dap.step_over() end, { desc = "Step Over (F10)" })
  vim.keymap.set("n", "<Leader>dO", function() dap.step_out() end, { desc = "Step Out (S-F11)" })
  vim.keymap.set("n", "<Leader>dq", function() dap.close() end, { desc = "Close Session" })
  vim.keymap.set("n", "<Leader>dQ", function() dap.terminate() end, { desc = "Terminate Session (S-F5)" })
  vim.keymap.set("n", "<Leader>dp", function() dap.pause() end, { desc = "Pause (F6)" })
  vim.keymap.set("n", "<Leader>dr", function() dap.restart_frame() end, { desc = "Restart (C-F5)" })
  vim.keymap.set("n", "<Leader>dR", function() dap.repl.toggle() end, { desc = "Toggle REPL" })
  vim.keymap.set("n", "<Leader>ds", function() dap.run_to_cursor() end, { desc = "Run To Cursor" })

  -- dap ui
  vim.keymap.set("n", "<Leader>dE", function()
    vim.ui.input({ prompt = "Expression: " }, function(expr)
      if expr then require("dapui").eval(expr, { enter = true }) end
    end)
  end, { desc = "Evaluate Input" })
  vim.keymap.set("v", "<Leader>dE", function() require("dapui").eval() end, { desc = "Evaluate Input" })
  vim.keymap.set("n", "<Leader>du", function() dapui.toggle() end, { desc = "Toggle Debugger UI" })
  vim.keymap.set("n", "<Leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "Debugger Hover" })

  --[[
 -   ╭─────────────────────────────────────────────────────────╮
 -   │                                                         │
 -   │              Diagnostics Breakpoint Signs               │
 -   │                                                         │
 -   ╰─────────────────────────────────────────────────────────╯
]]

  vim.fn.sign_define("DapBreakpoint", {
    text = Config.get_custom_icon "DapBreakpoint",
    texthl = "DiagnosticInfo",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextInfo",
  })
  vim.fn.sign_define("DapBreakpointCondition", {
    text = Config.get_custom_icon "DapBreakpointCondition",
    texthl = "DiagnosticInfo",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextInfo",
  })
  vim.fn.sign_define("DapBreakpointRejected", {
    text = Config.get_custom_icon "DapBreakpointRejected",
    texthl = "DiagnosticError",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextError",
  })
  vim.fn.sign_define("DapLogPoint", {
    text = Config.get_custom_icon "DapLogPoint",
    texthl = "DiagnosticInfo",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextInfo",
  })
  vim.fn.sign_define("DapStopped", {
    text = Config.get_custom_icon "DapStopped",
    texthl = "DiagnosticWarn",
    linehl = "",
    numhl = "TinyInlineDiagnosticVirtualTextWarn",
  })
end)
