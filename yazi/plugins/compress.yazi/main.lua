--- @since 25.5.31

local supported_encryption = {
	"%.zip$",
	"%.7z$",
	"%.rar$",
	"%.lha$",
}

-- Send error notification
local function notify_error(message, urgency)
	ya.notify({
		title = "Compress.yazi",
		content = message,
		level = urgency,
		timeout = 5,
	})
end

local function quote(path)
	local result = "'" .. string.gsub(tostring(path), "'", "'\\''") .. "'"
	return result
end

local function run_command(cmd, cwd)
	if cwd then
		-- escape path if it contains spaces
		if package.config:sub(1, 1) == "\\" then
			-- Windows
			cmd = string.format('cd /d "%s" && %s', cwd, cmd)
		else
			-- Unix-like
			cmd = string.format('cd "%s" && %s', cwd, cmd)
		end
	end

	local handle = io.popen(cmd .. " 2>&1")
	local output = handle:read("*a")
	local success, exit_type, exit_code = handle:close()
	return output, success, exit_type, exit_code
end

-- Check for windows
local is_windows = ya.target_family() == "windows"

local function pathJoin(...)
	-- Detect OS path separator ('\' for Windows, '/' for Unix)
	local separator = package.config:sub(1, 1)
	local parts = { ... }
	local filteredParts = {}
	-- Remove empty strings or nil values
	for _, part in ipairs(parts) do
		if part and part ~= "" then
			table.insert(filteredParts, part)
		end
	end
	-- Join the remaining parts with the separator
	local path = table.concat(filteredParts, separator)
	-- Normalize any double separators (e.g., "folder//file" → "folder/file")
	path = path:gsub(separator .. "+", separator)

	return path
end

local get_cwd = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

local selected_files = ya.sync(function()
	local tab, raw_urls = cx.active, {}
	for _, u in pairs(tab.selected) do
		raw_urls[#raw_urls + 1] = tostring(u)
	end
	return raw_urls
end)

local selected_or_hovered_files = ya.sync(function()
	local tab, raw_urls = cx.active, selected_files()
	if #raw_urls == 0 and tab.current.hovered then
		raw_urls[1] = tostring(tab.current.hovered.url)
	end
	return raw_urls
end)

local selected_or_hovered = function()
	local result = {}
	local paths = selected_or_hovered_files()

	for _, path in ipairs(paths) do
		local url = Url(path)
		local cha, err = fs.cha(url)

		if cha then
			local parent_path = tostring(url.parent)
			if not result[parent_path] then
				result[parent_path] = {}
			end
			table.insert(result[parent_path], quote(url.name))
		else
			notify_error(string.format("Failed to get metadata for %s: %s", path, err), "error")
			return
		end
	end
	return result
end

-- Check if archive command is available
local function is_command_available(cmd)
	local stat_cmd

	if is_windows then
		stat_cmd = string.format("where %s > nul 2>&1", cmd)
	else
		stat_cmd = string.format("command -v %s >/dev/null 2>&1", cmd)
	end

	local cmd_exists = os.execute(stat_cmd)
	return cmd_exists
end

-- Archive command list --> string
local function find_binary(cmd_list)
	local idx = 1
	local first_cmd, first_args
	for cmd, args in pairs(cmd_list) do
		if is_command_available(cmd) then
			return cmd, args
		end
		if idx == 1 then
			first_cmd, first_args = cmd, args
		end
		idx = idx + 1
	end
	return first_cmd, first_args -- Return first command as fallback
end

return {
	entry = function(_, job)
		-- Exit visual mode
		ya.emit("escape", { visual = true })
		local secure = job.args.secure
		local decrypt_password, input_pw_event
		local files_to_archive = selected_or_hovered()

		if files_to_archive == nil then
			return
		end

		-- Get input
		local output_name, event_name = ya.input({
			title = "Create archive:",
			pos = { "top-center", y = 3, w = 40 },
			-- TODO: remove this after next yazi released
			position = { "top-center", y = 3, w = 40 },
		})

		if event_name ~= 1 then
			return
		end
		if secure then
			decrypt_password, input_pw_event = ya.input({
				title = "Enter password:",
				obscure = true,
				pos = { "top-center", y = 3, w = 40 },
				-- TODO: remove this after next yazi released
				position = { "top-center", y = 3, w = 40 },
			})
			if input_pw_event ~= 1 then
				return
			end
			if utf8.len(decrypt_password) > 1 then
				local is_supported_encryption = false
				for _, pattern in pairs(supported_encryption) do
					if output_name:match(pattern) then
						is_supported_encryption = true
						break
					end
				end
				if not is_supported_encryption then
					notify_error("Unsupported encryption for file extention", "error")
					return
				end
			end
		end

		local output_fpath = pathJoin(get_cwd(), output_name)
		local output_furl = Url(output_fpath)
		local output_fcha, _ = fs.cha(output_furl)
		local output_fname_without_ext = output_furl.stem

		-- Use appropriate archive command
		local archive_commands = {
			--  ───────────────────────────────── zip ─────────────────────────────────
			["%.zip$"] = {
				archive_commands = {
					["7z"] = {
						"a",
						"-tzip",
						decrypt_password and ("-p" .. quote(decrypt_password)) or "",
						decrypt_password and "-mem=AES256" or "",
					},
					["7zz"] = {
						"a",
						"-tzip",
						decrypt_password and ("-p" .. quote(decrypt_password)) or "",
						decrypt_password and "-mem=AES256" or "",
					},
				},
			},
			--  ───────────────────────────────── 7z ──────────────────────────────
			["%.7z$"] = {
				archive_commands = {
					["7z"] = {
						"a",
						"-t7z",
						decrypt_password and ("-p" .. quote(decrypt_password)) or "",
						decrypt_password and "-mem=AES256" or "",
					},
					["7zz"] = {
						"a",
						"-t7z",
						decrypt_password and ("-p" .. quote(decrypt_password)) or "",
						decrypt_password and "-mem=AES256" or "",
					},
				},
			},
			--  ───────────────────────────────── rar ─────────────────────────────────
			["%.rar$"] = {
				archive_commands = {
					["rar"] = {
						"a",
						decrypt_password and ("-p" .. quote(decrypt_password)) or "",
					},
				},
			},
			--  ───────────────────────────────── lha ─────────────────────────────────
			["%.lha$"] = {
				archive_commands = {
					["lha"] = {
						"a",
						decrypt_password and ("-p" .. quote(decrypt_password)) or "",
					},
				},
			},
			--  ──────────────────────────────── tar.gz ─────────────────────────────
			["%.tar.gz$"] = {
				archive_commands = {
					["tar"] = {
						"rpf",
					},
				},
				compress_commands = {
					["gzip"] = {},
					["7z"] = {
						"a",
						"-tgzip",
						"-sdel",
						quote(output_name),
					},
				},
			},
			--  ───────────────────────────────── tar.xz ──────────────────────────────
			["%.tar.xz$"] = {
				archive_commands = {
					["tar"] = {
						"rpf",
					},
				},
				compress_commands = {
					["xz"] = {},
					["7z"] = {
						"a",
						"-txz",
						"-sdel",
						quote(output_name),
					},
				},
			},
			--  ──────────────────────────────── tar.bz2 ────────────────────────────────
			["%.tar.bz2$"] = {
				archive_commands = {
					["tar"] = {
						"rpf",
					},
				},
				compress_commands = {
					["bzip2"] = {},
					["7z"] = {
						"a",
						"-tbzip2",
						"-sdel",
						quote(output_name),
					},
				},
			},
			--  ──────────────────────────────── tar.zst ─────────────────────────────
			["%.tar.zst$"] = {
				archive_commands = {
					["tar"] = {
						"rpf",
					},
				},
				compress_commands = {
					["zstd"] = {
						"--rm",
					},
					["7z"] = {
						"a",
						"-tzstd",
						"-sdel",
						quote(output_name),
					},
				},
			},
			--  ───────────────────────────────── tar.lz4 ─────────────────────────────────
			["%.tar.lz4$"] = {
				archive_commands = {
					["tar"] = {
						"rpf",
					},
				},
				compress_commands = {
					["lz4"] = {
						"--rm",
					},
				},
			},
			--  ───────────────────────────────── tar ─────────────────────────────────
			["%.tar$"] = {
				archive_commands = {
					["tar"] = { "rpf" },
				},
			},
		}

		-- Match user input to archive command
		local archive_cmd, archive_args, compress_cmd, compress_args
		for pattern, cmd_pair in pairs(archive_commands) do
			if output_name:match(pattern) then
				archive_cmd, archive_args = find_binary(cmd_pair.archive_commands)
				compress_cmd, compress_args = find_binary(cmd_pair.compress_commands or {})
			end
		end

		-- Check if no archive command is available for the extention
		if not archive_cmd then
			notify_error("Unsupported file extention", "error")
			return
		end

		-- Exit if archive command is not available
		if not is_command_available(archive_cmd) then
			notify_error(string.format("%s not available", archive_cmd), "error")
			return
		end

		-- Exit if compress command is not available
		if compress_cmd and not is_command_available(compress_cmd) then
			notify_error(string.format("%s compression not available", compress_cmd), "error")
			return
		end

		local overwrite_answer = true
		local list_existed_files = {}
		if output_fcha then
			list_existed_files[#list_existed_files + 1] = ui.Span(output_name)
		end
		if compress_cmd then
			local output_fwithout_ext_cha = fs.cha(Url(pathJoin(get_cwd(), output_fname_without_ext)))
			if output_fwithout_ext_cha then
				list_existed_files[#list_existed_files + 1] = ui.Span(output_fname_without_ext)
			end
		end
		if #list_existed_files > 0 then
			overwrite_answer = ya.confirm({
				title = ui.Line("Create Archive File"),
				body = ui.Text({
					ui.Line(""),
					ui.Line("The following file is existed, overwrite?"):fg("yellow"),
					ui.Line(""),
					ui.Line({
						ui.Span(" "),
						table.unpack(list_existed_files),
					}):align(ui.Align.LEFT),
				})
					:align(ui.Align.LEFT)
					:wrap(ui.Wrap.YES),
				-- TODO: remove this after next yazi released
				content = ui.Text({
					ui.Line(""),
					ui.Line("The following file is existed, overwrite?"):fg("yellow"),
					ui.Line(""),
					ui.Line({
						ui.Span(" "),
						table.unpack(list_existed_files),
					}):align(ui.Align.LEFT),
				})
					:align(ui.Align.LEFT)
					:wrap(ui.Wrap.YES),
				pos = { "center", w = 70, h = 10 },
			})

			if not overwrite_answer then
				return -- If no overwrite selected, exit
			end
			local rm_status, rm_err = fs.remove("file", output_furl)
			if not rm_status then
				notify_error(string.format("Failed to remove %s, exit code %s", output_name, rm_err), "error")
				return
			end
		end

		for parent_path, fnames in pairs(files_to_archive) do
			-- Add to output archive in each path, their respective files
			local archive_output, archive_success, archive_code = run_command(
				archive_cmd
					.. " "
					.. table.concat(archive_args, " ")
					.. " "
					.. quote(tostring(compress_cmd and output_fname_without_ext or output_fpath))
					.. " "
					.. table.concat(fnames, " "),
				parent_path
			)
			if not archive_success then
				notify_error(
					string.format("Failed to archive, error %s", archive_output and archive_output or archive_code),
					"error"
				)
				return
			end
		end

		if compress_cmd then
			local compress_output, compress_success, compress_code = run_command(
				compress_cmd .. " " .. table.concat(compress_args, " ") .. " " .. quote(output_fname_without_ext),
				tostring(output_furl.parent)
			)
			if not compress_success then
				notify_error(
					string.format("Failed to compress, error %s", compress_output and compress_output or compress_code),
					"error"
				)
				return
			end
		end
	end,
}
