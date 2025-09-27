require("hover-after-moved"):setup()
require("custom-dds"):setup()
require("simple-tag"):setup({
	ui_mode = "text",
	colors = {
		-- default theme is reversed color for hovered
		reversed = false,
		-- Default tag key = *
		["*"] = "#bf68d9",
		-- color for tag with key = "q"
		["$"] = "green",
		["`"] = "#4fa6ed",
		["~"] = "#E55561",
		["p"] = "red",
	},
	icons = {
		default = "󰚋",
		-- Add icon "*" tag for tag key = "*".
		["*"] = "",
		-- Add icon tag for tag key = "$"
		["$"] = "",
		-- Add icon tag for tag key = "!"
		-- ["`"] = "",
		["`"] = "",
		["~"] = "",
		["p"] = "",
	},
})
require("pref-by-location"):setup({
	-- no_notify = true,
	disable_fallback_preference = false,
	prefs = {
		-- If you want to use special characters (such as . * ? + [ ] ( ) ^ $ %), you need to escape them with a percent sign (%).
		-- Example: "/home/test/Hello (Lua) [world]" => { location = "/home/test/Hello %(Lua%) %[world%]", ....}
		{
			location = "^/mnt/remote/.*",
			sort = { "extension", reverse = false, dir_first = true },
			linemode = "size",
			show_hidden = false,
		},
		{
			location = ".*/Downloads",
			sort = { "btime", reverse = true, dir_first = true },
			linemode = "btime",
			show_hidden = false,
		},
	},
})

require("save-clipboard-to-file"):setup({
	input_position = { "center", w = 70 },
	overwrite_confirm_position = { "center", w = 70, h = 10 },
	hide_notify = false,
})

require("restore"):setup({
	-- position = { "center", w = 120, h = 40 },
	show_confirm = true,
	theme = {
		title = "blue",
		header = "green",
		header_warning = "red",
		list_item = { odd = "blue", even = "cyan" },
	},
})

require("fuse-archive"):setup({
	smart_enter = true,
	-- excluded_extensions = { "deb", "apk", "rpm" },
	-- extra_extensions = { "apk" },
	mount_options = "lazycache",
	-- mount_root_dir = "/home/huyhoang",
})

require("full-border"):setup({
	type = ui.Border.PLAIN,
})

require("zoxide"):setup({
	update_db = true,
})

local always_show_patterns = {
	"%- S%d%dE%d%d %-",
	-- "Bluray",
	-- "WEBDL",
	-- "WEBRip",
	-- "HDTV",
	-- "AMZN",
	-- "NF",
	-- "DSNP",
	-- "ADN",
	-- "v2",
}
local smart_truncate = require("smart-truncate")
smart_truncate:setup({
	always_show_patterns = always_show_patterns,
	render_parent = true,
	render_current = true,
})

require("relative-motions"):setup({
	show_numbers = "relative_absolute",
	show_motion = true,
	smart_truncate = true,
	line_numbers_styles = {
		hovered = ui.Style():fg("#61afef"),
		normal = ui.Style():fg("#494D56"),
	},
})

require("gvfs"):setup({
	input_position = { "center", y = 0, w = 60 },
	save_password_autoconfirm = false,
	password_vault = "pass", -- "keyring", "pass", or nil
	key_grip = "A01E6EDD2819D82B3B4D6509F480D961CCBB0E1D",
})
require("mime-ext"):setup({ -- Expand the existing filename database (lowercase), for example:
	fallback_file1 = true,
})

