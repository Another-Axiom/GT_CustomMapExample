startTime = os.clock() -- Timers

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

function onEvent(event, data) -- event handler
	print("received event: " .. event)
	if event == "playerHit" then
		print("Agent with entity ID " .. tostring(data[1]) .. " has hit player with ID " .. tostring(data[2]))
	end
end

tickCount = 0
function tick(dt)
	tickCount += 1
end

function scriptStarted()
	print("luau started")
end
scriptStarted()
