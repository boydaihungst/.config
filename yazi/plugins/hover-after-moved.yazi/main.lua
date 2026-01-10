--- @since 25.5.31

local PackageName = "hover-after-moved"

local M = {}

function M:setup()
	ps.sub("@yank", function(_)
		ps.unsub("move")
		ps.unsub("duplicate")
		ps.sub("duplicate", function(payload)
			if not payload then
				ps.unsub("duplicate")
				return
			end
			if payload.items and #payload.items > 0 then
				local is_virtual = Url(cx.active.current.cwd).scheme and Url(cx.active.current.cwd).scheme.is_virtual
				if
					cx.active.current.cwd
					and Url(is_virtual and cx.active.current.cwd or cx.active.current.cwd.path)
						== payload.items[1].to.parent
				then
					ya.emit("reveal", {
						payload.items[1].to,
						no_dummy = true,
						raw = true,
						tab = cx.active.id.value,
					})
					return
				end
			end
			ps.unsub("duplicate")
		end)

		ps.sub("move", function(payload)
			if not payload then
				ps.unsub("move")
				return
			end

			if payload.items and #payload.items > 0 then
				local is_virtual = Url(cx.active.current.cwd).scheme and Url(cx.active.current.cwd).scheme.is_virtual
				if
					cx.active.current.cwd
					and Url(is_virtual and cx.active.current.cwd or cx.active.current.cwd.path)
						== payload.items[1].to.parent
				then
					ya.emit("reveal", {
						payload.items[1].to,
						no_dummy = true,
						raw = true,
						tab = cx.active.id.value,
					})
					return
				end
			end
			ps.unsub("move")
		end)
	end)
end

return M
