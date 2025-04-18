startTime = os.clock() -- Timers
buttonTimeout = os.clock()
tagTimeout = os.clock()

redTeamButton = GameObject.findGameObject("redTeamButton") -- Access our gameobjects
redTeamText = GameObject.findGameObject("redTeamText")
blueTeamButton = GameObject.findGameObject("blueTeamButton")
blueTeamText = GameObject.findGameObject("blueTeamText")
leaveTeamButton = GameObject.findGameObject("leaveTeamButton")
redTeamTimeText = GameObject.findGameObject("redTeamTime")
blueTeamTimeText = GameObject.findGameObject("blueTeamTime")
startGameButton = GameObject.findGameObject("startButton")

startGameButton:setCollision(false) -- Disable collision to act as buttons
startGameButton:setActive(false)
leaveTeamButton:setCollision(false)
redTeamButton:setCollision(false)
blueTeamButton:setCollision(false)
leaveTeamButton:setActive(false)

redTeamButtonOutside = GameObject.findGameObject("redTeamButtonOutside")
redTeamTextOutside = GameObject.findGameObject("redTeamTextOutside")
blueTeamButtonOutside = GameObject.findGameObject("blueTeamButtonOutside")
blueTeamTextOutside = GameObject.findGameObject("blueTeamTextOutside")
leaveTeamButtonOutside = GameObject.findGameObject("leaveTeamButtonOutside")
redTeamTimeTextOutside = GameObject.findGameObject("redTeamTimeOutside")
blueTeamTimeTextOutside = GameObject.findGameObject("blueTeamTimeOutside")
startGameButtonOutside = GameObject.findGameObject("startButtonOutside")

startGameButtonOutside:setCollision(false)
startGameButtonOutside:setActive(false)
leaveTeamButtonOutside:setCollision(false)
redTeamButtonOutside:setCollision(false)
blueTeamButtonOutside:setCollision(false)
leaveTeamButtonOutside:setActive(false)

redTeamButtonEnabled = true -- Bool for if we should process button input
blueTeamButtonEnabled = true
leaveTeamButtonEnabled = false
startGameButtonEnabled = false
redTeamIndex = 1 -- Indexes for player materials, tag, lava, ice etc. Used to represent teams in game
redTeamTaggedIndex = 2
blueTeamIndex = 3
blueTeamTaggedIndex = 14
taggedIndex = 12
redTeamStartTime = 0 -- Global variables for later timer use.
blueTeamStartTime = 0
redTeamTime = 0
blueTeamTime = 0

gameStarted = false -- Info for gamestate
gameState = 0

synced = false

lastPlayerCount = 0

local DelayedFunctions = {} -- Table/Array to store functions and timers

function setTimeout(delay, func) -- take in a delay and a callback function
	local timeout = {
		endTime = os.clock() + delay,
		callback = func,
	}
	table.insert(DelayedFunctions, timeout)
end

function handleTimeouts() -- Process timeouts each tick to see if they are ready to be called
	local currentTime = os.clock()

	for i = #DelayedFunctions, 1, -1 do
		local timeout = DelayedFunctions[i]

		if currentTime >= timeout.endTime then
			timeout.callback()
			table.remove(DelayedFunctions, i)
		end
	end
end

setTimeout(1, function() -- Inital room check, gathers state from others.
	if not LocalPlayer.isMasterClient then -- If were the masterClient then its a new room and theres nothing to collect
		emitEvent("requestState", { 0 })
	else
		synced = true
	end
end)

function teamIndex(ply) -- Function for determining a players team from their player material 0 none, 1 red, 2 blue etc.
	if ply.playerMaterial == redTeamIndex or ply.playerMaterial == redTeamTaggedIndex then
		return 1
	end
	if ply.playerMaterial == blueTeamIndex or ply.playerMaterial == blueTeamTaggedIndex then
		return 2
	end
	if ply.playerMaterial == 12 then
		if gameState == 2 or gameState == 3 then
			return 1
		end
		if gameState == 4 or gameState == 0 then
			return 2
		else
			ply.playerMaterial = 0
		end
	end
	return 0
end

function formatTime(t) -- Simple time formatter for displaying on boards.
	local minutes = math.floor(t / 60)
	local seconds = math.floor(t % 60)
	local milliseconds = math.floor((t % 1) * 1000)
	return string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
end

function canPressButtons() -- Timeout for buttons, only allows any button to be pressed every 0.5 seconds
	if os.clock() - buttonTimeout >= 0.5 then
		buttonTimeout = os.clock()
		return true
	else
		return false
	end
end

