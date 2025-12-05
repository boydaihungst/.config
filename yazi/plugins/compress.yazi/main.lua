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

local function tmp_name(url)
	return ".tmp_" .. ya.hash(string.format("compress//%s//%.10f", url, ya.time()))
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

local get_cwd = ya.sync(function()
	return cx.active.current.cwd
end)

local selected_files_maybe_vfs = ya.sync(function()
	local tab, raw_urls = cx.active, {}
	for _, u in pairs(tab.selected) do
		raw_urls[#raw_urls + 1] = tostring(u)
	end
	return raw_urls
end)

local selected_files = ya.sync(function()
	local tab, raw_urls = cx.active, {}
	for _, u in pairs(tab.selected) do
		local is_virtual = u.scheme and u.scheme.is_virtual
		local u_real = is_virtual and Url(u.scheme.cache .. tostring(u.path)) or u
		raw_urls[#raw_urls + 1] = { path = tostring(u_real), is_virtual = is_virtual }
	end
	return raw_urls
end)

local selected_or_hovered_files = ya.sync(function()
	local tab, raw_urls = cx.active, selected_files()
	if #raw_urls == 0 and tab.current.hovered then
		local hovered_url = tab.current.hovered.url
		local is_virtual = hovered_url.scheme and hovered_url.scheme.is_virtual
		hovered_url = is_virtual and Url(hovered_url.scheme.cache .. tostring(hovered_url.path)) or hovered_url
		raw_urls[1] = { path = tostring(hovered_url), is_virtual = is_virtual }
	end
	return raw_urls
end)

local selected_or_hovered = function()
	local result = {}
	local files = selected_or_hovered_files()

	for _, file in ipairs(files) do
		local url = Url(file.path)
		local cha, err = fs.cha(url)

		if cha then
			local parent_path = tostring(url.parent)
			if not result[parent_path] then
				result[parent_path] = {}
			end
			table.insert(result[parent_path], quote(url.name))
		else
			if file.is_virtual then
				notify_error(string.format("Remote VFS files need to be downloaded first: %s", file.path), "error")
			else
				notify_error(string.format("Failed to get metadata for %s: %s", file.path, err), "error")
			end
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

		local cwd = get_cwd()

		local path_separator = package.config:sub(1, 1)
		local output_url_maybe_vfs = Url(cwd .. path_separator .. output_name)
		local output_path_is_virtual = output_url_maybe_vfs.scheme and output_url_maybe_vfs.scheme.is_virtual

		local output_path_cache = output_path_is_virtual
				and Url(output_url_maybe_vfs.scheme.cache .. tostring(cwd.path .. path_separator .. output_name))
			or output_url_maybe_vfs
		local output_path_cha, _ = fs.cha(output_path_cache)
		local output_path_cha_vfs, _ = fs.cha(output_url_maybe_vfs)
		local output_url_maybe_vfs_no_extension = output_url_maybe_vfs.stem
		local output_path_cache_no_extension = output_path_cache.stem

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
		if output_path_cha or output_path_cha_vfs then
			list_existed_files[#list_existed_files + 1] = output_name
		end
		if compress_cmd then
			local output_fwithout_ext_cha = fs.cha(Url(cwd .. output_url_maybe_vfs_no_extension))
			if output_fwithout_ext_cha then
				list_existed_files[#list_existed_files + 1] = output_url_maybe_vfs_no_extension
			end
		end
		if #list_existed_files > 0 then
			overwrite_answer = ya.confirm({
				title = ui.Line("Create Archive File"),
				body = ui.Text({
					ui.Line(""),
					ui.Line(
						"The following file is existed, overwrite?"
							.. (output_path_is_virtual and " (included cached file)" or "")
					):fg("yellow"),
					ui.Line(""),
					ui.Line({
						ui.Span(" "),
						table.unpack(list_existed_files),
					}):align(ui.Align.LEFT),
				})
					:align(ui.Align.LEFT)
					:wrap(ui.Wrap.YES),
				pos = { "center", w = 70, h = 10 },
				-- TODO: remove this after next yazi released
				content = ui.Text({
					ui.Line(""),
					ui.Line(
						"The following file is existed, overwrite?"
							.. (output_path_is_virtual and " (included cached file)" or "")
					):fg("yellow"),
					ui.Line(""),
					ui.Line({
						ui.Span(" "),
						table.unpack(list_existed_files),
					}):align(ui.Align.LEFT),
				})
					:align(ui.Align.LEFT)
					:wrap(ui.Wrap.YES),
			})

			if not overwrite_answer then
				return -- If no overwrite selected, exit
			end
			if output_path_cha_vfs then
				local rm_status, rm_err = fs.remove("file", output_url_maybe_vfs)
				if not rm_status then
					notify_error(string.format("Failed to remove %s, exit code %s", output_name, rm_err), "error")
					return
				end
			end

			-- Remove cached vfs file
			if output_path_is_virtual and output_path_cha then
				fs.remove("file", output_path_cache)
			end
		end

		for parent_path, fnames in pairs(files_to_archive) do
			-- Add to output archive in each path, their respective files
			local archive_output, archive_success, archive_code = run_command(
				archive_cmd
					.. " "
					.. table.concat(archive_args, " ")
					.. " "
					.. quote(tostring(compress_cmd and output_path_cache_no_extension or tostring(output_path_cache)))
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
				compress_cmd .. " " .. table.concat(compress_args, " ") .. " " .. quote(output_path_cache_no_extension),
				tostring(output_path_cache.parent)
			)
			if not compress_success then
				notify_error(
					string.format("Failed to compress, error %s", compress_output and compress_output or compress_code),
					"error"
				)
				return
			end
		end
		-- NOTE: Trick to upload compressed file to vfs remote path
		output_path_cha, _ = fs.cha(output_path_cache)
		if output_path_is_virtual and output_path_cha and output_path_cache ~= output_url_maybe_vfs then
			local preserved_selected_files = selected_files_maybe_vfs()
			local preserved_cwd = get_cwd()
			local tmp_cache_path = tostring(output_path_cache.parent)
				.. path_separator
				.. tmp_name(tostring(output_path_cache))
				.. path_separator
				.. output_path_cache.name
			fs.create("dir_all", Url(tmp_cache_path).parent)
			os.rename(tostring(output_path_cache), tmp_cache_path)
			ya.emit("escape", { select = true })
			local valid_selected_files = {}
			valid_selected_files[#valid_selected_files + 1] = tostring(tmp_cache_path)
			valid_selected_files.state = "on"
			ya.emit("toggle_all", valid_selected_files)
			ya.emit("yank", { cut = true })
			ya.emit("cd", { tostring(output_url_maybe_vfs.parent), raw = true })
			ya.emit("paste", { force = true })

			-- Restore selected files
			ya.emit("escape", { select = true })
			valid_selected_files = {}
			for _, url_raw in ipairs(preserved_selected_files) do
				local url = Url(url_raw)
				local cha = fs.cha(url, {})
				if cha then
					valid_selected_files[#valid_selected_files + 1] = url_raw
				end
			end
			if #valid_selected_files > 0 then
				valid_selected_files.state = "on"
				ya.emit("toggle_all", valid_selected_files)
			end
			ya.emit("cd", { tostring(preserved_cwd), raw = true })
		end
	end,
}
