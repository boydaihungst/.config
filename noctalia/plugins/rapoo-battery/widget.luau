--! nonstrict

local function updateBattery()
	-- Settings are fetched via noctalia.getSetting()
	local glyph = noctalia.getConfig("glyph")
	local glyph_charging = noctalia.getConfig("glyph_charging")
	local device = noctalia.getConfig("device") or ""
	local interval = tonumber(noctalia.getConfig("interval")) or 120

	noctalia.setUpdateInterval(interval * 1000)

	local cmd = { "timeout", "-k", "10s", "10s", "rapoo-battery", "--json" }
	if device ~= "" then
		table.insert(cmd, "--device")
		table.insert(cmd, device)
	end

	noctalia.runAsync(cmd, function(result)
		if result.exitCode ~= 0 then
			barWidget.setVisible(false)
		elseif result.stdout then
			barWidget.setVisible(true)
			local percentMatch = result.stdout:match('"battery_percent"%s*:%s*(%d+)')
			local chargingMatch = result.stdout:match('"charging"%s*:%s*(%w+)')

			if percentMatch then
				local percent = percentMatch
				local isCharging = (chargingMatch == "true")

				-- barWidget.setText(percent .. "%")
				barWidget.setTooltip(
					"Rapoo Mouse: " .. percent .. "%" .. (isCharging and " (Charging)" or " (Discharging)")
				)
				barWidget.setText(percent .. "%")
				barWidget.setGlyph(isCharging and glyph_charging or glyph)
			end
		end
	end)
end

function update()
	updateBattery()
end

function onClick()
	updateBattery()
end
