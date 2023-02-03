return {
	setup = function()
		local dap = require("dap")
		local adapter_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/")
		require("dap-vscode-js").setup({
			node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
			debugger_path = adapter_path .. "js-debug-adapter/out/src/nodeDebug.js",
			debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
			-- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
			-- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
			-- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
		})

		-- custom adapter for running tasks before starting debug
		local custom_adapter = "pwa-node-custom"
		dap.adapters[custom_adapter] = function(cb, config)
			if config.preLaunchTask then
				local async = require("plenary.async")
				local notify = require("notify").async

				async.run(function()
					---@diagnostic disable-next-line: missing-parameter
					notify("Running [" .. config.preLaunchTask .. "]").events.close()
				end, function()
					vim.fn.system(config.preLaunchTask)
					config.type = "pwa-node"
					dap.run(config)
				end)
			end
		end

		-- language config
		for _, language in ipairs({ "typescript", "javascript", "vue" }) do
			dap.configurations[language] = {
				{
					name = "Launch",
					type = "pwa-node",
					request = "launch",
					program = "${file}",
					rootPath = "${workspaceFolder}",
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					skipFiles = { "<node_internals>/**" },
					protocol = "inspector",
					console = "integratedTerminal",
				},
				{
					type = "pwa-node",
					request = "launch",
					name = "Debug yarn",
					trace = true, -- include debugger info
					runtimeExecutable = "yarn",
					runtimeArgs = {
						"dev",
					},
					rootPath = "${workspaceFolder}",
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					internalConsoleOptions = "neverOpen",
				},
				{
					name = "Attach to node process",
					type = "pwa-node",
					request = "attach",
					rootPath = "${workspaceFolder}",
					processId = require("dap.utils").pick_process,
				},
				{
					name = "Debug Main Process (Electron)",
					type = "pwa-node",
					request = "launch",
					program = "${workspaceFolder}/node_modules/.bin/electron",
					args = {
						"${workspaceFolder}/dist/index.js",
					},
					outFiles = {
						"${workspaceFolder}/dist/*.js",
					},
					resolveSourceMapLocations = {
						"${workspaceFolder}/dist/**/*.js",
						"${workspaceFolder}/dist/*.js",
					},
					rootPath = "${workspaceFolder}",
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					skipFiles = { "<node_internals>/**" },
					protocol = "inspector",
					console = "integratedTerminal",
				},
				{
					name = "Compile & Debug Main Process (Electron)",
					type = custom_adapter,
					request = "launch",
					preLaunchTask = "npm run build-ts",
					program = "${workspaceFolder}/node_modules/.bin/electron",
					args = {
						"${workspaceFolder}/dist/index.js",
					},
					outFiles = {
						"${workspaceFolder}/dist/*.js",
					},
					resolveSourceMapLocations = {
						"${workspaceFolder}/dist/**/*.js",
						"${workspaceFolder}/dist/*.js",
					},
					rootPath = "${workspaceFolder}",
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					skipFiles = { "<node_internals>/**" },
					protocol = "inspector",
					console = "integratedTerminal",
				},
			}
		end
	end,
}
