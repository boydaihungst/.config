local M = {}

local function save_stash(args)
	if args.source == "tab" or args.source == "cd" then
		return args -- Returns `args` as is to allow stashing this time
	elseif args.source == "search" then
		ya.emit("stash", { cx.active.current.cwd, source = "cd" })
	end
end

function M:setup()
	ps.sub("ind-stash", save_stash) -- Triggered when the `stash` command is called on `cd`
	ps.sub("relay-stash", save_stash) -- Triggered when the `stash` command is called on interactive `cd`
end

return M
