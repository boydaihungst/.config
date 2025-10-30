--- @since 25.5.31

local M = {}
local path_separator = package.config:sub(1, 1)
local PLUGIN_NAME = "Drag-and-Drop"

local function error(s, ...)
	ya.notify({ title = PLUGIN_NAME, content = string.format(s, ...), timeout = 3, level = "error" })
end

local function info(s, ...)
	ya.notify({ title = PLUGIN_NAME, content = string.format(s, ...), timeout = 3, level = "info" })
end

-- Normalize paths across OS
local function normalize_path(path)
	-- Trim surrounding quotes (Windows drag-drop)
	path = path:gsub('^"(.*)"$', "%1")

	-- macOS Finder drops like "file:///Users/foo/file.txt"
	path = path:gsub("^file://", "")

	-- On Windows: convert backslashes to forward slashes internally
	path = path:gsub("\\", "/")

	return path
end

-- Copy file content
local function copy_file(src, dst)
	local infile, err = io.open(src, "rb")
	if not infile then
		return nil, "open src failed: " .. tostring(err)
	end

	local outfile, oerr = io.open(dst, "wb")
	if not outfile then
		infile:close()
		return nil, "open dst failed: " .. tostring(oerr)
	end

	local blocksize = 1024 * 1024 -- 1MB buffer
	while true do
		local chunk = infile:read(blocksize)
		if not chunk then
			break
		end
		outfile:write(chunk)
	end

	infile:close()
	outfile:close()
	return true
end

-- Safe move into folder
local function move_into(src, dst_folder)
	src = normalize_path(src)
	dst_folder = normalize_path(dst_folder)

	-- Extract filename (last component)
	local filename = src:match("([^/]+)$")
	if not filename then
		return nil, "invalid source path: " .. src
	end

	-- Use proper OS separator
	local dst = dst_folder .. path_separator .. filename

	-- Try rename first (fast, but fails across devices/filesystems)
	local ok, err = os.rename(src, dst)
	if ok then
		return true
	end

	-- Fallback: copy+delete
	local ok2, cerr = copy_file(src, dst)
	if not ok2 then
		return nil, cerr
	end

	os.remove(src)
	return true
end

local function download_file(url, dst, command)
	command = command or ("curl -sSLOJ" .. ' "$1"')

	local child, err = Command("sh")
		:arg({ "-c", command, "sh", tostring(url) })
		:cwd(dst)
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return nil, err
	end

	local status, child_err = child:wait()
	child:start_kill()

	if child_err or (status and not status.success) then
		return nil, child_err
	end
	return true
end

--- Convert file list to UI component list
---@return ui.List[]
local function get_components(file_list)
	local item_odd_style = th.confirm.list
	local item_even_style = th.confirm.list

	local components = {}
	local display_index = 1

	for _, item in ipairs(file_list) do
		table.insert(
			components,
			ui.Line({
				ui.Span(" "),
				ui.Span(item):style((display_index % 2 == 1) and item_odd_style or item_even_style),
			}):align(ui.Align.LEFT)
		)
		display_index = display_index + 1
	end
	return components
end

local get_cwd = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

function M:entry(job)
	local raw_drop_data = job.args
	local download_cmd = job.args.download_cmd
	local cwd = get_cwd()
	local urls, files = {}, {}
	---@type "file"|"url"|nil
	local drop_type

	for _, line in ipairs(raw_drop_data) do
		line = line:match("^%s*(.-)%s*$")
		if line:match("^https?://") then
			-- Handle URL
			if not drop_type then
				drop_type = "url"
			elseif drop_type ~= "url" then
				-- Fallback: plain text or unsupported
				return
			end
			urls[#urls + 1] = line
		else
			line = normalize_path(line)
			local file_url = Url(line)
			if file_url.is_absolute and file_url.is_regular and fs.cha(file_url) then
				-- Handle file path
				if not drop_type then
					drop_type = "file"
				elseif drop_type ~= "file" then
					-- Fallback: plain text or unsupported
					return
				end

				if tostring(file_url) == cwd then
					goto continue
				end
				files[#files + 1] = tostring(file_url)
			else
				-- Fallback: plain text or unsupported
				return
			end
		end
		::continue::
	end
	if #files > 0 or #urls > 0 then
		-- Show confirm dialog if any files or urls is dropped
		local confirmed = ya.confirm({
			title = ui.Line("Drag-and-Drop"):style(th.confirm.title),
			body = ui.Text({
				ui.Line(""),
				ui.Line(
					"Confirm to "
						.. (
							drop_type == "file" and "move these files and folders to current folder?"
							or "download these urls to current folder?"
						)
				):style(ui.Style():fg("yellow")),
				ui.Line(""),
				table.unpack(get_components(drop_type == "file" and files or urls)),
			})
				:align(ui.Align.LEFT)
				:wrap(ui.Wrap.YES),
			pos = { "center", w = 70, h = 40 },
		})
		if not confirmed then
			return
		end
	else
		-- Exit if no files or urls is dropped
		return
	end

	if drop_type == "file" then
		for _, file_path in ipairs(files) do
			local ok, err = move_into(file_path, cwd)
			if not ok then
				error("Failed to move: " .. file_path .. " -> " .. tostring(err))
				break
			end
		end
	elseif drop_type == "url" then
		for _, url in ipairs(urls) do
			info("Downloading: " .. url)

			local ok, err = download_file(url, cwd, download_cmd)
			if not ok then
				error("Failed to download: " .. url .. " -> " .. tostring(err))
				break
			end
		end
	end
end

return M
