---@type Wezterm
local wezterm = require("wezterm")

---@type Config
return {
	colors = {
		foreground = "#BCC4C9",
		background = "#080A0E",

		cursor_bg = "#FFFFFF",
		cursor_fg = "#000000",
		cursor_border = "#FFFFFF",

		selection_fg = "#080A0E",
		selection_bg = "#AAAAAA",

		-- ANSI Colors
		ansi = {
			"#282c34", -- color0
			"#e06c75", -- color1
			"#98c379", -- color2
			"#e5c07b", -- color3
			"#61afef", -- color4
			"#be5046", -- color5
			"#56b6c2", -- color6
			"#979eab", -- color7
		},
		-- Bright ANSI Colors
		brights = {
			"#393e48", -- color8
			"#d19a66", -- color9
			"#56b6c2", -- color10
			"#e5c07b", -- color11
			"#61afef", -- color12
			"#be5046", -- color13
			"#56b6c2", -- color14
			"#abb2bf", -- color15
		},

		tab_bar = {
			background = "#080A0E",
			inactive_tab_edge = "#14161B",
			active_tab = {
				bg_color = "#597999",
				fg_color = "#dddddd",
			},
			inactive_tab = {
				bg_color = "#14161B",
				fg_color = "#abb2bf",
			},
			inactive_tab_hover = {
				bg_color = "#2c313a",
				fg_color = "#dddddd",
			},
			new_tab = {
				bg_color = "#14161B",
				fg_color = "#abb2bf",
			},
			new_tab_hover = {
				bg_color = "#2c313a",
				fg_color = "#dddddd",
			},
		},
	},
}