-- Bookmark plugin -- [[
local path_sep = package.config:sub(1, 1)
local home_path = ya.target_family() == "windows" and os.getenv("USERPROFILE") or os.getenv("HOME")

local bookmarks = {
	{
		tag = ".config",
		path = home_path .. path_sep .. ".config" .. path_sep,
		key = "c",
	},
	{
		tag = ".local/share",
		path = home_path .. path_sep .. ".local" .. path_sep .. "share" .. path_sep,
		key = "l",
	},
	{
		tag = "Downloads",
		path = home_path .. path_sep .. "Downloads" .. path_sep,
		key = "d",
	},
	{
		tag = "Videos",
		path = home_path .. path_sep .. "Videos" .. path_sep,
		key = "v",
	},
	{
		tag = "/mnt/remote",
		path = "/mnt" .. path_sep .. "remote" .. path_sep,
		key = "m",
	},
}
if ya.target_family() == "windows" then
	table.insert(bookmarks, {
		tag = "Scoop Local",

		path = (os.getenv("SCOOP") or home_path .. "\\scoop") .. "\\",
		key = "p",
	})
	table.insert(bookmarks, {
		tag = "Scoop Global",
		path = (os.getenv("SCOOP_GLOBAL") or "C:\\ProgramData\\scoop") .. "\\",
		key = "P",
	})
end

require("yamb"):setup({
	-- Optional, the path ending with path seperator represents folder.
	bookmarks = bookmarks,
	-- Optional, recieve notification everytime you jump.
	jump_notify = false,
	-- Optional, the cli of fzf.
	cli = "fzf",
	-- Optional, a string used for randomly generating keys, where the preceding characters have higher priority.
	keys = "abcdefghijklmnopqrstuvwxyz",
	-- Optional, the path of bookmarks
	path = (ya.target_family() == "windows" and os.getenv("APPDATA") .. "\\yazi\\config\\bookmark")
		or (os.getenv("HOME") .. "/.config/yazi/bookmark"),
})
-- ]]

require("projects"):setup({
	save = {
		method = "yazi", -- yazi | lua
		lua_save_path = "~/.config/yazi/state/projects.json", -- windows: "%APPDATA%/yazi/state/projects.json", unix: "~/.config/yazi/state/projects.json"
	},
	last = {
		update_after_save = true,
		update_after_load = true,
		load_after_start = true,
	},
	merge = {
		quit_after_merge = true,
	},
	notify = {
		enable = true,
		title = "Projects",
		timeout = 3,
		level = "info",
	},
})
--------------------------------------------------------------------------------------------
-------------------------- Root + Header + Status bar + linemode ------------------------------------
--------------------------------------------------------------------------------------------

function Root:drop(data)
	-- Default download_cmd = 'curl -sSLOJ "$1"'
	ya.emit("plugin", { "dragdrop", data })
	-- Or with specific downloader and args
	-- data = data .. " --download-cmd='wget -q --content-disposition \"$1\"'"
	-- ya.emit("plugin", { "dragdrop", data })
end

function Tabs.height()
	return 0
end

