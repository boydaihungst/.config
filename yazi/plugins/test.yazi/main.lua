--- @since 25.8.15
-- yazi/plugins/your-plugin.yazi/main.lua

local is_searching = ya.sync(function()
	return cx.active.current.cwd.spec.is_search
end)

local hovered_file_path = ya.sync(function()
	return cx.active.current.hovered and tostring(cx.active.current.hovered.url.path)
end)

return {
	entry = function()
		local path = hovered_file_path()
		if is_searching() and path then
			-- ya.emit("shell", { "ya emit reveal %h --raw --no-dummy", confirm = true })
			ya.emit("reveal", { path, no_dummy = not fs.cha(Url(path), false), raw = true })
		else
			ya.emit("leave", {})
		end
	end,
}

-- local function fail(s, ...)
-- 	error(string.format(s, ...))
-- end
--
-- local M = {}
--
-- function M:setup()
-- 	ps.sub_remote("custom-extract", function(args)
-- 		ya.async(function()
-- 			for i, arg in ipairs(args) do
-- 				local source = arg and Url(arg)
-- 				local destination = source and source.parent:join(source.stem)
-- 				local success, err = fs.create("dir", destination)
-- 				if success then
-- 					local in_ = {
-- 						"extract",
-- 						args = { arg, tostring(destination), noisy = #args == 1 },
-- 						track = i == 1,
-- 					}
-- 					ya.task("plugin", in_):name("Extract " .. arg):spawn()
-- 				else
-- 					fail(tostring(err or ""))
-- 				end
-- 			end
-- 		end)
-- 	end)
-- end
--
-- return M
