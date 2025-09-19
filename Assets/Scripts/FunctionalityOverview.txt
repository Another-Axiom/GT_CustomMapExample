startTime = os.clock() -- Timers

scriptInitialized = false
waitingForInitData = false

purpleSkeleton = nil
targetingRange = 5
attackRange = 1

spawnedGrabbables = {}
grabbableSpawnType = 15

grabbableSpawnPoints = {}

local patrolPoints = {}
local agentPatrolTargets = {}
local agentPlayerTargets = {}

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

function getRandomPatrolPoint(exceptPos)
	local availablePatrolPoints = table.clone(patrolPoints)

	if exceptPos ~= nil then
		for i = #availablePatrolPoints, 1, -1 do
			if Vec3.nearlyEqual(availablePatrolPoints[i].position, exceptPos, 0.01) then
				table.remove(availablePatrolPoints, i)
				break
			end
		end
	end

	local numPatrolPoints = #availablePatrolPoints
	local patrolPointIdx = math.random(1, numPatrolPoints)
	local patrolPoint = availablePatrolPoints[patrolPointIdx];
	-- print("[getRandomPatrolPoint] returning point: " .. tostring(patrolPoint.position))
	return patrolPoint
end

function initPatrolPoints()
	for i = 1, 100, 1 do
		local foundPatrolPoint = GameObject.findGameObject("patrolPoint_" .. tostring(i))
		if foundPatrolPoint == nil then
			break
		end
		table.insert(patrolPoints, foundPatrolPoint)
	end
end

function startPatrol(patrolAgent, originPos)
	if patrolAgent == nil then
		print("[startPatrol] ERROR: patrolAgent is nil")
		return
	end

	local initialPatrolPoint = getRandomPatrolPoint(originPos)
	-- print("[startPatrol] got patrol point: " .. tostring(initialPatrolPoint.position))

	if initialPatrolPoint ~= nil then
		patrolAgent:setDestination(initialPatrolPoint.position)
		updatePatrolTarget(patrolAgent, initialPatrolPoint.position, true)
	end
end

function updatePatrolTarget(patrolAgent, patrolTargetPos, sendEvent)
	if patrolAgent == nil then
		print("[updatePatrolTarget] ERROR: patrolAgent is nil")
		return
	end

	if patrolTargetPos == nil then
		print("[updatePatrolTarget] ERROR: patrolTargetPos is nil")
		return
	end

	local foundExistingEntry = false
	for i = 1, #agentPatrolTargets, 1 do
		if agentPatrolTargets[i].agent == patrolAgent then
			agentPatrolTargets[i].targetPos = patrolTargetPos
			foundExistingEntry = true
			break
		end
	end

	if not foundExistingEntry then
		local patrolTarget = {
			agent = patrolAgent,
			targetPos = patrolTargetPos
		}
		table.insert(agentPatrolTargets, patrolTarget)
	end

	if sendEvent then
		-- print("[updatePatrolTarget] sending event")
		emitEvent("setPatrolTarget", { patrolAgent.entityID, patrolTargetPos })
	end
end

function checkPatrols()
	-- print("[checkPatrols] checking...")
	for i = #agentPatrolTargets, 1, -1 do -- loop backwards to allow for table removal during the loop
		local patrolTarget = agentPatrolTargets[i]
		if Vec3.nearlyEqual(patrolTarget.agent.agentPosition, patrolTarget.targetPos, 1) then

			print("[checkPatrols] Agent " .. tostring(patrolTarget.agent.entityID) .. " reached patrol target")
			
			local nextPatrolTarget = getRandomPatrolPoint(patrolTarget.targetPos)
			patrolTarget.agent:setDestination(nextPatrolTarget.position)
			patrolTarget.targetPos = nextPatrolTarget.position
			emitEvent("setPatrolTarget", { patrolTarget.agent.entityID, nextPatrolTarget.position })
		end
	end
end

function hasTarget(agent)
	if agent == nil then
		print("[hasTarget] ERROR: agent is nil")
		return false
	end

	for i = #agentPlayerTargets, 1, -1 do -- loop backwards to allow for table removal during the loop
		local targetData = agentPlayerTargets[i]
		if targetData.agent == agent then
			-- print("[hasTarget] agent " .. tostring(agent.entityID) .. " has target: " .. targetData.target.playerName)
			return true
		end
	end

	-- print("[hasTarget] agent " .. tostring(agent.entityID) .. " has no target")
	return false
end

