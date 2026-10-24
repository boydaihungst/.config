local platform = mp.get_property_native("platform")
local VOLUME_LEVEL_ON_SHUTDOWN = "9"
local VOLUME_LEVEL_ON_STARTUP = "12"

local function reduce_volume_on_shutdown()
	if platform == "windows" then
		mp.command_native({
			args = {
				"cmd",
				"/c",
				"C:\Users\boyda\Downloads\BluetoothDevicePairing\soundbar-volume.bat",
				"VOLUME_LEVEL_ON_SHUTDOWN",
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
			"C:\Users\boyda\Downloads\BluetoothDevicePairing\soundbar-volume.bat",
			"VOLUME_LEVEL_ON_STARTUP",
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
