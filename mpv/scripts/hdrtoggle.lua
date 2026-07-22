local utils = require("mp.utils")
local platform = mp.get_property_native("platform")
local HDR_MONITOR_SWAY = "Q27G4ZDP"
local MONITOR_SDR_ICC_PROFILE = "~/.config/sway/scripts/color_profiles/Q27G4ZDP.icm"
local MONITOR_HDR_COLOR_PROFILE = "gamma22"

mp.msg.info("HDR detecting.")
local hdrcmd_on
local hdrcmd_off
if platform == "windows" then
	local function find_in_path(exe_name)
		local result = mp.command_native({
			args = { "cmd", "/c", "where", exe_name },
			name = "subprocess",
			playback_only = false,
			capture_stdout = true,
			capture_stderr = true,
		})

		if result.status == 0 and result.stdout then
			-- Take the first path found
			local path = result.stdout:match("([^\r\n]+)")
			if path then
				return path:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
			end
		end
		return nil
	end

	local hdrcmd = find_in_path("HDRCmd.exe")
	if not hdrcmd then
		mp.msg.error("HDRCmd.exe not found in PATH.")
	else
		local f = io.open(hdrcmd, "r")
		if not f then
			mp.msg.error("HDRCmd.exe not found at: " .. hdrcmd)
		else
			hdrcmd_on = { hdrcmd, "on" }
			hdrcmd_off = { hdrcmd, "off" }
			mp.msg.info("HDRCmd.exe found at: " .. hdrcmd)
			f:close()
		end
	end
elseif platform == "linux" then
	local env = {}
	for _, v in ipairs(utils.get_env_list()) do
		local i = v:find("=", 1, true)
		env[v:sub(1, i - 1)] = v:sub(i + 1)
	end

	if env["SWAYSOCK"] ~= nil then
		local function get_monitor_name(monitor_model)
			local result = mp.command_native({
				args = {
					"swaymsg",
					"-t",
					"get_outputs",
					"-r",
				},
				name = "subprocess",
				playback_only = false,
				capture_stdout = true,
				capture_stderr = true,
			})

			if result.status == 0 and result.stdout then
				local monitors = utils.parse_json(result.stdout)

				for _, m in ipairs(monitors) do
					if m.model == monitor_model then
						return m.name
					end
				end
			end
			return nil
		end

		local monitor = get_monitor_name(HDR_MONITOR_SWAY)
		if not monitor then
			return
		end
		hdrcmd_on = { "swaymsg", "output", monitor, "hdr", "on" }
		hdrcmd_off = {
			"swaymsg",
			"output",
			monitor,
			"hdr",
			"off",
		}
		hdrcmd_on[#hdrcmd_on + 1] = "color_profile"
		hdrcmd_on[#hdrcmd_on + 1] = MONITOR_HDR_COLOR_PROFILE or "srgb"

		if MONITOR_SDR_ICC_PROFILE then
			hdrcmd_off[#hdrcmd_off + 1] = "color_profile"
			hdrcmd_off[#hdrcmd_off + 1] = "icc"
			hdrcmd_off[#hdrcmd_off + 1] = MONITOR_SDR_ICC_PROFILE
		end
		mp.command_native({
			args = { "pkill", "-RTMIN+10", "waybar" },
			name = "subprocess",
			playback_only = false,
		})
	end
end

local function check_hdr_and_toggle()
	-- Fetch video parameters from mpv
	local video_params = mp.get_property_native("video-params")

	-- Safety check if there's no video track (e.g., audio-only files)
	if not video_params then
		return
	end

	local gamma = video_params["gamma"]
	local primaries = video_params["primaries"]
	mp.msg.info("gamma=" .. tostring(gamma) .. " primaries=" .. tostring(primaries))

	local is_hdr = primaries ~= "bt.709"
	if is_hdr then
		mp.command_native({
			args = hdrcmd_on,
			name = "subprocess",
			playback_only = false,
		})
		mp.msg.info("HDR video detected. Enabling HDR.")
	else
		mp.command_native({
			args = hdrcmd_off,
			name = "subprocess",
			playback_only = false,
		})
		mp.msg.info("SDR video detected. Disabling HDR.")
	end
end

local function clear_hdr_on_shutdown()
	-- Always ensure the system reverts to SDR when closing mpv
	mp.command_native({
		args = hdrcmd_off,
		name = "subprocess",
		playback_only = false,
	})
	mp.msg.info("Disabling HDR.")
end

if hdrcmd_on and hdrcmd_off then
	mp.register_event("shutdown", clear_hdr_on_shutdown)
	mp.register_event("video-reconfig", check_hdr_and_toggle)
end
