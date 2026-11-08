local M = {}

local get_cwd = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

local function save_stash(args)
	if args.source == "cd" then
		ya.emit("stash", { cx.active.current.cwd, source = "cd" })
		ya.emit("stash", { args.target, source = "cd" })
	elseif args.source == "tab" then
		return args -- Returns `args` as is to allow stashing this time
	elseif args.source == "search" then
		ya.emit("stash", { cx.active.current.cwd, source = "cd" })
	end
end

function M:setup()
	ps.sub("ind-stash", save_stash) -- Triggered when the `stash` command is called on `cd`
	ps.sub("relay-stash", save_stash) -- Triggered when the `stash` command is called on interactive `cd`
end

function M:entry()
	ya.exec("stash", { get_cwd(), source = "cd" })
	ya.emit("back", {})
end
return M
