spinTop = GameObject.findGameObject("Spin") -- Spinning Gameobject

doorHinge = GameObject.findGameObject("DoorRot") -- Door hinge, not needed but nice for placing rotation
door = GameObject.findGameObject("GoldDoor")

button1 = GameObject.findGameObject("button1") -- Trap Buttons
button2 = GameObject.findGameObject("button2")
button3 = GameObject.findGameObject("button3")

button1:setCollision(false)
button2:setCollision(false)
button3:setCollision(false)

endWall = GameObject.findGameObject("EndWall")
endWall:setCollision(false)
endWall:setVisibility(false)

pointerBall = GameObject.findGameObject("pointerBall") -- Used for showing where your pressing keypad (tip of finger)
pointerBall:setCollision(false)
pointerLocation = Vec3.new(pointerBall.position.x, pointerBall.position.y, pointerBall.position.z)

ButtonPlate = {} -- Table/Array to store the keypad buttons
for i = 0, 9 do
	ButtonPlate[i + 1] = GameObject.findGameObject("ButtonPlate (" .. i .. ")") -- Find and store buttons in Table/Array
	ButtonPlate[i + 1]:setCollision(false)
end

bridgePlates = {} -- Table/Array to store bridge peices
for i = 1, 8 do
	bridgePlates[i] = GameObject.findGameObject("b" .. i)
end

bhopPlates = {} -- Table/Array to store bhop platforms

for i = 1, 5 do
	bhopPlates[i] = { timer = 0, plate = GameObject.findGameObject("Bhop" .. i) }
end

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

doorAngle = door.rotation:euler().y + 90
Opening = false

StartTime = 0

function isWithinBox(point, pos, size) -- Check if point is within box for buttons
	local min = pos - size / 2
	local max = pos + size / 2
	return (point.x >= min.x and point.x <= max.x)
		and (point.y >= min.y and point.y <= max.y)
		and (point.z >= min.z and point.z <= max.z)
end

function lerp(a, b, t) -- Simple lerp between 2 values
	if t > 1 then
		t = 1
	end

	return a + (b - a) * t
end

isLeft = true

function KeypadHandle() -- Check each button and return the current key pressed or if none are pressed return -1
	if Opening then
		return -1
	end
	if Vec3.distance(LocalPlayer.bodyPosition, ButtonPlate[6].position) > 5 then
		pointerBall.position = pointerLocation
		lastPressed = -1
		return -1
	end
	local dleft = Vec3.distance(LocalPlayer.leftHandPosition, ButtonPlate[6].position)
	local dright = Vec3.distance(LocalPlayer.rightHandPosition, ButtonPlate[6].position)

	if dleft < dright then
		isLeft = true
		local offset = Vec3.new(-0.07, 0.21, 0)
		offset = Vec3.rotate(offset, LocalPlayer.leftHandRotation)
		pointerBall.position = offset + LocalPlayer.leftHandPosition -- Rotates Vec3 to allign with hand, gets close to finger position for keypad
	else
		isLeft = false
		local offset = Vec3.new(0.07, 0.21, 0)
		offset = Vec3.rotate(offset, LocalPlayer.rightHandRotation)
		pointerBall.position = offset + LocalPlayer.rightHandPosition
	end

	for i = 1, #ButtonPlate do
		if isWithinBox(pointerBall.position, ButtonPlate[i].position, ButtonPlate[i].scale) then -- Checks if ball is within any of the buttons
			return i - 1
		end
	end

	return -1
end

previousKeypad = -1
codeStep = 1
code = { 1, 3, 7, 9 }

function tick(dt)
	handleTimeouts()

	local rot = spinTop.rotation:euler()
	spinTop.rotation = Quat.fromEuler(rot.x, rot.y + 90 * dt, rot.z) -- Spinning helicopter

	local key = KeypadHandle()
	if key ~= previousKeypad and key ~= -1 then -- Make sure buttons not spammed, only pressed once
		playSound(3, pointerBall.position, 0.2)
		startVibration(isLeft, 0.5, 0.25)
		if key == code[codeStep] then -- If code is correct advance step
			codeStep += 1
		else
			codeStep = 1 -- Otherwise reset
		end
		if codeStep == #code + 1 then -- If code step is at the end of the codes then open the door
			emitEvent("openDoor", { 1 })
			onEvent("openDoor", { 1 })
			codeStep = 1
		end
	end
	previousKeypad = key
	doorHandling()
	bhopchecks()
	traps()
end

