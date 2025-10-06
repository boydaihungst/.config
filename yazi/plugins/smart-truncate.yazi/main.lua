--- @since 25.5.31
--- @sync peek

local M = {}

local function to_unique_set(t)
	local result = {}
	for _, v in ipairs(t) do
		if type(v) == "number" then
			result[v] = true
		end
	end
	return result
end

function M:is_literal_string(str)
	return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

local function utf8_sub(str, start_char, end_char)
	local start_byte = utf8.offset(str, start_char) -- Expects start_char to be a character index
	local end_byte = end_char and (utf8.offset(str, end_char + 1) or (#str + 1)) - 1 -- Expects end_char
	if not start_byte then
		return ""
	end
	return str:sub(start_byte, end_byte)
end

local function utf8_remove_last_ellipsis(str)
	local len = 0
	for _ in utf8.codes(str) do
		len = len + 1
	end
	if len == 0 then
		return ""
	end

	-- Get last character codepoint
	local last_char_start = utf8.offset(str, -1)
	local last_char = str:sub(last_char_start)

	if last_char == "…" then
		-- Remove last character
		return utf8_sub(str, 1, len - 1)
	else
		return str
	end
end

local function remove_suffix(str, suffix)
	if suffix == "" then
		return str
	end
	local str_len = utf8.len(str)
	local suffix_len = utf8.len(suffix)
	local end_of_str = utf8_sub(str, str_len - suffix_len + 1, str_len)
	if end_of_str == suffix then
		return utf8_sub(str, 1, str_len - suffix_len)
	else
		return str
	end
end

---shorten string
---@param max_width number max characters
---@param long_string_without_suffix string string
---@param suffix? string file extentions or any thing which will shows at the end when file is truncated
---@return string
local function shorten_suffix(max_width, long_string_without_suffix, suffix)
	suffix = suffix or ""
	max_width = max_width < 0 and 0 or max_width
	long_string_without_suffix = long_string_without_suffix or ""
	local long_string_length = ui.Line(long_string_without_suffix .. suffix):width()

	if long_string_length <= max_width then
		return long_string_without_suffix .. suffix
	end

	-- local long_string_without_suffix = remove_suffix(long_string_without_suffix, suffix)
	local original_suffix = suffix
	suffix = "…" .. suffix
	local suffix_len = ui.Line(suffix):width()

	local cut_width = max_width - suffix_len

	if cut_width == 0 then
		suffix = utf8_sub(suffix, 1, max_width)
		return suffix
	elseif cut_width < 0 then
		suffix = utf8_sub(suffix, 1, max_width - 1)
		return suffix .. "…"
	end

	--TODO: remove this after next yazi released
	local result = (ui.truncate or ya.truncate)(long_string_without_suffix, { max = cut_width + 1 })
	if string.find(result, "…$") then
		return result .. original_suffix
	end
	return result .. suffix
end

local function shortern_array_strings(
	array_strings,
	usable_space,
	resize_order,
	last_component_idx,
	list_display_order_hidden
)
	local count_resizable_part = 0
	local count_resizable_part_higher_order_length = 0
	list_display_order_hidden = list_display_order_hidden or {}

	for i = #array_strings, 1, -1 do
		if not array_strings[i] or utf8.len(array_strings[i].segment) == 0 then
			table.remove(array_strings, i)
		else
			if array_strings[i].resize_order == resize_order then
				count_resizable_part = count_resizable_part + 1
			end
			if array_strings[i].resize_order > resize_order then
				count_resizable_part_higher_order_length = count_resizable_part_higher_order_length
					+ array_strings[i].length
			end
		end
	end

	usable_space = usable_space - count_resizable_part_higher_order_length

	-- calculate max_length for each resizable component/children
	for idx, str_part in ipairs(array_strings) do
		if str_part.resize_order == resize_order then
			if usable_space <= 1 then
				-- usable_space = usable_space + 1
				if str_part.length >= 1 then
					if usable_space + count_resizable_part_higher_order_length > 0 then
						count_resizable_part_higher_order_length = count_resizable_part_higher_order_length - 1
						array_strings[idx].max_length = 1
						array_strings[idx].segment_shortened = "…"
					else
						array_strings[idx].max_length = 0
						array_strings[idx].segment_shortened = ""
					end
				else
					array_strings[idx].max_length = 0
					array_strings[idx].segment_shortened = ""
				end
			elseif str_part.length <= usable_space - count_resizable_part then
				array_strings[idx].max_length = str_part.length
				array_strings[idx].segment_shortened = str_part.segment
			else
				array_strings[idx].max_length = math.abs(usable_space - count_resizable_part)
				if array_strings[idx].max_length <= 0 then
					array_strings[idx].max_length = 1
				end
				array_strings[idx].segment_shortened =
					shorten_suffix(array_strings[idx].max_length, array_strings[idx].segment)
			end

			count_resizable_part = count_resizable_part - 1
			::recheck::
			if
				array_strings[idx].segment_shortened == "^…"
				and array_strings[idx - 1]
				and array_strings[idx - 1].segment_shortened
			then
				if string.match(array_strings[idx - 1].segment_shortened, ".+…$") then
					array_strings[idx - 1].segment_shortened =
						utf8_remove_last_ellipsis(array_strings[idx - 1].segment_shortened)
					array_strings[idx - 1].max_length = array_strings[idx - 1].max_length - 1
					usable_space = usable_space + 1
					array_strings[idx].max_length = array_strings[idx].max_length + 1
					array_strings[idx].segment_shortened =
						shorten_suffix(array_strings[idx].max_length, array_strings[idx].segment)
					goto recheck
					-- end
				elseif array_strings[idx - 1].segment_shortened == "…" then
					array_strings[idx - 1].segment_shortened = ""
					array_strings[idx - 1].max_length = 0
					usable_space = usable_space + 1
					array_strings[idx].max_length = array_strings[idx].max_length + 1
					array_strings[idx].segment_shortened =
						shorten_suffix(array_strings[idx].max_length, array_strings[idx].segment)
					goto recheck
				end
			elseif string.match(array_strings[idx].segment_shortened, "…$") then
				if array_strings[idx + 1] and array_strings[idx + 1].segment_shortened == "…" then
					array_strings[idx + 1].segment_shortened = ""
					array_strings[idx + 1].max_length = 0
					usable_space = usable_space + 1
					array_strings[idx].max_length = array_strings[idx].max_length + 1
					array_strings[idx].segment_shortened =
						shorten_suffix(array_strings[idx].max_length, array_strings[idx].segment)
				end
			end
			usable_space = usable_space - array_strings[idx].max_length
		end
	end
	usable_space = usable_space + count_resizable_part_higher_order_length

	-- add left over space to last/longest length resizable component
	if usable_space > 0 then
		if resize_order == 3 then
			for _resize_order = 3, 1, -1 do
				if usable_space <= 0 then
					break
				end
				for idx, str_part in ipairs(array_strings) do
					if str_part.resize_order == _resize_order and str_part.max_length < str_part.length then
						if array_strings[idx].max_length + usable_space >= array_strings[idx].length then
							usable_space = usable_space - (array_strings[idx].length - array_strings[idx].max_length)
							array_strings[idx].max_length = array_strings[idx].length
						else
							array_strings[idx].max_length = array_strings[idx].max_length + usable_space
							usable_space = 0
						end
						array_strings[idx].segment_shortened =
							shorten_suffix(array_strings[idx].max_length, array_strings[idx].segment)
					end
				end
			end
		else
			array_strings = shortern_array_strings(
				array_strings,
				usable_space,
				resize_order + 1,
				last_component_idx,
				list_display_order_hidden
			)
		end
	end

	return array_strings
end

---@param max_width number max characters
---@param string_with_suffix string string
---@param suffix? string file extentions or any thing which will shows at the end when file is truncated
---@param always_show_patterns? string[] anystring match one of this lua patterns will be always show when file is truncated, unless the space is not enough
---@return string
function M:shorten(max_width, string_with_suffix, suffix, always_show_patterns)
	-- Remove empty pattern
	if always_show_patterns ~= nil then
		for i = #always_show_patterns, 1, -1 do
			if not always_show_patterns[i] == "" or utf8.len(always_show_patterns[i]) == 0 then
				table.remove(always_show_patterns, i)
			end
		end
	end

	suffix = suffix or ""
	max_width = max_width or 0
	local string_without_suffix = remove_suffix(string_with_suffix, suffix) or ""
	if not always_show_patterns or #always_show_patterns == 0 or max_width <= utf8.len("…" .. suffix) then
		return shorten_suffix(max_width, string_without_suffix, suffix)
	end

	local result_with_order_flags = {}
	local last_byte_end = 1
	local byte_input_len = #string_without_suffix

	local display_order = 0
	-- Collect all matches from all patterns
	local matches = {}

	for _, pat in ipairs(always_show_patterns) do
		for byte_start_pos, byte_end_pos in string_without_suffix:gmatch("()" .. pat .. "()") do
			table.insert(matches, { start = byte_start_pos, stop = byte_end_pos })
		end
	end

	-- Sort matches by start position
	table.sort(matches, function(a, b)
		return a.start < b.start
	end)

	-- Remove overlapping matches (optional, based on use case)
	local non_overlapping = {}
	local last_end = 0
	for _, m in ipairs(matches) do
		if m.start >= last_end then
			table.insert(non_overlapping, m)
			last_end = m.stop
		end
	end

	-- Process matched and unmatched segments
	for _, m in ipairs(non_overlapping) do
		local byte_start_pos = m.start
		local byte_end_pos = m.stop

		if byte_start_pos > last_byte_end then
			display_order = display_order + 1
			local unmatched = string_without_suffix:sub(last_byte_end, byte_start_pos - 1)
			table.insert(result_with_order_flags, {
				segment = unmatched,
				length = utf8.len(unmatched),
				resize_order = 1,
				display_order = display_order,
			})
		end

		display_order = display_order + 1
		local matched = string_without_suffix:sub(byte_start_pos, byte_end_pos - 1)
		table.insert(result_with_order_flags, {
			segment = matched,
			length = utf8.len(matched),
			resize_order = 2,
			display_order = display_order,
		})

		last_byte_end = byte_end_pos
	end

	-- Add any remaining non-matching tail
	if last_byte_end <= byte_input_len then
		display_order = display_order + 1
		local segment = string_without_suffix:sub(last_byte_end)
		table.insert(result_with_order_flags, {
			segment = segment,
			length = utf8.len(segment),
			resize_order = 1,
			display_order = display_order,
		})
	end

	-- Case not matched any pattern
	if #result_with_order_flags == 1 then
		return shorten_suffix(max_width, string_without_suffix, suffix)
	end

	if suffix and utf8.len(suffix) > 0 then
		table.insert(
			result_with_order_flags,
			{ segment = suffix, length = utf8.len(suffix), resize_order = 3, display_order = display_order + 1 }
		)
	end

	result_with_order_flags = shortern_array_strings(result_with_order_flags, max_width, 1)
	local final_result = ""
	for _, item in ipairs(result_with_order_flags) do
		if item.segment_shortened then
			final_result = final_result .. item.segment_shortened
		end
	end
	return final_result
end

--- Function to truncate entity
---@class entity Entity created entity object. For example: `local entity = Entity:new(f)`
---@param max_width number max width of the area entity will be rendered. For example: `area.w`
function M:smart_truncate_entity(entity, max_width)
	local thisPlugin = self
	entity._components = {}
	local resizable_entity_children_ids_set = to_unique_set(thisPlugin.resizable_entity_children_ids)
	if thisPlugin.resizable_entity_children_ids and #thisPlugin.resizable_entity_children_ids > 0 then
		-- Override Entity.render function for this entity
		entity.redraw = function(entity_self)
			-- length of resizable entity's component/children
			local total_length_resizable = 0
			-- length of unresizable entity's component/children
			local total_length_unresizable = 0
			local count_resizable_component_with_length_not_zero = 0

			if not entity_self._components then
				entity_self._components = {}
			end
			-- loop through all entity children
			for _, c in ipairs(entity_self._children) do
				local child_component = ui.Line((type(c[1]) == "string" and entity_self[c[1]] or c[1])(entity_self))
					:style(entity_self:style())
				if not entity_self._components[c.id] then
					entity_self._components[c.id] = {}
				end
				entity_self._components[c.id].length = child_component:width()
				-- add some metadata for this commponent/children
				if resizable_entity_children_ids_set[c.id] and entity_self._components[c.id].length > 0 then
					entity_self._components[c.id].max_length = 0
					total_length_resizable = total_length_resizable + entity_self._components[c.id].length
					entity_self._components[c.id].resizable = true
					count_resizable_component_with_length_not_zero = count_resizable_component_with_length_not_zero + 1
				else
					entity_self._components[c.id].resizable = false
					total_length_unresizable = total_length_unresizable + entity_self._components[c.id].length
					entity_self._components[c.id].max_length = entity_self._components[c.id].length
				end
			end

			local usable_space = max_width - total_length_unresizable
			local max_length_size_each_component = count_resizable_component_with_length_not_zero <= 1 and usable_space
				or (usable_space / count_resizable_component_with_length_not_zero)
			local last_component_id

			-- Convert the table to an array of key-value pairs
			local components_array = {}
			for id, metadata in pairs(entity_self._components) do
				table.insert(components_array, { id = id, metadata = metadata })
			end
			-- sort by length, then calculate max_length for each resizable component/children
			table.sort(components_array, function(a, b)
				return a.metadata.length < b.metadata.length
			end)
			local avg_usable_space = -1
			-- calculate max_length for each resizable component/children
			for _, c in ipairs(components_array) do
				if c.metadata.resizable then
					if c.metadata.length <= max_length_size_each_component then
						entity_self._components[c.id].max_length = c.metadata.length
						count_resizable_component_with_length_not_zero = count_resizable_component_with_length_not_zero
							- 1
					else
						if avg_usable_space == -1 then
							avg_usable_space = usable_space / count_resizable_component_with_length_not_zero
						end
						entity_self._components[c.id].max_length = math.floor(avg_usable_space)
					end

					usable_space = usable_space - entity_self._components[c.id].max_length
					last_component_id = c.id
				end
			end
			-- add left over space to last/longest length resizable component
			if usable_space > 0 and last_component_id then
				entity_self._components[last_component_id].max_length = entity_self._components[last_component_id].max_length
					+ usable_space
			end

			local lines = {}
			for _, c in ipairs(entity_self._children) do
				if
					entity_self._components[c.id]
					and entity_self._components[c.id].resizable
					and thisPlugin.children_callbacks[c.id]
				then
					lines[#lines + 1] = thisPlugin.children_callbacks[c.id](entity_self)
				else
					lines[#lines + 1] = (type(c[1]) == "string" and entity_self[c[1]] or c[1])(entity_self)
				end
			end
			return ui.Line(lines):style(entity_self:style())
		end
	end
end

function M:render_parent_entities()
	local thisPlugin = self
	function Parent:redraw()
		if not self._folder then
			return {}
		end

		local items = {}
		local parent_tab_window_w = self._area.w
		for _, f in ipairs(self._folder.window) do
			local entity = Entity:new(f)
			thisPlugin:smart_truncate_entity(entity, parent_tab_window_w)
			items[#items + 1] = ui.Line({ entity:redraw() }):style(entity:style())
		end

		return {
			ui.List(items):area(self._area),
		}
	end
end

function M:render_current_entities()
	local thisPlugin = self
	function Current:redraw()
		local files = self._folder.window
		if #files == 0 then
			return self:empty()
		end

		local current_tab_window_w = self._area.w

		local entities, linemodes = {}, {}
		for _, f in ipairs(files) do
			local entity = Entity:new(f)
			local linemode_rendered = Linemode:new(f):redraw()
			local linemode_char_length = linemode_rendered:align(ui.Align.RIGHT):width()
			-- smart truncate
			thisPlugin:smart_truncate_entity(entity, current_tab_window_w - linemode_char_length)
			entities[#entities + 1] = ui.Line({ entity:redraw() }):style(entity:style())
			linemodes[#linemodes + 1] = linemode_rendered
		end

		return {
			ui.List(entities):area(self._area),
			ui.Text(linemodes):area(self._area):align(ui.Align.RIGHT),
		}
	end
end

function M:peek(job)
	local folder = cx.active.preview.folder
	if not folder or folder.cwd ~= job.file.url then
		return
	end

	local bound = math.max(0, #folder.files - job.area.h)
	if job.skip > bound then
		return ya.emit("peek", { bound, only_if = job.file.url, upper_bound = true })
	end

	if #folder.files == 0 then
		local done, err = folder.stage()
		local s = not done and "Loading..." or not err and "No items" or string.format("Error: %s", err)
		return ya.preview_widget(job, ui.Line(s):area(job.area):align(ui.Align.CENTER))
	end

	local entities = {}
	for _, f in ipairs(folder.window) do
		local entity = Entity:new(f)
		-- smart truncate
		self:smart_truncate_entity(entity, job.area.w)
		entities[#entities + 1] = ui.Line({ entity:redraw() }):style(entity:style())
	end

	ya.preview_widget(job, {
		ui.List(entities):area(job.area),
		table.unpack(Marker:new(job.area, folder):redraw()),
	})
end

function M:seek(job)
	local folder = cx.active.preview.folder
	if folder and folder.cwd == job.file.url then
		local step = math.floor(job.units * job.area.h / 10)
		local bound = math.max(0, #folder.files - job.area.h)
		ya.emit("peek", {
			ya.clamp(0, cx.active.preview.skip + step, bound),
			only_if = job.file.url,
		})
	end
end

function M:render_entities()
	if self.render_parent then
		self:render_parent_entities()
	end
	if self.render_current then
		self:render_current_entities()
	end
end

function Entity:get_component_max_length(component_id_or_fn_name)
	if type(component_id_or_fn_name) == "string" then
		component_id_or_fn_name = Entity:get_component_id_by_fn_name(component_id_or_fn_name)
	end
	return self._components
		and self._components[component_id_or_fn_name]
		and self._components[component_id_or_fn_name].max_length
end

function Entity:get_component_id_by_fn_name(component_fn_name)
	for _, c in ipairs(self._children) do
		if type(c[1]) == "string" and c[1] == component_fn_name then
			return c.id
		end
	end
end

function M:init_default_callbacks(always_show_patterns)
	local thisPlugin = self
	thisPlugin:children_add("highlights", function(entity_self)
		-- override these resizeable components/children render function then re-render the whole entity with truncated/shortened value
		local suffix = ""
		local shortened_name
		local name = entity_self._file.name:gsub("\r", "?", 1)

		---------------------------
		-- get max_length if highlight is resizable
		local max_length = entity_self:get_component_max_length("highlights") or 0
		if entity_self._file.cha.is_dir then
			shortened_name = M:shorten(max_length, name, "", always_show_patterns)
		else
			local ext = entity_self._file.url.ext

			suffix = (not ext or ext == "") and "" or ("." .. ext)
			shortened_name = M:shorten(max_length, name, suffix, always_show_patterns)
		end

		local highlights = entity_self._file:highlights()
		if not highlights or #highlights == 0 then
			return shortened_name
		end

		-- This will run when use find command
		---@see https://yazi-rs.github.io/docs/configuration/keymap#mgr.find
		local matched_keyword = {}

		for _, h in ipairs(highlights) do
			matched_keyword[#matched_keyword + 1] = name:sub(h[1] + 1, h[2])
		end

		-- NOTE: Manually check find matched keyword
		if #matched_keyword > 0 then
			local result_with_matched_highlighted = {}
			local current_byte_cursor = 1 -- Start of the next segment to process (byte index)
			local byte_input_len = #shortened_name

			-- Collect all matches from all patterns
			local matches = {}
			for _, pat in ipairs(matched_keyword) do
				-- Ensure pat is treated as a literal string for the pattern
				local literal_pat = thisPlugin:is_literal_string(pat)
				if literal_pat ~= "" then -- Avoid empty patterns if is_literal_string could return one
					for byte_start_pos, byte_end_pos_after_match in shortened_name:gmatch("()" .. literal_pat .. "()") do
						table.insert(matches, { start = byte_start_pos, stop = byte_end_pos_after_match })
					end
				end
			end

			-- Sort matches by start position
			table.sort(matches, function(a, b)
				return a.start < b.start
			end)

			-- Remove overlapping matches
			local non_overlapping = {}
			local last_match_byte_end = 0
			for _, m in ipairs(matches) do
				if m.start >= last_match_byte_end then
					table.insert(non_overlapping, m)
					last_match_byte_end = m.stop
				end
			end

			-- Process matched and unmatched segments using byte offsets with string.sub
			for _, m in ipairs(non_overlapping) do
				local match_start_byte = m.start -- Byte index where match begins
				local match_end_byte_after = m.stop -- Byte index *after* the end of the match

				-- Unmatched segment before the current match
				if match_start_byte > current_byte_cursor then
					local unmatched_segment = shortened_name:sub(current_byte_cursor, match_start_byte - 1)
					table.insert(result_with_matched_highlighted, unmatched_segment)
				end

				-- Matched segment
				local matched_segment_text = shortened_name:sub(match_start_byte, match_end_byte_after - 1)
				local styled_matched_segment = ui.Span(matched_segment_text):style(th.mgr.find_keyword)
				table.insert(result_with_matched_highlighted, styled_matched_segment)

				current_byte_cursor = match_end_byte_after -- Move cursor to position after current match
			end

			-- Add any remaining non-matching tail segment
			if current_byte_cursor <= byte_input_len then
				local tail_segment = shortened_name:sub(current_byte_cursor) -- from cursor to end
				table.insert(result_with_matched_highlighted, tail_segment)
			end

			if #result_with_matched_highlighted <= 1 then
				return ui.Line(shortened_name)
			end
			return ui.Line(result_with_matched_highlighted)
		end
	end)

	thisPlugin:children_add("symlink", function(entity_self)
		-- override these resizeable components/children render function then re-render the whole entity with truncated/shortened value

		-- override symlink Entity:symlink function
		if not rt.mgr.show_symlink then
			return ""
		end

		local link_to = entity_self._file.link_to
		if not link_to then
			return ""
		end

		local prefix = " -> "
		local max_length = entity_self:get_component_max_length("symlink") or 0

		local to_extension = link_to.ext
		local suffix = (not to_extension or to_extension == "") and "" or ("." .. to_extension)
		local shortened = M:shorten(max_length, prefix .. tostring(link_to), suffix, always_show_patterns)

		return ui.Span(shortened):style(th.mgr.symlink_target)
	end)
end

function M:is_setup_loaded()
	return self.setup_loaded
end

function M:setup(opts)
	self.resizable_entity_children_ids = {}
	local always_show_patterns = nil
	if type(opts) == "table" then
		self.render_parent = opts.render_parent ~= nil and opts.render_parent
		self.render_current = opts.render_current ~= nil and opts.render_current
		if type(opts.resizable_entity_children_ids) == "table" then
			self.resizable_entity_children_ids = opts.resizable_entity_children_ids
		end
		if type(opts.always_show_patterns) == "table" then
			always_show_patterns = opts.always_show_patterns
		end
	end
	self.children_callbacks = {}
	self:init_default_callbacks(always_show_patterns)
	self:render_entities()
	self.setup_loaded = true
end

--- Add a callback function for a component
---@param children string|number component/children id or children function name. For example: `"highlights"` or `4` or `"symlink"` or `6`
---@param callback function callback function when component/children is resized
function M:children_add(children, callback)
	if type(children) == "string" then
		children = Entity:get_component_id_by_fn_name(children)
		if not children then
			return
		end
	end
	self.resizable_entity_children_ids[#self.resizable_entity_children_ids + 1] = children
	self.children_callbacks[children] = callback
	self:render_entities()
end

function M:children_remove(children)
	if type(children) == "string" then
		children = Entity:get_component_id_by_fn_name(children)
		if not children then
			return
		end
	end

	for idx, id in ipairs(self.resizable_entity_children_ids) do
		if id == children then
			table.remove(self.resizable_entity_children_ids, idx)
			table.remove(self.children_callbacks, children)
			self:render_entities()
			return
		end
	end
end

return M