function findTarget(forAgent)
	if forAgent == nil then 
		print("[findTarget] ERROR: forAgent is nil!")
		return
	end

	local agentPos = forAgent.agentPosition

	for i = 1, #Players, 1 do
		local player = Players[i]
		if player == nil then
			continue
		end

		-- print("[findTarget] checking player " .. player.playerName)
		if player.playerMaterial ~= 0 then -- only target untagged players
			-- print("[findTarget] " .. player.playerName .. " is already tagged, skipping")
			continue
		end

		if Vec3.nearlyEqual(agentPos, player.bodyPosition, targetingRange) then
			-- print("[findTarget] " .. player.playerName .. " is in targeting range, setting target")
			-- print("[findTarget] Agent " .. tostring(forAgent.entityID) .. " found target: " .. player.playerName)
			updatePlayerTarget(forAgent, player, true)

			forAgent:setDestination(player.bodyPosition)
			for i = #agentPatrolTargets, 1, -1 do -- loop backwards to allow for table removal during the loop
				local patrolTarget = agentPatrolTargets[i]
				if patrolTarget.agent == forAgent then
					table.remove(agentPatrolTargets, i)
					emitEvent("removePatrolTarget", { forAgent.entityID })
					break
				end
			end
		-- else
			-- print("[findTarget] " .. player.playerName .. " is not in targeting range. AgentPos: " .. tostring(agentPos) .. " | PlayerPos: " .. tostring(player.bodyPosition))
		end
	end
end

function updatePlayerTarget(targetingAgent, playerTarget, sendEvent)
	local foundExistingEntry = false
	for i = 1, #agentPlayerTargets, 1 do
		if agentPlayerTargets[i].agent == targetingAgent then
			agentPlayerTargets[i].target = playerTarget
			agentPlayerTargets[i].reachedTarget = false
			foundExistingEntry = true
			break
		end
	end
	if not foundExistingEntry then
		local targetData = {
			agent = targetingAgent,
			target = playerTarget,
			reachedTarget = false
		}
		table.insert(agentPlayerTargets, targetData)
	end

	if sendEvent then
		emitEvent("setPlayerTarget", { targetingAgent.entityID, playerTarget })
	end
end

function removePlayerTarget(targetingAgent)
	for i = #agentPlayerTargets, 1, -1 do
		if agentPlayerTargets[i].agent == targetingAgent then
			table.remove(agentPlayerTargets, i)
			break
		end
	end
end

function updatePlayerTargets()
	if purpleSkeleton ~= nil and not hasTarget(purpleSkeleton) then
		findTarget(purpleSkeleton)
	end

	for i = #agentPlayerTargets, 1, -1 do -- loop backwards to allow for table removal during the loop
		local targetData = agentPlayerTargets[i]
		if Vec3.nearlyEqual(targetData.agent.agentPosition, targetData.target.bodyPosition, attackRange) then -- check if close enough to attack

			if not targetData.reachedTarget then
				print("Agent " .. tostring(targetData.agent.entityID) .. " reached player target")
				targetData.agent:playAgentAnimation("Attack")
				targetData.reachedTarget = true -- this logic gives the agent one update loop to start playing the Attack animation before tagging the target
			else
				tagPlayer(targetData.target, true)
				startPatrol(targetData.agent, nil)

				table.remove(agentPlayerTargets, i)
				emitEvent("removePlayerTarget", { targetData.agent.entityID })
			end
		else
			targetData.agent:setDestination(targetData.target.bodyPosition) -- follow target until close enough
		end
	end
end

function removePatrolTarget(patrolAgent)
	for i = #agentPatrolTargets, 1, -1 do
		if agentPatrolTargets[i].agent == patrolAgent then
			table.remove(agentPatrolTargets, i)
			break
		end
	end
end

function tagPlayer(player, sendEvent) 
	player.playerMaterial = 2 -- infected
	playSound(0, player.bodyPosition, 0.4)

	if sendEvent then
		emitEvent("tagPlayer", { player })
	end
end

function untagPlayer(player, sendEvent) 
	player.playerMaterial = 0 -- normal
	playSound(5, player.bodyPosition, 0.4)

	if sendEvent then
		emitEvent("untagPlayer", { player })
	end
end

