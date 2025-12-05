--- @since 25.5.31

local M = {}
local MAX_ITEMS_IN_CACHE = 100
local MAX_OUTPUT_LINES_TO_CACHE = 100000

local STATE_KEY = {
	CACHED_COMMAND_OUTPUT = "CACHED_COMMAND_OUTPUT",
}

local set_state = ya.sync(function(state, namespace, key, value, limit_cached_items)
	if not state[namespace] then
		state[namespace] = {}
	end
	local storage = state[namespace]
	if limit_cached_items and #storage > limit_cached_items then
		table.remove(storage, 1)
	end
	storage[key] = value
end)

local get_state = ya.sync(function(state, namespace, key)
	local storage = state[namespace]
	if not storage then
		return nil
	end

	if storage then
		return storage[key]
	end
end)

function M:peek(job)
	local start = os.clock()
	local cached_ouput, file_cache_name
	local file_cache = ya.file_cache({ file = job.file, skip = 0 })

	if file_cache then
		file_cache_name = tostring(file_cache)
		cached_ouput = get_state(STATE_KEY.CACHED_COMMAND_OUTPUT, file_cache_name)
	end

	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

	local output = {}
	if not cached_ouput or cached_ouput.exceeded_max_line then
		local piper_output = require("piper"):peek(job)
		local args = "--cmd="
			.. ya.quote(job.args[1])
			.. " --url="
			.. ya.quote(tostring(job.file.url))
			.. " --w="
			.. ya.quote(job.area.w)
			.. " --h="
			.. ya.quote(job.area.h)
			.. " --file-cache-name="
			.. ya.quote(file_cache_name)
		if job.args.cache_limit then
			args = args .. " --cache-limit=" .. ya.quote(job.args.cache_limit)
		end
		if job.args.cache_max_lines then
			args = args .. " --cache-max-lines=" .. ya.quote(job.args.cache_max_lines)
		end
		ya.emit("plugin", {
			"enhance-piper",
			args,
		})
		return piper_output
	else
		output = cached_ouput.output
	end

	local limit = job.area.h
	local i, outs = 0, {}

	for _, line in ipairs(output) do
		if i >= job.skip + limit then
			break
		end

		i = i + 1
		if i > job.skip then
			outs[#outs + 1] = line
		end
	end

	if job.skip > 0 and i < job.skip + limit then
		ya.emit("peek", { math.max(0, i - limit), only_if = job.file.url, upper_bound = true })
	else
		ya.preview_widget(job, require("piper").format(job, outs))
	end
end

function M:seek(job)
	require("code"):seek(job)
end

function M:entry(job)
	local cached_ouput
	local file_cache_name = job.args.file_cache_name
	local cache_limit = job.args.cache_limit and tonumber(job.args.cache_limit) or MAX_ITEMS_IN_CACHE
	local cache_max_lines = job.args.cache_max_lines and tonumber(job.args.cache_max_lines) or MAX_OUTPUT_LINES_TO_CACHE

	if file_cache_name then
		cached_ouput = get_state(STATE_KEY.CACHED_COMMAND_OUTPUT, file_cache_name)
		if not cached_ouput or not cached_ouput.exceeded_max_line then
			local output = {}
			local child, child_err = Command("sh")
				:arg({ "-c", job.args.cmd, "sh", job.args.url })
				:env("w", job.args.w)
				:env("h", job.args.h)
				:stdout(Command.PIPED)
				:stderr(Command.PIPED)
				:spawn()
			if not child then
				return
			end

			local i = 0
			while true do
				local next, event = child:read_line()
				if event == 1 then
					child:start_kill()
					return
				elseif event ~= 0 then
					child:start_kill()
					break
				end
				i = i + 1
				output[#output + 1] = next
				if cache_max_lines and i >= cache_max_lines then
					child:start_kill()
					if file_cache_name then
						set_state(
							STATE_KEY.CACHED_COMMAND_OUTPUT,
							file_cache_name,
							{ output = "", exceeded_max_line = true },
							cache_limit
						)
					end
					return
				end
			end

			-- Cache output to ram if possible
			if file_cache_name then
				set_state(
					STATE_KEY.CACHED_COMMAND_OUTPUT,
					file_cache_name,
					{ output = output, exceeded_max_line = false },
					cache_limit
				)
			end
		end
	end
end

return M
