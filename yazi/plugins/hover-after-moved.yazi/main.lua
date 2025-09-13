--- @since 25.5.31

local PackageName = "hover-after-moved"

local M = {}

function M:setup()
	ps.sub("move", function(payload)
		if payload.items and #payload.items > 0 then
			ya.emit("reveal", {
				payload.items[1].to,
				no_dummy = true,
				raw = true,
				tab = (type(cx.active.id) == "number" or type(cx.active.id) == "string") and cx.active.id
					or cx.active.id.value,
			})
		end
	end)
end

return M
