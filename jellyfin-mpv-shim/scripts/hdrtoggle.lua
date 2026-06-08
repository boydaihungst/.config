local utils = require "mp.utils"
local is_windows = package.config:sub(1, 1) == "\\"

if not is_windows then
    return
end
function find_in_path(exe_name)
    local result =
        mp.command_native(
        {
            args = {"cmd", "/c", "where", exe_name},
            _name = "subprocess",
            playback_only = false,
            capture_stdout = true,
            capture_stderr = true
        }
    )

    if result.status == 0 and result.stdout then
        -- Take the first path found
        local path = result.stdout:match("([^\r\n]+)")
        if path then
            return path:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
        end
    end
    return nil
end

local hdr_is_on = false
local hdrcmd = find_in_path("HDRCmd.exe")
local f = io.open(hdrcmd, "r")
if not f then
    mp.msg.error("HDRCmd.exe not found at: " .. hdrcmd)
else
    mp.msg.info("HDRCmd.exe found at: " .. hdrcmd)
    f:close()
end
mp.msg.info("HDR detecting.")

function check_hdr_and_toggle()
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
        mp.command_native_async(
            {
                args = {hdrcmd, "on"},
                _name = "subprocess",
                playback_only = false
            }
        )
        hdr_is_on = true
        mp.msg.info("HDR video detected. Enabling Windows HDR.")
    else
        mp.command_native_async(
            {
                args = {hdrcmd, "off"},
                _name = "subprocess",
                playback_only = false
            }
        )
        hdr_is_on = false
        mp.msg.info("SDR video detected. Disabling Windows HDR.")
    end
end

function clear_hdr_on_shutdown()
    -- Always ensure the system reverts to SDR when closing mpv
    mp.command_native_async(
        {
            args = {hdrcmd, "off"},
            _name = "subprocess",
            playback_only = false
        }
    )
    mp.msg.info("Disabling Windows HDR.")
    hdr_is_on = false
end

mp.register_event("video-reconfig", check_hdr_and_toggle)
mp.register_event("shutdown", clear_hdr_on_shutdown)
