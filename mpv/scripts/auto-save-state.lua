-- Runs write-watch-later-config periodically
local utils = require("mp.utils")
local mp = require("mp")
local options = require("mp.options")
local o = { save_interval = 60, yazi_simple_tag_keys = "w" }
options.read_options(o)
local function run(cmd)
	local res = utils.subprocess({
		args = cmd,
		cancellable = false,
	})

	if res.status ~= 0 then
		print("Command failed:", table.concat(cmd, " "))
		print(res.stderr or "")
	end

	return res
end

local function trigger_yazi_simple_tag(path)
	path = path or mp.get_property("path")

	if path then
		-- 1. Clear visual selection
		run({
			"ya",
			"emit-to",
			"0",
			"escape",
			"select",
		})

		-- 2. Trigger visual select a video file
		run({
			"ya",
			"emit-to",
			"0",
			"toggle_all",
			"--",
			path,
		})

		-- 3. Add tag key = o.yazi_simple_tag_keys
		run({
			"ya",
			"emit-to",
			"0",
			"plugin",
			"simple-tag",
			"add-tag --key=" .. o.yazi_simple_tag_keys,
		})
	end
end

local function save()
	if mp.get_property_bool("save-position-on-quit") then
		-- trigger_yazi_simple_tag()
		mp.command("write-watch-later-config")
	end
end

local function save_if_pause(_, pause)
	if pause then
		save()
	end
end

local function pause_timer_while_paused(_, pause)
	if pause then
		timer:stop()
	else
		timer:resume()
	end
end

-- This function runs on file-loaded, registers two callback functions, and
-- then they run delete-watch-later-config when appropriate.
local function delete_watch_later(event)
	local path = mp.get_property("path")

	-- Temporarily disables save-position-on-quit while eof-reached is true, so
	-- state isn't saved at EOF when keep-open=yes
	local function eof_reached(_, eof)
		if not can_delete then
			return
		elseif eof then
			print("path: " .. path)
			print("Deleting state (eof-reached)")
			mp.commandv("delete-watch-later-config", path)
			mp.set_property("save-position-on-quit", "no")
		else
			mp.set_property("save-position-on-quit", "yes")
		end
	end

	local function end_file(event)
		mp.unregister_event(end_file)
		mp.unobserve_property(eof_reached)

		if not can_delete then
			can_delete = true
		elseif event["reason"] == "eof" or event["reason"] == "stop" then
			trigger_yazi_simple_tag(path)
			print("Deleting state (end-file " .. event["reason"] .. ")")
			mp.commandv("delete-watch-later-config", path)
		end
	end

	mp.observe_property("eof-reached", "bool", eof_reached)
	mp.register_event("end-file", end_file)
end

mp.set_property("save-position-on-quit", "yes")

can_delete = true
mp.register_script_message("skip-delete-state", function()
	can_delete = false
end)

timer = mp.add_periodic_timer(o.save_interval, save)
mp.observe_property("pause", "bool", pause_timer_while_paused)

mp.observe_property("pause", "bool", save_if_pause)
mp.register_event("file-loaded", delete_watch_later)