Header:children_add(function()
	if #cx.tabs <= 1 then
		return ""
	end
	local spans = {}
	for i = 1, #cx.tabs do
		local name = ui.truncate(string.format(" %d %s ", i, cx.tabs[i].name), { max = 20 })
		if i == cx.tabs.idx then
			spans[#spans + 1] = ui.Span(" " .. name .. " "):style(th.tabs.active)
		else
			spans[#spans + 1] = ui.Span(" " .. name .. " "):style(th.tabs.inactive)
		end
	end
	return ui.Line(spans)
end, 9000, Header.RIGHT)

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%H:%M:%S %d/%m", time)
	else
		time = os.date("%d/%m/%Y", time)
	end

	local size = self._file:size()
	return ui.Line(string.format("%s - %s", size and ("[" .. ya.readable_size(size) .. "]") or "", time))
end

--hostname + username before url
Header:children_add(function()
	if ya.target_family() ~= "unix" then
		return ui.Line({})
	end
	return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):style(ui.Style():fg("cyan"):bg("#080A0E"):bold())
end, 500, Header.LEFT)

--------------------------------- Components -----------------------------------------
function Status:file_size_and_folder_childs()
	local h = self._tab.current.hovered
	if not h or h.cha.is_link then
		return ui.Line({})
	end

	local size = h:size()

	if size then
		return ui.Line({
			ui.Span(ya.readable_size(h:size() or h.cha.len)),
			ui.Span(" "),
		})
	else
		local folder = cx.active:history(h.url)
		return ui.Line({
			ui.Span(folder and tostring(#folder.files) or ""),
			ui.Span(" "),
		})
	end
end

function Status:mtime()
	local h = self._tab.current.hovered
	if not h or h.cha.is_link then
		return ui.Line({})
	end
	local time = math.floor(h.cha.mtime or 0)
	if time == 0 then
		return ui.Line("")
	else
		return ui.Line({
			ui.Span(os.date("%Y-%m-%d %H:%M", time)),
			ui.Span(" "),
		})
	end
end

--  Status mode
function Status:mode()
	local mode = tostring(self._tab.mode):upper()

	local style = self:style()
	return ui.Line({
		ui.Span(" " .. mode .. " "):style(style.main),
		ui.Span(""):fg(style.main:bg()):bg(style.alt:fg()),
		ui.Span(""):fg(style.alt:fg()):bg("#26343F"),
	})
end

function Status:name()
	local h = self._tab.current.hovered
	if not h then
		return ui.Line({})
	end

	local icon = h:icon()
	local file_name = h.name
	local tail = h.cha.is_dir and "" or ("." .. (h.url.ext or ""))

	if h.link_to ~= nil then
		file_name = " " .. tostring(h.link_to)
	end

	local right_width = self:children_redraw(self.RIGHT):width()

	local left_lines = {}
	for _, c in ipairs(self._left) do
		if c[1] ~= Status.name and c[1] ~= "name" then
			left_lines[#left_lines + 1] = (type(c[1]) == "string" and self[c[1]] or c[1])(self)
		end
	end
	local left_width = ui.Line(left_lines):width()

	-- Progress bar width
	local max_width = math.floor(self._area.w - right_width - left_width - 26)

	file_name = smart_truncate:shorten(max_width, file_name, tail, always_show_patterns)
	local style = self:style()
	return ui.Line({
		ui.Span(" " .. icon.text):style(icon.style):bg("#26343F"),
		ui.Span(" " .. file_name:gsub("\r", "?", 1) .. " "):fg(style.alt:fg()):bg("#26343F"),
		ui.Span(""):fg("#26343F"):bg(style.alt:bg()),
	})
end

function Status:link_count()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ui.Line({})
	end

	return ui.Line({
		ui.Span("  "),
		ui.Span(tostring(h.cha.nlink)):fg("#BCC4C9"),
		ui.Span(" "),
	})
end

function Status:owner_group()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ui.Line({})
	end
	return ui.Line({
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("#BCC4C9"),
		ui.Span(" "),
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("#BCC4C9"),
		ui.Span(" "),
	})
end

-- -- Status position - Right
function Status:position()
	local cursor = self._tab.current.cursor
	local length = #self._tab.current.files

	return ui.Line({
		ui.Span(string.format(" %2d/%-2d ", math.min(cursor + 1, length), length)),
	})
end

-- Remove left components
Status:children_remove(1, Status.LEFT)
Status:children_remove(2, Status.LEFT)
Status:children_remove(3, Status.LEFT)

-- Remove right components
Status:children_remove(4, Status.RIGHT)
Status:children_remove(5, Status.RIGHT)
Status:children_remove(6, Status.RIGHT)

local render_status = (function()
	local status_left_section = {
		Status.mode,
		Status.name,
		Status.link_count,
	}

	-- Left Status
	local status_right_section = {
		Status.mtime,
		Status.file_size_and_folder_childs,
		Status.owner_group,
		Status.perm,
		Status.position,
	}

	for idx, component in ipairs(status_left_section) do
		Status:children_add(component, idx, Status.LEFT)
	end

	for idx, component in ipairs(status_right_section) do
		Status:children_add(component, idx, Status.RIGHT)
	end
end)()