function doorHandling()
	local rot2 = door.rotation:euler()

	if Opening then
		doorAngle = lerp(0, -90, (os.clock() - StartTime) / 2) -- Rotate forward
	end
	if (os.clock() - StartTime) > 10 and StartTime ~= 0 then
		Opening = false
		doorAngle = lerp(-90, 0, (os.clock() - 10 - StartTime) / 2) -- Rotate back
	end
	if (os.clock() - StartTime) > 12 and StartTime ~= 0 then -- Reset to closed position
		StartTime = 0
		doorAngle = 0
	end

	rot2.y = doorAngle - 90
	door.rotation = Quat.fromEuler(rot2.x, rot2.y, rot2.z)
	door.position = doorHinge.position
		- (Vec3.new(math.sin(rot2.y * math.pi / 180), 0, math.cos(rot2.y * math.pi / 180)) * door.scale.z / 2) -- Pure math way, can also rotate forward vector of door by Quat like done in keypad
end

function bhopchecks()
	for i = 1, #bhopPlates do
		local lhpos = LocalPlayer.leftHandPosition
		local rhpos = LocalPlayer.rightHandPosition
		local dbpos = bhopPlates[i].plate.position
		local dbscale = bhopPlates[i].plate.scale
		local offset = Vec3.new(0, 0.1, 0)
		if
			(isWithinBox(lhpos, dbpos + offset, dbscale) or isWithinBox(rhpos, dbpos + offset, dbscale)) -- Check if either hand is above each plate
			and bhopPlates[i].timer == 0
		then
			emitEvent("bhop", { i })
			onEvent("bhop", { i })
		end
	end
end

function bhop(index)
	if bhopPlates[index].timer == 1 then
		return
	end

	bhopPlates[index].timer = 1
	setTimeout(1, function() -- Disable plate after 1 second
		playSound(1, bhopPlates[index].plate.position, 1)
		bhopPlates[index].plate:setCollision(false)
		bhopPlates[index].plate:setVisibility(false)
	end)
	setTimeout(3, function() -- Re enable after 3 seconds
		playSound(3, bhopPlates[index].plate.position, 1)
		bhopPlates[index].plate:setCollision(true)
		bhopPlates[index].plate:setVisibility(true)
		bhopPlates[index].timer = 0
	end)
end

trap1 = false
trap2 = false
trap3 = false

function traps()
	local lhpos = LocalPlayer.leftHandPosition
	local rhpos = LocalPlayer.rightHandPosition

	if
		(isWithinBox(lhpos, button2.position, button2.scale) or isWithinBox(rhpos, button2.position, button2.scale)) -- Check if trap button is pressed, then emit the event
		and trap2 == false
	then
		emitEvent("button2", { 1 })
		onEvent("button2", { 1 })
	end
	if
		(isWithinBox(lhpos, button3.position, button3.scale) or isWithinBox(rhpos, button3.position, button3.scale))
		and trap3 == false
	then
		emitEvent("button3", { 1 })
		onEvent("button3", { 1 })
	end
end

function button2fn()
	if trap2 == true then
		return
	end
	trap2 = true
	button2:setVisibility(false)
	playSound(1, button2.position, 0.25)
	for i = 1, 8 do -- Disable plates 1 by 1, .2 seconds after each other.
		setTimeout(0.2 * i, function()
			playSound(3, bridgePlates[i].position, 0.1)
			bridgePlates[i]:setCollision(false)
			bridgePlates[i]:setVisibility(false)
		end)
	end
	setTimeout(6, function() -- Re enable them all at once
		playSound(2, bridgePlates[4].position, 0.3)
		for i = 1, 8 do
			bridgePlates[i]:setCollision(true)
			bridgePlates[i]:setVisibility(true)
		end
	end)
	setTimeout(12, function() -- Re enable trap button
		button2:setVisibility(true)
		trap2 = false
	end)
end

function button3fn()
	if trap3 == true then
		return
	end
	trap3 = true
	playSound(1, button3.position, 0.25)
	button3:setVisibility(false)
	setTimeout(0.2, function() -- Enable Wall
		playSound(3, endWall.position, 0.4)
		endWall:setCollision(true)
		endWall:setVisibility(true)
	end)

	setTimeout(6, function() -- Hide Wall
		playSound(2, endWall.position, 0.4)
		endWall:setCollision(false)
		endWall:setVisibility(false)
	end)

	setTimeout(12, function() -- Re enable trap button
		button3:setVisibility(true)
		trap3 = false
	end)
end

function openDoor() -- Begin the opening process
	Opening = true
	StartTime = os.clock()
	playSound(1, door.position, 1)
end

function onEvent(event, data) -- Handle events
	if event == "button2" then
		button2fn()
	end
	if event == "button3" then
		button3fn()
	end
	if event == "bhop" then
		bhop(data[1])
	end
	if event == "openDoor" then
		openDoor()
	end
end
