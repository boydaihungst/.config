local platform = mp.get_property_native("platform")
local DEVICE_ID = "209542ab-9c82-1967-9806-82a8323cbb55"
local VOLUME_LEVEL_ON_SHUTDOWN = "9"
local VOLUME_LEVEL_ON_STARTUP = "12"

local function reduce_volume_on_shutdown()
	if platform == "windows" then
		mp.command_native({
			args = {
				"cmd",
				"/c",
				"smartthings",
				"devices:commands",
				DEVICE_ID,
				"audioVolume:setVolume(" .. VOLUME_LEVEL_ON_SHUTDOWN .. ")",
			},
			name = "subprocess",
			playback_only = false,
			detach = true,
		})
	elseif platform == "linux" then
		mp.command_native({
			args = {
				os.getenv("HOME") .. "/bin/soundbar-vol.sh",
				VOLUME_LEVEL_ON_SHUTDOWN,
			},
			name = "subprocess",
			playback_only = false,
			detach = true,
		})
	end
end

if platform == "windows" then
	mp.command_native_async({
		args = {
			"cmd",
			"/c",
			"smartthings",
			"devices:commands",
			DEVICE_ID,
			"audioVolume:setVolume(" .. VOLUME_LEVEL_ON_STARTUP .. ")",
		},
		name = "subprocess",
		playback_only = false,
		detach = true,
	})
elseif platform == "linux" then
	mp.command_native_async({
		args = {
			os.getenv("HOME") .. "/bin/soundbar-vol.sh",
			VOLUME_LEVEL_ON_STARTUP,
		},
		name = "subprocess",
		playback_only = false,
		detach = true,
	})
end
mp.register_event("shutdown", reduce_volume_on_shutdown)
