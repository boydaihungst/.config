-- See https://wiki.hyprland.org/Configuring/Variables/ for more
--
hl.config({
	gestures = {
		workspace_swipe_touch = true,
	},
})

hl.gesture({
	fingers = 3,
	direction = "left",
	action = function()
		hl.exec_cmd("ydotool key 56:1 106:1 56:0 106:0")
	end,
})
hl.gesture({
	fingers = 3,
	direction = "right",
	action = function()
		hl.exec_cmd("ydotool key 56:1 105:1 56:0 105:0")
	end,
})
hl.gesture({ fingers = 3, direction = "vertical", action = "workspace" })