function onEvent(event, data) -- event handler
    print("received event: " .. event);

	-- the agentDestroyed event is sent from GorillaTag whenever an agent is destroyed, remove any references to it that we may have stored
	if event == "agentDestroyed" then
		-- print("Agent with entity ID " .. tostring(data) .. " has been destroyed.")

		for i = #agentPatrolTargets, 1, -1 do
			if agentPatrolTargets[i].agent == nil then
				table.remove(agentPatrolTargets, i)
				continue
			end
			if agentPatrolTargets[i].agent.entityId == data then
				table.remove(agentPatrolTargets, i)
				continue
			end
		end

		for i = #agentPlayerTargets, 1, -1 do
			if agentPlayerTargets[i].agent == nil then
				table.remove(agentPlayerTargets, i)
				continue
			end
			if agentPlayerTargets[i].agent.entityId == data then
				table.remove(agentPlayerTargets, i)
				continue
			end
		end
	end

	if event == "tagPlayer" then
		tagPlayer(data[1], false)
	end

	if event == "untagPlayer" then
		untagPlayer(data[1], false)
	end

	-- the following events are used to ensure patrol and player targets are synced between players
	-- this is important because the EntityAuthority will change if the current player with EntityAuthority
	-- leaves the room. 
	if event == "setPatrolTarget" then
		local patrolAgentID = data[1]
		local patrolAgent = AIAgent.getAIAgentByEntityID(patrolAgentID)
		local patrolTargetPos = data[2]
		-- print("[OnEvent] SetPatrolTarget for Agent " .. patrolAgentID .. " pos: " .. tostring(patrolTargetPos) .. " | Agent is nil? = " .. tostring(patrolAgent == nil))
		updatePatrolTarget(patrolAgent, patrolTargetPos, false)
	end

	if event == "removePatrolTarget" then
		local patrolAgentID = data[1]
		local patrolAgent = AIAgent.getAIAgentByEntityID(patrolAgentID)
		-- print("[OnEvent] RemovePatrolTarget for Agent " .. patrolAgentID .. " | Agent is nil? = " .. tostring(patrolAgent == nil))
		removePatrolTarget(patrolAgent)
	end

	if event == "setPlayerTarget" then
		local targetingAgentID = data[1]
		local targetingAgent = AIAgent.getAIAgentByEntityID(targetingAgentID)
		local playerTarget = data[2]
		-- print("[OnEvent] SetPlayerTarget for Agent " .. targetingAgentID .. " target: " .. playerTarget.playerName .. " | Agent is nil? = " .. tostring(targetingAgent == nil))
		updatePlayerTarget(targetingAgent, playerTarget, false)
	end

	if event == "removePlayerTarget" then
		local targetingAgentID = data[1]
		local targetingAgent = AIAgent.getAIAgentByEntityID(targetingAgentID)
		-- print("[OnEvent] RemovePlayerTarget for Agent " .. targetingAgentID .. " | Agent is nil? = " .. tostring(targetingAgent == nil))
		removePlayerTarget(targetingAgent)
	end

	if event == "requestAgentData" then
		if LocalPlayer.isEntityAuthority then
			print("[OnEvent] Sending initAgentData...")
			for i = 1, #agentPatrolTargets, 1 do
				emitEvent("initAgentPatrol", { agentPatrolTargets[i].agent.entityID, agentPatrolTargets[i].targetPos })
			end

			for i = 1, #agentPlayerTargets, 1 do
				emitEvent("initAgentTarget", { agentPlayerTargets[i].agent.entityID, agentPlayerTargets[i].target })
			end

			emitEvent("endAgentInit", { nil })
		end
	end

	if event == "initAgentPatrol" then
		if waitingForInitData then
			local patrolAgentID = data[1]
			local patrolAgent = AIAgent.getAIAgentByEntityID(patrolAgentID)
			local patrolTargetPos = data[2]
			-- print("[OnEvent] initAgentPatrol for Agent " .. patrolAgentID .. " pos: " .. tostring(patrolTargetPos) .. " | Agent is nil? = " .. tostring(patrolAgent == nil))
			updatePatrolTarget(patrolAgent, patrolTargetPos, false)
		end
	end

	if event == "initAgentTarget" then
		if waitingForInitData then
			local targetingAgentID = data[1]
			local targetingAgent = AIAgent.getAIAgentByEntityID(targetingAgentID)
			local playerTarget = data[2]
			-- print("[OnEvent] initAgentTarget for Agent " .. targetingAgentID .. " target: " .. playerTarget.playerName .. " | Agent is nil? = " .. tostring(targetingAgent == nil))
			updatePlayerTarget(targetingAgent, playerTarget, false)
		end
	end

	if event == "endAgentInit" then
		-- print("[OnEvent] ending agent init")
		waitingForInitData = false
		scriptInitialized = true
	end

	if event == "entityGrabbed" then
		print("Agent with entity ID " .. tostring(data) .. " has been grabbed.")
	end
	if event == "entityReleased" then
		print("Agent with entity ID " .. tostring(data) .. " has been released.")
	end
end

function tickInput()
	-- this logic allows players to "UnTag" themselves by pressing any of the face buttons on their controllers
	if LocalPlayer.playerMaterial ~= 0 then
		if PlayerInput.rightPrimaryButton or PlayerInput.leftPrimaryButton or PlayerInput.rightSecondaryButton or PlayerInput.leftSecondaryButton then
			untagPlayer(LocalPlayer, true)
		end
	end
end

