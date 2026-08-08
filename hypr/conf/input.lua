-- For all categories, see https://wiki.hyprland.org/Configuring/Variables/

hl.config({
	input = {
		repeat_rate = 80,
		repeat_delay = 300,
		scroll_factor = 1.0,
		-- sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

		touchpad = {
			disable_while_typing = true,
			tap_to_click = true,
			natural_scroll = true,
		},
	},
})

hl.device({
	name = "ugreen-ble-mouse",
	sensitivity = -0.9,
	accel_profile = "flat",
})

hl.device({
	name = "ugreen-mouse-1",
	sensitivity = -0.5,
	accel_profile = "flat",
})

hl.device({
	name = "logitech-m585/m590-1",
	sensitivity = -0.5,
	accel_profile = "flat",
})

hl.device({
	name = "rapoo-rapoo-gaming-device",
	scroll_factor = 2.0,
	accel_profile = "flat",
})
