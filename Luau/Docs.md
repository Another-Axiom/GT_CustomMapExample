
----------

# GT_CustomMapScripting

Scripting for compatible Gorilla Tag maps is done using a [Luau](https://luau.org/) script, executed by each client. Maps can have a single script that overrides the default game modes (e.g., infection, casual). This script manages custom game logic, including interactions such as opening/closing doors, tagging, and movement. The gamemode starts off as casual but quickly becomes whatever youd like. A puzzle map? Go for it. Freeze tag with some twists? Why not. The freedom is yours.

Luau support as well as this repo will recieve updates so be sure to be on the lookout.

----------

## **Setup**

Scripting is done in the **Luau** programming language and starts with a simple text file. We recommend using **VS Code** with the extensions:

-   `stylua` – for code formatting.
-   `luau-lsp` – a language server providing real-time feedback.

Type files are provided to enhance these extensions with up-to-date bindings between Gorilla Tag and Luau. You can view these files for a full list of binded features.

Open the `LUAU` folder in **VS Code** and make sure the extensions install for the best expierience.

### **Steps to Add Scripts to Maps**:

1.  Once your script is complete, add it to your map's Unity project as a **Text Resource**. (copy your .luau file into a .txt file)
2.  Supply the text file in the **Custom Game Mode** field of the Map Descriptor for your initial scene (If its not in your inital scene your script may not load).
3.  After exporting and uploading your map, run your script by selecting **CUSTOM** in the game mode selector inside the Virtual Stump. Then load up your map.
    
    > **Note:** If CUSTOM is not selected, the script won't execute, and the selected game mode will run.
    

----------

## **Important Notes**

-   **Client-Side Execution**:  
    All scripts currently run on the client side. You are responsible for managing synchronization between clients. For instance:
    
    -   When opening a door, ensure you network the state to other clients.
    -   If a player gets tagged, sync the change and update their materials accordingly.
    -  If  a script crashes or errors out, that player needs to rejoin the room for the script to execute again, so please tests scripts accordingly. 
    - Room states are always changing so make sure to handle things like the master client leaving and getting transferred to another payer

-   **Printing/Logging**:  
    Logging is done via Unity's log system.
    
    -   On **PC VR**, logs can be accessed in the Unity Player logs.
    -   On **Quest**, use `logcat` via `adb` to retrieve logs.
    
- **Must have tick function**
	- Functionality is dependent on the tick function
- **Luau standard**
	- Not all standard Luau functionality is provided or tested
- **Performance**
	- Clients are running code, and code can be slow, so keep performance in mind while creating your game modes.

----------

## **Debugging**

A built-in `print()` function allows you to log messages to Unity logs. 

In the event that your script crashes or fails to run, the logs will include the error message and the line number where the issue occurred.
```lua
 print("Hello " .. "World!")
```

----------

## **Networking**

Networking is currently event-driven. Each client can send up to **20 events per second**. So it should be used to send events, not streaming data like positions.

-   **Sending Events**:  
    Use the `emitEvent()` function, which takes:
    
    -   `tag` (string): The event name.
    -   `data` (table): A table containing the data to be sent (must have at least one entry and must be a table).
    
    ```lua
	emitEvent("eventName", { 1, 2, 3, LocalPlayer })
    ```
    
    **Limitations**:
    
    -   Tables are limited to **10 entries**.
    -   Every event must send some data, even if it's just an empty table with one element.
    -   Events can only send, `Vec3`'s, `Quat`'s, `Player`'s, and Numbers.
    -	No strings can be sent at this time, apart from the event name.
-   **Receiving Events**:  
    Implement an `onEvent()` function in your script to handle incoming events. The function should accept:
    
    -   `tag` (string): The event name.
    -   `data` (table): The data received.
    
    ```lua
    function onEvent(tag, data)
        if tag == "exampleEvent" then
            -- Process the data
        end
    end
    ```

----------

## **Game Events**

Some events from Gorilla Tag will be sent to your script via the `onEvent()` function. These events include:

- `taggedByEnvironment` - This indicates the local player was tagged by something in the environment rather than a player. 
                          Only sent in Infection-style and Custom gamemodes. `data` will be `nil`.
- `agentDestroyed` - This indicates an AIAgent was destroyed, `data` will be the AIAgent's `entityID`
- `touchedPlayer` - This indicates the local player touched another player. `data` will be the `Player` they touched

----------

## **Players**

Scripts have simple access to each player in the lobby, allowing you to do things like:

-   Check if a player is the **master client** or **entity authority**
-   Get their **position**, **rotation**, and **player materials**.

### **Player Materials**

You can control how players appear using the `playerMaterial` property. This property is an integer corresponding to different material types (normal, tagged, infected, frozen, etc.):

0 = normal
1 = tagged
2 = infected
3 = frozen
4 = blue
5 = magenta
6 = light blue
7 = blue with orange splatter
8 = orange
9 = red
10 = yellow
11 = orange with blue splatter
12 = soda infected
13 = ghost skeleton
14 = ice

Example:
```lua
LocalPlayer.playerMaterial = 0
function tick() end
```
----------

## **Touch Events**

When a player tags/touches another player, the `onEvent()` function receives an event named `"touchedPlayer"` with the touched player instance as data. Please see the SimpleTag example.

----------

## AI Agents

Scripts have access to each of the AI Agents in the map. They have several properties available including:
- `entityID` - can be used to identify an AI Agent and get a reference to them with the `getAIAgentByEntityID` function. This ID is valid when sent to other players via the `emitEvent` function
- `agentPosition` - the AI Agent's world position, updated every tick
- `agentRotation` - the AI Agent's world rotation, updated every tick

There are also several functions available including: 
- `tostring` support
- `setDestination(Vec3 destination)`* - used to tell an Agent where they should try to move to.
- `destroyAgent`* - used to remove an AI Agent from the game entirely
- `playAgentAnimation(string animationStateName)` - used to tell all Animator components on an agent to activate the specified Animation State.
- `getAIAgentByEntityID(number id)` - used to get an AIAgent reference from an entityID
- `findPrePlacedAIAgentByID(number id)` - used to get a reference to a specific Pre-Placed AIAgent using their Lua_AgentID
- `spawnAIAgent(number agentTypeID, Vec3 position, Quat rotation)`* - used to spawn a new AIAgent at the specified world position/rotation using their AgentTypeID

Functions with a * next to them must be called on the Player that has EntityAuthority. Use `Player.isEntityAuthority` to check this.

----------

## **GameObjects**

Scripts can access and manipulate **GameObjects** within a custom map's scene thats loaded. Available properties include:

-   **position**: `Vec3`
-   **rotation**: `Quat`
-   **scale**: `Vec3`

Additional methods allow you to toggle:

-   **Collision**: `setCollision(enabled: boolean)`
-   **Visibility**: `setVisibility(enabled: boolean)`

> **Note:** Static objects cannot be moved, as they are combined into a single mesh upon export.

### **Finding GameObjects**

Use the `findGameObject()` function to retrieve GameObjects by name:

```lua
local door = GameObject.findGameObject("DoorName")
door:setVisibility(false)
function tick() end
```


----------

## **Sounds**

You can play sounds using the `playSound()` function, which accepts:

-   `idx` (number): The sound ID (similar to player materials).
-   `pos` (Vec3): The position to play the sound.
-   `vol` (number): Volume percentage (0 to 1).
```lua
playSound(1, Vec3.new(0, 0, 0), 1)
function tick() end
```
----------

## **Vibrations**

The `startVibration()` function lets you trigger controller vibrations. Parameters include:

-   `leftHand` (boolean): Whether to vibrate the left hand.
-   `strength` (number): Vibration strength (0 to 1).
-   `duration` (number): Duration in seconds.

```lua
startVibration(true, 0.8, 2.0)
function tick() end
```

----------

## **Movement Control**

Scripts can modify player movement settings through the `PlayerSettings` instance. 

Example usage:

```lua
PlayerSettings.maxJumpSpeed = 10
PlayerSettings.jumpMultiplier = 1.5

function tick() end
```
----------


## **Tick Function**

The `tick()` function is called every frame, making it essential for continuous processing. Use this function to handle tasks like:

-   Updating game logic for non event based player interactions.
-   Handling movement over time.

Since `tick()` is called frequently, it's a good practice to prefetch any GameObjects outside the function to avoid performance issues.

Example usage:

```lua
local buttonObject = GameObject.findGameObject("Button")
local otherObject = GameObject.findGameObject("OtherObject")

buttonObject:setCollision(false)

function isButtonPressed(gameObject)
	local leftHand = LocalPlayer.leftHandPosition
	local rightHand = LocalPlayer.rightHandPosition

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

function tick()
	if isButtonPressed(buttonObject) then
		otherObject:setVisibility(false)
	else
		otherObject:setVisibility(true)
	end
end
```


-------
## **FAQ**

- **Q:** Nothing happens when I run my script

    - **A:** Make sure you've selected the custom gamemode, and your map is updated. If it still appears to do nothing, check your unity logs and search for luau, this will show if any erors happened, and will also show your print statements

- **Q:** Can I use wait or sleep?

    - **A:** Not currently, as luau is proccessed on the main thread, doing so would essentialy pause your game. 

- **Q:** Im getting roblox references in Vs code?

    - **A:** Make sure only the extensions we recomend are enabled (atleast lua related ones), these are `stylua` and `luau-lsp`

- **Q:** It seems like my events are not going through?

    - **A:** Remember, your limited to 20 events per second, any over that wont be processed. Also, you dont recieve your own events when you emit then so consider also calling onEvent your self, to recieve them if you want.

- **Q:** I'm Still having issues?

    - **A:**  Feel free to ask in the `luau-help` channel in the modding discord.