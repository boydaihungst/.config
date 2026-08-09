--- @sync entry
--- @since 25.5.31

return {
	entry = function()
		ya.emit("escape", { visual = true })
		local selected_items = cx.active.selected
		if #selected_items >= 1 then
			for _, f in pairs(selected_items) do
				local u = f.url or f
				local is_virtual = (u.spec and u.spec.is_virtual) or (not u.spec and u.scheme.is_virtual)
				if is_virtual then
					ya.dbg("thunar-bulk-rename", "Thunar rename doesn't support virtual file system")
					ya.emit("rename", { hovered = false, cursor = "before_ext" })
					return
				end
			end
			ya.emit("shell", { "thunar -B %s", block = true, confirm = true })
		else
			ya.emit("rename", { hovered = false, cursor = "before_ext" })
		end
	end,
}
