---@type Wezterm
local wezterm = require("wezterm")

---@type Config
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Apply modular configs
for _, m in ipairs(wezterm.glob("*.lua", wezterm.config_dir)) do
	if not m:match("^wezterm%.lua$") then
		m = m:gsub("%.lua$", "")
		for k, v in pairs(require(m)) do
			config[k] = v
		end
	end
end

config.default_cursor_style = "SteadyBlock"
config.scrollback_lines = 5000
config.audible_bell = "SystemBeep"
config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 150,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 150,
	target = "CursorColor",
}
config.initial_cols = 80
config.initial_rows = 45
config.window_decorations = "TITLE|RESIZE"
config.window_padding = {
	left = 15,
	right = 15,
	top = 15,
	bottom = 15,
}

config.window_background_opacity = 1.0

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.enable_kitty_keyboard = true
config.enable_scroll_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.enable_wayland = true
config.animation_fps = 1
config.max_fps = 60
config.front_end = "OpenGL"

-- for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
-- 	if gpu.backend == "Vulkan" and gpu.driver == "NVIDIA" then
-- 		config.webgpu_preferred_adapter = gpu
-- 		config.front_end = "WebGpu"
-- 		break
-- 	end
-- end
config.webgpu_power_preference = "HighPerformance"
config.ime_preedit_rendering = "Builtin"
config.show_close_tab_button_in_tabs = false
config.show_new_tab_button_in_tab_bar = false
config.show_tab_index_in_tab_bar = false
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- make username/project paths clickable. this implies paths like the following are for github.
-- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wezterm/wezterm | "wezterm/wezterm.git" )
-- as long as a full url hyperlink regex exists above this it should not match a full url to
-- github or gitlab / bitbucket (i.e. https://gitlab.com/user/project.git is still a whole clickable url)
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
	format = "https://www.github.com/$1/$3",
})

config.tab_max_width = 30

config.set_environment_variables = {
	TERMINFO_DIRS = "/usr/share/terminfo",
	WSLENV = "TERMINFO_DIRS",
}
config.term = "wezterm"

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = ""

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = ""
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.active_pane.title

	-- extra fixed padding (spaces) around the title
	local side_padding = 3
	local edge_padding = 1
	-- trim if too long
	-- 2 edge, 6 padding left+right
	title = wezterm.truncate_right(title, max_width - (2 * edge_padding) - (2 * side_padding))
	title = string.rep(" ", side_padding) .. title .. string.rep(" ", side_padding)

	return {
		{ Background = { Color = config.colors.tab_bar.background } },
		{
			Foreground = {
				Color = tab.is_active and config.colors.tab_bar.active_tab.bg_color
					or config.colors.tab_bar.inactive_tab_edge,
			},
		},
		{ Text = SOLID_LEFT_ARROW },
		{
			Background = {
				Color = tab.is_active and config.colors.tab_bar.active_tab.bg_color
					or config.colors.tab_bar.inactive_tab.bg_color,
			},
		},
		{
			Foreground = {
				Color = tab.is_active and config.colors.tab_bar.active_tab.fg_color
					or config.colors.tab_bar.inactive_tab.fg_color,
			},
		},
		{ Text = title },
		{ Background = { Color = config.colors.tab_bar.background } },
		{
			Foreground = {
				Color = tab.is_active and config.colors.tab_bar.active_tab.bg_color
					or config.colors.tab_bar.inactive_tab_edge,
			},
		},
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
	local ws = wezterm.mux.get_active_workspace()
	local title = tab.active_pane.title
	if ws ~= "default" then
		return string.format("[%s] %s", ws, title)
	end
	return title
end)

local function should_prompt_on_quit(proc)
	if proc.status == "Run" then
		return true
	end
	for _, child in pairs(proc.children) do
		local child_status = should_prompt_on_quit(child)
		if child_status then
			return true
		end
	end
	return false
end
wezterm.on("mux-is-process-stateful", function(proc)
	-- log_proc(proc)
	---@diagnostic disable-next-line: redundant-return-value
	return should_prompt_on_quit(proc)
end)
return config