function isButtonPressed(gameObject) -- Button to determine if a hand is within the bounds of a gameobject, used as buttons.
	local leftOffset = Vec3.new(-0.056, 0.168, 0) -- Get aproxamate finger location rather than base of hand
	leftOffset = Vec3.rotate(leftOffset, LocalPlayer.leftHandRotation)
	local rightOffset = Vec3.new(0.056, 0.168, 0)
	rightOffset = Vec3.rotate(rightOffset, LocalPlayer.rightHandRotation)
	local leftHand = leftOffset + LocalPlayer.leftHandPosition
	local rightHand = rightOffset + LocalPlayer.rightHandPosition

	local minBounds = gameObject.position - (gameObject.scale * 0.5)
	local maxBounds = gameObject.position + (gameObject.scale * 0.5)

	local function isWithinBounds(hand)
		return hand.x >= minBounds.x
			and hand.x <= maxBounds.x
			and hand.y >= minBounds.y
			and hand.y <= maxBounds.y
			and hand.z >= minBounds.z
			and hand.z <= maxBounds.z
	end

	return isWithinBounds(leftHand) or isWithinBounds(rightHand)
end

function refreshButtons() -- Set button states, visible, pressable etc.
	if gameStarted then
		leaveTeamButton:setActive(false)
		redTeamButton:setActive(false)
		blueTeamButton:setActive(false)
		startGameButton:setActive(false)

		leaveTeamButtonOutside:setActive(false)
		redTeamButtonOutside:setActive(false)
		blueTeamButtonOutside:setActive(false)
		startGameButtonOutside:setActive(false)

		leaveTeamButtonEnabled = false
		redTeamButtonEnabled = false
		blueTeamButtonEnabled = false
		startGameButtonEnabled = false
		return
	end

	local redCount = 0
	local blueCount = 0

	for index, ply in ipairs(Players) do
		if teamIndex(ply) == 1 then
			redCount += 1
		end
		if teamIndex(ply) == 2 then
			blueCount += 1
		end
	end
	if redCount >= 1 and blueCount >= 1 then
		startGameButtonEnabled = true
		startGameButton:setActive(true)
		startGameButtonOutside:setActive(true)
	else
		startGameButtonEnabled = false
		startGameButton:setActive(false)
		startGameButtonOutside:setActive(false)
	end

	if teamIndex(LocalPlayer) == 1 or teamIndex(LocalPlayer) == 2 then
		leaveTeamButton:setActive(true)
		redTeamButton:setActive(false)
		blueTeamButton:setActive(false)

		leaveTeamButtonOutside:setActive(true)
		redTeamButtonOutside:setActive(false)
		blueTeamButtonOutside:setActive(false)

		leaveTeamButtonEnabled = true
		redTeamButtonEnabled = false
		blueTeamButtonEnabled = false
	else
		leaveTeamButton:setActive(false)
		redTeamButton:setActive(true)
		blueTeamButton:setActive(true)

		leaveTeamButtonOutside:setActive(false)
		redTeamButtonOutside:setActive(true)
		blueTeamButtonOutside:setActive(true)

		leaveTeamButtonEnabled = false
		redTeamButtonEnabled = true
		blueTeamButtonEnabled = true
	end
end

function refreshTeams() -- Loop through players, and display names on team board
	local redText = ""
	local blueText = ""
	for index, ply in ipairs(Players) do
		if teamIndex(ply) == 1 then
			redText = redText .. ply.playerName .. "\n" -- \n represent a newline
		end
		if teamIndex(ply) == 2 then
			blueText = blueText .. ply.playerName .. "\n"
		end
	end
	redTeamText:setText(redText)
	blueTeamText:setText(blueText)
	redTeamTextOutside:setText(redText)
	blueTeamTextOutside:setText(blueText)

	refreshButtons()
end

function changeTeam(player, teamIdx) -- simple function to change a team of a player, refreshes board after
	player.playerMaterial = teamIdx
	refreshTeams()
end

function tryToTag(ply) -- see if a player is taggable
	if not gameStarted then
		return
	end
	local localIdx = teamIndex(LocalPlayer)
	local taggingTeam = 0
	if gameState == 2 then
		taggingTeam = 2
	end
	if gameState == 4 then
		taggingTeam = 1
	end

	if localIdx ~= taggingTeam then -- Make sure the LocalPlayer can tag
		return
	end
	local taggableIdx = 0
	if gameState == 2 then
		taggableIdx = redTeamIndex
	end
	if gameState == 4 then
		taggableIdx = blueTeamIndex
	end
	if ply.playerMaterial == taggableIdx then -- Make sure the person being tagged is on the opposite team, and not already tagged
		onEvent("tagPlayer", { ply })
		emitEvent("tagPlayer", { ply })
	end
end

