-- ~/.config/yazi/plugins/folder-rules.yazi/main.lua
local function setup()
	local home = os.getenv("HOME") or os.getenv("USERPROFILE")
	ps.sub("ind-hidden", function(opt)
		local cwd = cx.active.current.cwd
		if tostring(cwd.path) == home then
			opt.state = "hide"
		else
			opt.state = "show"
		end
		return opt
	end)
end

return { setup = setup }
