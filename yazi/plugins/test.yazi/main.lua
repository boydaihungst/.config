local function fail(s, ...)
	error(string.format(s, ...))
end

local M = {}

function M:setup()
	ps.sub_remote("custom-extract", function(args)
		ya.async(function()
			for i, arg in ipairs(args) do
				local source = arg and Url(arg)
				local destination = source and source.parent:join(source.stem)
				local success, err = fs.create("dir", destination)
				if success then
					local in_ = {
						"extract",
						args = { arg, tostring(destination), noisy = #args == 1 },
						track = i == 1,
					}
					ya.task("plugin", in_):name("Extract " .. arg):spawn()
				else
					fail(tostring(err or ""))
				end
			end
		end)
	end)
end

return M