function checkGameState() -- Process the match state, check if everyone is tagged, if teams still have atleast 1 person each etc
	if not gameStarted then
		return
	end
	if not LocalPlayer.isMasterClient then
		return
	end
	local redCount = 0
	local blueCount = 0
	for index, ply in ipairs(Players) do -- Count players per team
		if teamIndex(ply) == 1 then
			redCount += 1
		end
		if teamIndex(ply) == 2 then
			blueCount += 1
		end
	end
	if redCount == 0 or blueCount == 0 then -- Someone left, end the game
		emitEvent("endGameEarly", { 0 })
		onEvent("endGameEarly", { 0 })
		return
	end
	if gameState == 2 then -- Check if everyone on red team has been tagged
		local unTaggedCount = 0
		for index, ply in ipairs(Players) do
			if ply.playerMaterial == redTeamIndex then
				unTaggedCount += 1
			end
		end
		if unTaggedCount == 0 then
			emitEvent("teamTagged", { 0 })
			onEvent("teamTagged", { 0 })
			return
		end
	end
	if gameState == 4 then -- Check if everyone on blue team has been tagged
		local unTaggedCount = 0
		for index, ply in ipairs(Players) do
			if ply.playerMaterial == blueTeamIndex then
				unTaggedCount += 1
			end
		end
		if unTaggedCount == 0 then
			emitEvent("teamTagged", { 0 })
			onEvent("teamTagged", { 0 })
			return
		end
	end
end

function endGameEarly() -- Reset room state
	playSound(2, LocalPlayer.bodyPosition, 0.5)
	for index, ply in ipairs(Players) do
		if teamIndex(ply) == 1 then
			ply.playerMaterial = redTeamIndex
		end
		if teamIndex(ply) == 2 then
			ply.playerMaterial = blueTeamIndex
		end
	end
	gameStarted = false
	gameState = 0
	DelayedFunctions = {}
	refreshTeams()
	redTeamStartTime = 0
	blueTeamStartTime = 0
	redTeamTime = 0
	blueTeamTime = 0
	refreshTeams()
end

function teamTagged() -- Progress room state forward, since everyone was tagged
	if not gameStarted then
		return
	end
	if gameState == 2 then
		gameState = 3
		playSound(2, LocalPlayer.bodyPosition, 0.5)
		setTimeout(5, function()
			playSound(0, LocalPlayer.bodyPosition, 0.5)
			for index, ply in ipairs(Players) do -- Reset materials
				if teamIndex(ply) == 1 then
					ply.playerMaterial = redTeamTaggedIndex
				end
				if teamIndex(ply) == 2 then
					ply.playerMaterial = blueTeamIndex
				end
			end
			if teamIndex(LocalPlayer) == 1 then
				PlayerSettings.jumpMultiplier = 0 -- Freeze new taggers
			end
			setTimeout(1, function()
				playSound(5, LocalPlayer.bodyPosition, 0.1) -- timers act as countdown before next round begins
			end)
			setTimeout(2, function()
				playSound(5, LocalPlayer.bodyPosition, 0.1)
			end)
			setTimeout(3, function()
				playSound(7, LocalPlayer.bodyPosition, 0.1)
				PlayerSettings.jumpMultiplier = 1.1 -- UnFreeze taggers
				gameState = 4
				blueTeamStartTime = os.clock() -- start clock
			end)
		end)
		redTeamTime = os.clock() - redTeamStartTime -- Process red team timer, and display
		if LocalPlayer.isMasterClient then
			onEvent("updateTimes", { redTeamTime, 0 })
			emitEvent("updateTimes", { redTeamTime, 0 })
		end
	end
	if gameState == 4 then
		for index, ply in ipairs(Players) do
			if teamIndex(ply) == 1 then
				ply.playerMaterial = redTeamIndex
			end
			if teamIndex(ply) == 2 then
				ply.playerMaterial = blueTeamIndex
			end
		end
		gameState = 0
		gameStarted = false
		playSound(2, LocalPlayer.bodyPosition, 0.5)
		blueTeamTime = os.clock() - blueTeamStartTime
		if LocalPlayer.isMasterClient then
			onEvent("updateTimes", { redTeamTime, blueTeamTime })
			emitEvent("updateTimes", { redTeamTime, blueTeamTime })
		end
		DelayedFunctions = {}
		redTeamStartTime = 0
		blueTeamStartTime = 0
		refreshTeams()
	end
end

function updateTimes(t1, t2) -- Uses formatted time and displays it to text fields
	local redTeam = formatTime(t1)
	local blueTeam = formatTime(t2)
	redTeamTimeText:setText(redTeam)
	blueTeamTimeText:setText(blueTeam)
	redTeamTimeTextOutside:setText(redTeam)
	blueTeamTimeTextOutside:setText(blueTeam)
end

function tagPlayer(ply) -- Actually tag a player, a check has already been ran to see if they can be tagged
	if not gameStarted then
		return
	end
	ply.playerMaterial = taggedIndex
	playSound(0, ply.bodyPosition, 0.4)
	if LocalPlayer.isMasterClient then
		checkGameState()
	end
end

