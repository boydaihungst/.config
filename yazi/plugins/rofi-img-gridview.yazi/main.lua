local M = {}

local get_cwd = ya.sync(function()
	return cx.active.current.cwd
end)

function M:entry(job)
	-- clear selection
	ya.emit("escape", { select = true })
	local cwd = get_cwd()
	-- selected_files is a string array
	for _, filename in ipairs(job.args) do
		local url = Url(cwd):join(filename)
		local cha = fs.cha(url, {})
		if cha then
			ya.emit("toggle", { url, state = "on" })
		end
	end
end
return M
