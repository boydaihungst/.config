--- @since 25.5.31

local M = {}

local set_state = ya.sync(function(state, key, value)
	state[key] = value
end)

local get_state = ya.sync(function(state, key)
	return state[key]
end)

function M:peek(job)
	local changed_seek
	if not get_state("SEEKING") then
		job.skip = 999999999
	end
	local err, bound = ya.preview_code(job)
	if bound then
		set_state("SEEKING", true)
		changed_seek = true
		ya.emit("peek", { bound, only_if = job.file.url })
	elseif err and not err:find("cancelled", 1, true) then
		require("empty").msg(job, err)
	end
	if not changed_seek then
		set_state("SEEKING", false)
	end
end

function M:seek(job)
	set_state("SEEKING", true)
	require("code"):seek(job)
end

return M
