--- @sync entry
--- @since 25.5.31

return {
	entry = function()
		ya.emit("escape", { visual = true })
		local selected_items = cx.active.selected
		if #selected_items >= 1 then
			local selected_urls = ""
			for _, v in pairs(selected_items) do
				local is_virtual = v.scheme and v.scheme.is_virtual
				if is_virtual then
					ya.dbg("thunar-bulk-rename", "Thunar rename doesn't support virtual file system")
					ya.emit("rename", { hovered = false, cursor = "before_ext" })
					return
				end
				selected_urls = selected_urls .. ya.quote(tostring(v))
			end
			ya.emit("shell", { "thunar -B %s", block = true, confirm = true })
		else
			ya.emit("rename", { hovered = false, cursor = "before_ext" })
		end
	end,
}
