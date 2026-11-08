-- @title Font Cycler
-- @description Adds macros to cycle through a user-defined list of fonts for selected lines.
-- @version 1.1
-- @author Gemini
-- @homepage https://github.com/google/gemini

script_name = "Font Cycler"
script_description = "Cycles through a user-defined list of fonts for selected lines."
script_version = "1.1"
script_author = "Gemini"

-- Use Aegisub's dependency control for local modules
local re = require("aegisub.re")

--[[
    CONFIGURATION MANAGEMENT (using Lua IO)
    We use Lua's file I/O to store the font list and the last used index.
    The configuration is saved in a file named 'font_cycler.conf' in the Aegisub user directory.
--]]
-- Determine the configuration file path
local config_path = aegisub.decode_path("?user") .. "\\font_cycler.conf"

function get_config()
	-- Default configuration if file doesn't exist or is invalid
	local defaults = {
		font_list = "Arial\nTimes New Roman\nComic Sans MS",
		current_index = 0,
	}

	local file, err = io.open(config_path, "r")
	if not file then
		-- If file doesn't exist, return defaults
		return defaults
	end

	-- Read the configuration from the file
	local index_str = file:read("*l") -- Read the first line for the index
	local font_list_str = file:read("*a") -- Read the rest of the file for the font list
	file:close()

	local cfg = {}
	-- Convert index to number, default to 0 if invalid
	cfg.current_index = tonumber(index_str) or 0

	-- Clean up font list string, which might have leading/trailing newlines
	if font_list_str then
		font_list_str = font_list_str:match("^%s*(.-)%s*$")
		cfg.font_list = font_list_str
	else
		cfg.font_list = defaults.font_list
	end

	-- Final check to ensure we have a valid font list
	if not cfg.font_list or cfg.font_list == "" then
		cfg.font_list = defaults.font_list
	end

	return cfg
end

function set_config(cfg)
	local file, err = io.open(config_path, "w")
	if not file then
		aegisub.log("Error: Could not open config file for writing: " .. config_path .. "\n" .. tostring(err))
		return
	end

	-- Write the current index on the first line, and the font list on the rest
	file:write(tostring(cfg.current_index) .. "\n")
	file:write(cfg.font_list)
	file:close()
end

--[[
    CONFIGURATION DIALOG
    This function creates and displays the dialog box where the user can input their font list.
--]]
function show_config_dialog(subs, selected_lines)
	local cfg = get_config()

	-- Define the UI controls for the dialog
	local dialog_config = {
		{
			x = 0,
			y = 0,
			width = 1,
			height = 1,
			class = "label",
			label = "  ~   Font Cycler " .. script_version .. "   ~",
		},
		{
			class = "label",
			x = 0,
			y = 1,
			width = 1,
			height = 1,
			label = "Enter font names, one per line:",
		},
		{
			class = "textbox",
			name = "font_list_box",
			x = 0,
			y = 2,
			width = 2,
			height = 20,
			text = cfg.font_list,
			multiline = true,
		},
	}

	buttons = { "OK", "Cancel" }
	-- Show the dialog and get the user's input
	local buttons, controls = aegisub.dialog.display(
		dialog_config, -- UI Layout
		buttons,
		{ ok = "OK", close = "Cancel" }
	)

	-- If the user clicks "OK" and provides a font list, save it.
	if buttons == "OK" and controls.font_list_box then
		cfg.font_list = controls.font_list_box
		-- Reset index when the list is updated to avoid out-of-bounds errors
		cfg.current_index = 0
		set_config(cfg)
		-- aegisub.log(script_name .. ": Font list updated and saved to file.\n")
	end
end

--[[
    CORE FONT SWITCHING LOGIC
    This is the main function that applies the font change to the selected lines.
--]]
function switch_font(subs, selected_lines, direction)
	if not selected_lines or #selected_lines == 0 then
		aegisub.log(script_name .. ": No lines selected.\n")
		return
	end

	local cfg = get_config()

	-- Split the font list string into a table of font names
	local fonts = {}
	for font in string.gmatch(cfg.font_list, "[^\r\n]*%S[^\r\n]*") do
		table.insert(fonts, font:match("^%s*(.-)%s*$"))
	end

	if #fonts == 0 then
		aegisub.log(script_name .. ": Font list is empty. Please configure it first.\n")
		-- aegisub.status_bar.set("Font list is empty. Go to Automation -> Font Cycler -> Configure Fonts.")
		return
	end

	-- Calculate the new index
	-- The index cycles through the list based on the direction (1 for next, -1 for previous)
	local new_index = cfg.current_index + direction
	if new_index > #fonts then
		new_index = 1 -- Wrap around to the start
	elseif new_index < 1 then
		new_index = #fonts -- Wrap around to the end
	end

	-- Update the configuration with the new index
	cfg.current_index = new_index
	set_config(cfg)

	local selected_font = fonts[new_index]

	-- Process each selected line
	for _, i in ipairs(selected_lines) do
		local line = subs[i]
		local text = line.text
		text = text:gsub("%{%}", "")
		if text:match("^%b{}") then
			-- Override block exists at the start
			text = text:gsub("^({\\[^}]-)}", function(override)
				-- Remove invalid or valid \fn tags
				local cleaned = override:gsub("\\fn[^\\}]*", "")
				-- Add correct \fn tag
				return cleaned .. "\\fn" .. selected_font .. "}"
			end)
		else
			-- No override block, insert one at the beginning
			text = "{\\fn" .. selected_font .. "}" .. text
		end

		line.text = text
		-- Prepend the new font override tag
		subs[i] = line
	end

	-- aegisub.log(string.format(script_name .. ": Applied font '%s'.\n", selected_font))
	-- aegisub.status_bar.set(string.format("Font set to: %s", selected_font))
end

--[[
    MACRO DEFINITIONS
    These are the functions that will be called when the user clicks the macros in the Automation menu.
--]]

-- Macro to select the next font in the list (top to bottom)
function cycle_font_next(subs, selected_lines)
	switch_font(subs, selected_lines, 1)
end

-- Macro to select the previous font in the list (bottom to top)
function cycle_font_previous(subs, selected_lines)
	switch_font(subs, selected_lines, -1)
end

--[[
    REGISTER SCRIPT WITH AEGISUB
    This part registers the macros and the configuration dialog with Aegisub's menu system.
--]]
aegisub.register_macro(
	script_name .. "/Font Cycler: Next",
	"Changes the font of selected lines to the next in the user list.",
	cycle_font_next
)

aegisub.register_macro(
	script_name .. "/Font Cycler: Previous",
	"Changes the font of selected lines to the previous in the user list.",
	cycle_font_previous
)

aegisub.register_macro(
	script_name .. "/Configure Fonts...",
	"Opens the configuration dialog to set the font list.",
	show_config_dialog
)