function tickAIAgents()

	-- don't run tickAIAgents logic if LocalPlayer is NOT the EntityAuthority or they're still waiting for agentInitData
	if not LocalPlayer.isEntityAuthority or waitingForInitData then
		-- print("[tickAIAgents] ERROR: LocalPlayer isEntityAuthority: " .. tostring(LocalPlayer.isEntityAuthority) .. " | waitingForInitData: " .. tostring(waitingForInitData))
		return
	end

	-- local numAgents = #AIAgents
	-- print("Num Agents: " .. tostring(numAgents))

	-- for j = numAgents, 1, -1 do
		-- local agent = AIAgents[j]
		-- print(agent.entityID)
	-- end

	if tickCount % 90 == 0 then -- roughly every second at 90fps
		checkPatrols()
	end

	if tickCount % 45 == 0 then -- roughly every 0.5 seconds at 90fps
		updatePlayerTargets()
	end
end

tickCount = 0
function tick(dt)
	handleTimeouts()

	-- prevent majority of tick logic from running before the script has fully initialized (see initAIAgents for where scriptInitialized is set to TRUE)
	if not scriptInitialized then
		return
	end

	tickCount += 1

	-- don't run tick logic if the LocalPlayer is nil
	if LocalPlayer == nil then
		print("[tick] LocalPlayer is nil")
		return
	end

	tickInput()
	tickAIAgents()
end

function initAIAgents()
	if LocalPlayer == nil then
		print("[initAIAgents] LocalPlayer is nil")
		setTimeout(1, initAIAgents) -- retry after 1 second, global variables are still initializing
		return
	end

	if InRoom == false then
		print("[initAIAgents] not currently in a room")
		setTimeout(1, initAIAgents) -- retry after 1 second, not yet in room
		return
	end

	purpleSkeleton = AIAgent.findPrePlacedAIAgentByID(3) -- copied from Lua_AgentID on the pre-placed AIAgent
	if purpleSkeleton == nil then
		print("[initAIAgents] couldn't find Agent by Lua_AgentID")
		setTimeout(1, initAIAgents) -- retry after 1 second, pre-placed Agent may not have been spawned yet
		return
	end

	if not LocalPlayer.isEntityAuthority then -- only the EntityAuthority can tell AI Agents what to do
		-- print("[initAIAgents] requesting agent init...") 
		-- if not the EntityAuthority, request Agent data from the current EntityAuthority
		waitingForInitData = true;
		emitEvent("requestAgentData", { nil })
		return
	end

	-- print("[initAIAgents] purpleSkeleton is valid (" .. tostring(purpleSkeleton ~= nil) .. "), starting patrol...")
	startPatrol(purpleSkeleton, nil)

	scriptInitialized = true
end

function spawnGrabbables()
	if LocalPlayer == nil or InRoom == false then
		setTimeout(1, spawnGrabbables)
		return
	end

	if not LocalPlayer.isEntityAuthority then
		return
	end

	local numGrabbablesToSpawn = #grabbableSpawnPoints
	local spawnPoint = nil
	for i = 1, numGrabbablesToSpawn, 1 do
		spawnPoint = grabbableSpawnPoints[i]
		if spawnPoint == nil then
			return
		end

		local spawnedGrabbable = GrabbableEntity.spawnGrabbableEntity(15, spawnPoint.position, spawnPoint.rotation)
		if spawnedGrabbable ~= nil then
			table.insert(spawnedGrabbables, spawnedGrabbable)
		end
	end
end

function initGrabbableSpawnPoints()
	print("initGrabbableSpawnPoints")
	for i = 1, 100, 1 do
		local foundSpawnPoint = GameObject.findGameObject("grabbableSpawn_" .. tostring(i))
		if foundSpawnPoint == nil then
			break
		end
		table.insert(grabbableSpawnPoints, foundSpawnPoint)
	end
	local numPatrolPoints = #grabbableSpawnPoints
	print("found " .. tostring(numPatrolPoints) .. " grabbable spawn points")
end

function findPreplacedGrabbable()
	print("findPreplacedGrabbable")
	local preplacedGrabbable = GrabbableEntity.findPrePlacedGrabbableEntityByID(4)
	if preplacedGrabbable == nil then
		return
	end
	print("found " .. tostring(preplacedGrabbable.gameObject.name))
end

function checkGrabStatus()
	print("getHoldingActorNumber")
	local actorNumber = GrabbableEntity.getHoldingActorNumberByLuauID(1)
	print("checkGrabStatus " .. tostring(actorNumber))
	if actorNumber < 0 then
		setTimeout(1, checkGrabStatus)
		return
	end
end

function scriptStarted()
	print("luau started")
	initPatrolPoints()
	initAIAgents()
	initGrabbableSpawnPoints()
	findPreplacedGrabbable()
	print("luau spawn grabbables")
	setTimeout(5, spawnGrabbables)
	print("luau check grab status")
	setTimeout(5, checkGrabStatus)
end
scriptStarted()
