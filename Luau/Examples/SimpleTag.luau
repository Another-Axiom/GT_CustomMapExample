timer = os.clock()
tagCoolDown = 0
lastPlayerCount = 0

function allNotTagged()
	for index, ply in ipairs(Players) do
		if ply.PlayerMaterial ~= 0 then
			return false
		end
	end
	return true
end

function tick(dt)
	if InRoom then
		if os.clock() - timer >= 2 then
			if #Players == 1 then
				LocalPlayer.playerMaterial = 1
			else
				emitEvent("whoTagged", { 1 })
			end
		end
		if tagCoolDown ~= 0 and os.clock() - tagCoolDown >= 2 then
			if LocalPlayer.playerMaterial == 2 then
				LocalPlayer.playerMaterial = 1
			end
			tagCoolDown = 0
		end
	end

	if LocalPlayer.isMasterClient and lastPlayerCount ~= #Players then
		if allNotTagged() then
			local n = math.random(1, #Players)
			emitEvent("tagEvent", { Players[n], LocalPlayer })
			onEvent("tagEvent", { Players[n], LocalPlayer })
		end
	end

	lastPlayerCount = #Players
end

function onEvent(event, data)
	if event == "touchedPlayer" then
		if LocalPlayer.playerMaterial == 1 then
			emitEvent("tagEvent", { data, LocalPlayer })
			onEvent("tagEvent", { data, LocalPlayer })
		end
	end

	if event == "tagEvent" then
		data[1].playerMaterial = 1
		if data[2] ~= nil then
			data[2].playerMaterial = 0
		end
		if data[1] == LocalPlayer then
			tagCoolDown = os.clock()
			data[1].playerMaterial = 2
		end
	end

	if event == "imTagged" then
		data[1].playerMaterial = 1
	end

	if event == "whoTagged" then
		if LocalPlayer.playerMaterial == 1 then
			emitEvent("imTagged", { LocalPlayer })
		end
	end
end
