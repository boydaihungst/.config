local msg = require("mp.msg")
local function select_smart_audio()
	local track_list = mp.get_property_native("track-list")
	-- Get alang from mpv.conf (returns a string like "jpn,eng")
	local alang_pref = mp.get_property("options/alang", "")

	local preferred_langs = {}
	for lang in string.gmatch(alang_pref, "([^,]+)") do
		table.insert(preferred_langs, lang)
	end

	local best_aid = nil
	local best_priority = 999 -- Lower is better (index in preferred_langs)

	for _, track in ipairs(track_list) do
		if track.type == "audio" then
			local codec = track.codec or ""
			local title = (track.title or ""):lower()
			local lang = (track.lang or ""):lower()

			-- Condition: Codec is AC3 or DTS, and NOT a commentary track
			if (codec == "ac3" or codec == "dts") and not title:find("commentary") then
				-- Check language priority
				local current_priority = 998 -- Default for tracks with no/wrong language
				for i, pref in ipairs(preferred_langs) do
					if lang == pref:lower() then
						current_priority = i
						break
					end
				end

				-- Update best track if this one has higher language priority
				if current_priority < best_priority then
					best_priority = current_priority
					best_aid = track.id
				end

				-- If we found the #1 preferred language, we can stop searching
				if best_priority == 1 then
					break
				end
			end
		end
	end

	if best_aid then
		msg.info("Found compatible track (ID: " .. best_aid .. ") matching alang priority. Switching...")
		mp.set_property("aid", best_aid)
		mp.commandv("af", "clr", "")
	else
		msg.info("No compatible AC3/DTS track found for preferred languages. Enabling AC3 encoder.")
		mp.commandv("af", "set", "lavcac3enc=yes:640:6")
	end
end

mp.register_event("file-loaded", select_smart_audio)
