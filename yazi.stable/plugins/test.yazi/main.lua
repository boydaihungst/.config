--- @since 25.6.11
local M = {}

local test = ya.sync(function()
	for _, file in ipairs(cx.active.current.files) do
		local highlights = file:highlights()
		if highlights and #highlights > 0 then
			ya.err("matched " .. file.name)
		end
	end
end)

function M:entry()
	test()
end
return M