function startGame() -- Initalize game state, initialize timer, etc.
	if gameStarted then
		return
	end
	gameStarted = true
	gameState = 1
	playSound(0, LocalPlayer.bodyPosition, 0.5)
	for index, ply in ipairs(Players) do
		if teamIndex(ply) == 1 then
			ply.playerMaterial = redTeamIndex
		end
		if teamIndex(ply) == 2 then
			ply.playerMaterial = blueTeamTaggedIndex
		end
	end
	if teamIndex(LocalPlayer) == 2 then
		PlayerSettings.jumpMultiplier = 0
	end
	setTimeout(1, function()
		playSound(5, LocalPlayer.bodyPosition, 0.1)
	end)
	setTimeout(2, function()
		playSound(5, LocalPlayer.bodyPosition, 0.1)
	end)
	setTimeout(3, function()
		playSound(7, LocalPlayer.bodyPosition, 0.1)
		PlayerSettings.jumpMultiplier = 1.1
		gameState = 2
		redTeamStartTime = os.clock()
	end)
	refreshButtons()
end

function handleButtons() -- Check if every button we have is active and if its pressed
	if
		(isButtonPressed(redTeamButton) or isButtonPressed(redTeamButtonOutside))
		and canPressButtons()
		and redTeamButtonEnabled
	then
		emitEvent("changeTeam", { LocalPlayer, redTeamIndex })
		onEvent("changeTeam", { LocalPlayer, redTeamIndex })
	end
	if
		(isButtonPressed(blueTeamButton) or isButtonPressed(blueTeamButtonOutside))
		and canPressButtons()
		and blueTeamButtonEnabled
	then
		emitEvent("changeTeam", { LocalPlayer, blueTeamIndex })
		onEvent("changeTeam", { LocalPlayer, blueTeamIndex })
	end
	if
		(isButtonPressed(leaveTeamButton) or isButtonPressed(leaveTeamButtonOutside))
		and canPressButtons()
		and leaveTeamButtonEnabled
	then
		emitEvent("changeTeam", { LocalPlayer, 0 })
		onEvent("changeTeam", { LocalPlayer, 0 })
	end
	if
		(isButtonPressed(startGameButton) or isButtonPressed(startGameButtonOutside))
		and canPressButtons()
		and startGameButtonEnabled
	then
		local redCount = 0
		local blueCount = 0
		for index, ply in ipairs(Players) do
			if teamIndex(ply) == 1 then
				redCount += 1
			end
			if teamIndex(ply) == 2 then
				blueCount += 1
			end
		end
		if redCount >= 1 and blueCount >= 1 then
			emitEvent("startGame", { 0 })
			onEvent("startGame", { 0 })
		end
		refreshTeams()
	end
end

tickCount = 0

function tick(dt)
	tickCount += 1
	handleTimeouts()
	handleButtons()

	if tickCount % 9000 == 0 and LocalPlayer.isMasterClient then -- Sanity check for if were out of sync
		emitEvent("sanityState", { gameStarted, gameState })
	end

	if tickCount % 200 then -- Infrequent update for boards and gamestate.
		refreshTeams()
		checkGameState()
	end

	if lastPlayerCount ~= #Players then -- Someone either left, or a new player has joined. Check states
		refreshTeams()
		checkGameState()
	end
	lastPlayerCount = #Players
end

function onEvent(event, data) -- event handler
	if event == "changeTeam" then
		changeTeam(data[1], data[2])
	end
	if event == "startGame" then
		startGame()
	end
	if event == "touchedPlayer" then
		tryToTag(data)
	end
	if event == "tagPlayer" then
		tagPlayer(data[1])
	end
	if event == "endGameEarly" then
		endGameEarly()
	end
	if event == "teamTagged" then
		teamTagged()
	end
	if event == "updateTimes" then
		updateTimes(data[1], data[2])
	end
	if event == "requestState" then -- Emit local players materials, and host transmits current game state
		emitEvent("localState", { LocalPlayer, LocalPlayer.playerMaterial })
		if LocalPlayer.isMasterClient then
			emitEvent(
				"hostState",
				{ gameStarted, gameState, redTeamTime, blueTeamTime, redTeamStartTime, blueTeamStartTime }
			)
		end
	end
	if event == "localState" then
		data[1].playerMaterial = data[2]
		refreshTeams()
	end
	if event == "hostState" then
		if not synced then
			gameStarted = data[1]
			gameState = data[2]
			redTeamTime = data[3]
			blueTeamTime = data[4]
			redTeamStartTime = data[5]
			blueTeamStartTime = data[6]
			synced = true
			refreshTeams()
		end
	end
	if event == "sanityState" then
		if LocalPlayer.isMasterClient then
			return
		end
		if gameStarted ~= data[1] or gameState ~= data[2] then
			synced = false
			emitEvent("requestState", { 0 })
		end
	end
end
