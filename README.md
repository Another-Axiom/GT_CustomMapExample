[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

# GT_CustomMapExample
A Unity project to facilitate the creation of custom maps for Gorilla Tag. 

**Contents**

* [Setup](#setup)
* [Functionality Overview Map](#functionality-overview-map)
* [Creating a map](#creating-a-map)
* [Accessing Your Map](#accessing-your-map)
* [Matching Gorilla Tag's Style](#matching-gorilla-tags-style)
* [UberShader and Zone Shader Settings](#ubershader-and-zone-shader-settings)
    + [Zone Shader Settings](#zone-shader-settings)
    + [Zone Shader Settings Trigger](#zone-shader-settings-trigger)
* [Lighting](#lighting)
    + [General Lighting Setup](#general-lighting-setup)
    + [Lighting Meshes](#lighting-meshes)
    + [Lights](#lights)
    + [Other Tips](#other-tips)
* [UberShader Dynamic Lighting](#ubershader-dynamic-lighting)
* [Trigger Scripts](#trigger-scriptsprefabs)
    + [Map Boundary](#map-boundary)
    + [Teleporter](#teleporter)
    + [Tag Zone](#tag-zone)
    + [Object Activation Trigger](#object-activation-trigger)
	+ [Play Animation Trigger](#play-animation-trigger)
* [Placeholder Script and Prefabs](#placeholder-script-and-prefabs)
    + [Force Volume](#force-volume)
    + [Leaf Glider](#leaf-glider)
    + [Glider Wind Volume](#glider-wind-volume)
    + [Water Volume](#water-volume)
    + [Hoverboard Area](#hoverboard-area)
    + [Hoverboard Dispenser](#hoverboard-dispenser)
    + [Rope Swing](#rope-swing)
    + [Zipline](#zipline)
    + [ATM](#atm)
    + [Store Placeholders](#store-placeholders)
* [Other Scripts](#other-scriptsprefabs)
    + [Surface Override Settings](#surface-override-settings)
	+ [Surface Mover Settings](#surface-mover-settings)
	+ [Moving Surface Settings](#moving-surface-settings)
    + [Access Door Placeholder](#access-door-placeholder)
    + [Map Orientation Point](#map-orientation-point)
    + [Destroy Pre Export](#destroy-pre-export)
    + [Teleport Point (Prefab)](#teleport-point-prefab)
    + [Hand Hold Settings](#hand-hold-settings)
    + [Cameras](#cameras)
    + [Inspector Note](#inspector-note)
* [Map Entity Scripts/Prefabs](#map-entitiesprefabs)
    + [Nav Mesh Surface](#nav-mesh-surface)
    + [AI Agent](#ai-agent)
    + [Grabbable Entity](#grabbable-entity)
    + [Map Spawn Manager](#map-spawn-manager)
    + [Map Spawn Point](#map-spawn-point)
* [Loading Zones](#loading-zones)
    + [Multi Map Setup](#multi-map-setup)
    + [Zone Load Trigger](#zone-load-trigger)
    + [Multi Map Lightmapping](#multi-map-lightmapping)
* [Exporting and Uploading to Mod.io](#exporting-and-uploading-to-modio)
    + [Exporting](#exporting)
    + [Map Export Window](#map-export-window)
    + [Uploading to Mod.io](#uploading-to-modio)
* [Playing Your Map](#playing-your-map)

## Setup
This project is made with Unity version 6000.1.9f1. Higher or lower Unity versions may not work properly, so make sure 
to download it from the [Unity Archive](https://unity3d.com/get-unity/download/archive) if you don't have it already. 
It's recommended to use Unity Hub to make managing versions easier.

**MAKE SURE TO ADD ANDROID BUILD SUPPORT TO YOUR UNITY 6000.1.9f1 INSTALLATION!** This is needed to make sure your 
bundles properly support the Quest. Instructions can be found here: 
https://docs.unity3d.com/Manual/android-sdksetup.html

If you're developing on a Linux or Mac OS **MAKE SURE TO ADD WINDOWS BUILD STUPPORT TO YOUR UNITY 6000.1.9f1 INSTALLATION!** 
This is needed to make sure your bundles properly support Steam and Meta PC builds.

## Functionality Overview Map
Included in this project are 4 scenes called `FunctionalityOverview_StartingZone`, `FunctionalityOverview_DynamicLights`,
`FunctionalityOverview_OceanZone`, and `FunctionalityOverview_ScriptsZone`. Each of these scenes are part of the 
Functionality Overview map which provides comprehensive in-editor documentation and examples of how most functionality 
available for Custom Maps can be used. You can also check out this map in-game by subscribing to the 
[Functionality Overview](https://mod.io/g/gorilla-tag/m/functionality-overview?preview=8256e9b8f815e1d6c54ec02e25766f2f)
map on mod.io and then loading it up in Gorilla Tag. This map will continue to be updated with each new version of the 
example project to provide examples of any new functionality we add.

## Creating a map
For the most part, creating a map itself is the same as creating anything in Unity. However, there are a few specific 
things that you'll need to do to ensure that Gorilla Tag can load it correctly.

To load up the Unity project, go ahead and open up Unity or Unity Hub (Hub is recommended) and then click Open/Add and 
navigate to the downloaded + unzipped project. Navigate to the folder that contains the `Assets`, `Packages`, and 
`ProjectSettings` folders, then click `Select Folder`.

When creating a new map, you should first create a new Scene and load it up. Then create an empty GameObject that will 
hold everything in your map. Make sure the position is (0, 0, 0), and the scale is (1, 1, 1).

Next, click Add Component and add a Map Descriptor. This will hold some information about your map.

![mapdescriptor](https://github.com/user-attachments/assets/9988159b-9ff5-4660-93d6-30fcbd3458a0)

This component holds some general info about the scene and your map.

- `Add Skybox` - Check if you want to add a skybox to your scene
  - `Custom Skybox` - A cubemap that will be used as the skybox on your map. If this empty, it'll automatically give your map the default game skybox
  - `Custom Skybox Tint` - what color do you want to tint the skybox
- `Lighting Export Type` - How to handle exporting lighting data for your map. Please read the Lighting Section farther down for more information.
- `Export All Objects` - If checked, all GameObjects will be parented under the MapDescriptor prior to export. Otherwise any GameObjects not parented under the Map Descriptor will be destroyed.

## Accessing Your Map
In order for Players to be able to access your map, it's required to include an `AccessDoorPlaceholder` in whichever scene you have designated as your initial scene.  

Under MapPrefabs, there's an `AccessDoorPlaceholder` prefab. Drag it into your scene and place it wherever you'd like. 
This represents the `Lobby` room that Players will use to pick which map to load. The door should be able to open 
directly into the map. Ensure the Placeholder doesn't overlap with any other meshes or collision or it could cause issues
for Players trying to load into your map. 

Players should always be able to return to the "Lobby" room at any point to facilitate leaving your map. Don't put it 
somewhere difficult to reach.

NOTE: For any scene that is not your initial scene, use the `MapOrientationPoint` prefab.

## Matching Gorilla Tag's Style
Although not every custom map has to look exactly like the game, making your map look similar to the base game's visuals 
will help improve player experience, so here's a couple of tips:

To make your textures have the same low-poly PS2 style as Gorilla Tag, change the following settings:
- Filter Mode - Point (no filter) [This will ensure your textures aren't blurry]
- Max Size - 64/128/256 [This will depend on your texture's size and what you're using it on]
- Compression - None [This will make sure that your images don't get garbled by compression]

![default_best_textureSettings](https://github.com/user-attachments/assets/920305a3-efcd-43f2-88d2-e26f02addca6)


Additionally, if you want to make a model low poly you can add a Decimate modifier to it in Blender. Lower the threshold 
until the model looks low poly enough for you.

![decimate_modifier](https://github.com/user-attachments/assets/f66907c0-132a-431b-8139-0ea3c7e7c9d1)


## UberShader and Zone Shader Settings
You'll find the UberShader in the `Assets/Shaders/` folder. This is the main shader used by almost everything in 
Gorilla Tag and is provided as part of the Example Project primarily to support UberShader Dynamic Lighting and 
Zone Shader Settings which can be used to apply fog and underwater effects to anything using the UberShader. There 
are also some example UberShader materials in the `Assets/Materials/UberShaderMaterials` folder and the Functionality 
Overview scenes primarily use those UberShader materials.

### Zone Shader Settings
The `Zone Shader Settings` component is used to modify global shader variables that are used by the UberShader. Using
this component, you can add Ground Fog and Underwater/Lava Liquid effects to your map.
- Ground Fog has options for color, height, and distance fading
- Using Liquid Effects you can define a Liquid Type (Water or Lava) and Shape (Plane or Cylinder) in which you can apply
an underwater tint, underwater fog with distance fading, and underwater caustics.

It's highly recommended to check out the FunctionalityOverview scenes for examples and more information about Zone Shader Settings 
to get a better understanding for how they work. The `FunctionalityOverview_StartingZone` scene has an example setup with Default Shader 
Settings and Pool Shader Settings which use the Cylinder Liquid Shape option. The `FunctionalityOverview_OceanZone` scene has an example 
Ocean Shader Settings which uses the Plane Liquid Shape and has example Fog settings. The `FunctionalityOverview_ScriptsZone` scene has an 
example Lava Shader Settings which also uses the Plane Liquid Shape but with the Lava Liquid Type and has some different example Fog settings.

### Zone Shader Settings Trigger
The `Zone Shader Settings Trigger` and prefab found in `Assets/MapPrefabs/` can be used to switch between different 
`Zone Shader Settings`. It can be used with a Collider component with `IsTrigger` set to TRUE, or it has an option 
called `Activate On Enable` which, if set to TRUE, can be used alongside an `Object Activation Trigger`.

## Lighting
An important part of making a map look good is the lighting. Since Gorilla Tag bakes lighting, the process to get it 
working is a bit involved, but it's absolutely worth it.

**When you SHOULD use lighting:**
- Most maps
- Complex maps with many objects
- Maps that need shadows
- Maps with reflections

**When you SHOULDN'T use lighting:**
- Maps that consist of mostly Unlit shaders
- Maps where shadows aren't important
- Maps that really need to save filesize

If your map falls under the "SHOULDN'T USE LIGHTING" category, you can set your map's `Export Lighting` value to `Off` 
and ignore the rest of this section.

![lightingoptions](https://github.com/user-attachments/assets/072dce93-dd7a-41c2-ad4e-9c80baceee0c)

Otherwise, follow these steps to getting lighting looking nice on your map:

### General Lighting Setup
Make sure to set your map's `Export Lighting` value to `Default_Unity` or `Alternative`, the rest of these instructions 
assume you're using the `Default_Unity` option.

Click on your map's GameObject, and set the `Static` value next to the name in the properties window to true.

When ask if you'd like to enable the static flags for all the child objects, click `Yes, change children`

Every object on your map should be static EXCEPT for:
- Objects that have an animation
- Objects that will somehow change or get enabled/disabled, such as a trigger
- Objects that should not have shadows or lighting applied to them

### Lighting Meshes
When you're initially importing a mesh, go to the properties and make sure that the `Generate Lightmap UVs` box is checked.

Go through all of your imported meshes now and make sure it's enabled for **all of them!** (unless you know what you're 
doing and have applied Lightmap UVs in an external program)

Next, go to each object with a `Mesh Renderer` in the scene, and ensure that `Contribute Global Illumination` is enabled. 
If you want to disable an object Receiving/Casting shadows, you can change the `Cast Shadows` and `Receive Shadows` 
properties - otherwise, leave them as the default values.

### Lights
The `Functionality Overview` scenes are setup with baked lighting and have a `Sunlight` directional light that can be used
as a reference. You can add any other sort of `Light` to your map that you want, but ensure that the type is set to `Baked`.

### Other Tips
Map compile time when baking lighting for the first time may be high. There's not much of a workaround here, so just 
wait for it to finish. Subsequent exports will be significantly faster.

If your map is too big or laggy after adding lighting, you can change these values in Window/Rendering/Lighting Settings:
- Lightmap Resolution (Default 32) - Change to 16 or 8
- Lightmap Size (Default 512) - Change to 256 or 128

By default, your map preview in-editor won't have shadows or proper lighting. If you want a preview of how it looks, 
go to `Window/Rendering/Lighting Settings` and click `Generate Lighting` in the bottom right. If you want to get rid of 
the baked preview data, click the little arrow next to `Generate Lighting` and click `Clear Baked Data.`

If your map is looking too light or you want to play around with how the lighting works, try adjusting the intensity of 
the included `Directional Light.`

If some materials look washed out ingame, try changing these settings on those materials:
- Set Metallic to 0
- Set Smoothness to 0
- Turn off Specular Highlights
- Turn off Reflections

## UberShader Dynamic Lighting
Another lighting option available for Custom Maps that utilize the UberShader is `Uber Shader Dynamic Lights`. 
These use the same lighting system as the Ghost Reactor area in Gorilla Tag. To enable this on your map use the
`Use Uber Shader Dynamic Lights` option on the MapDescriptor if you want to enable it as soon as your map is loaded. 
Or you can use `Zone Load Triggers` to enable/disable UberShader Dynamic Lighting when loading or unloading a Zone. 
Currently only Point Lights are supported by this system and any lights you want to use for `Uber Shader Dynamic Lighting` 
need to have the `UberShaderDynamicLight` component on them. You can also use the `UberShaderDynamicLight` prefab 
located in the `Assets/MapPrefabs/` folder. The `FunctionalityOverview_DynamicLights` scene has some examples of 
UberShader Dynamic Light usage that you can use as reference. 

## Trigger Scripts/Prefabs
The following scripts can be used for multiple purposes, but the GameObject they are attached to will always need a Collider 
component with `Is Trigger` set to true. All trigger scripts have several common options: 
- `Synced To All Players` - Should this Trigger sync to all players, or only be processed for the person who triggered it?
    - Generally this will sync the Trigger Activation event as well as its current `Trigger Count` (used to check against
    `Num Allowed Triggers`).
- `Triggered By` - Defines which parts of the player will trigger this Trigger.
    - Options include Hands, Body, Head, BodyOrHead. Due to how Hand and Body/Head colliders work in GorillaTag, a single Trigger is
    unable to check for both at the same time.
- `On Enable Trigger Delay` - After being enabled, how long before this Trigger can be triggered? Useful when setting up overlapping Triggers.
- `General Retrigger Delay` - After being triggered, how long before this Trigger can be triggered again?
- `Num Allowed Triggers` - How many times is this Trigger allowed to trigger? 0 means infinite
- `Retrigger After Duration` - Should this Trigger re-trigger if a player stays inside it for long enough?
- `Retrigger Stay Duration` - How long does a player need to stay inside the Trigger before it re-triggers?
    - NOTE: If `General Retrigger Delay` is larger, that value will be used for this instead.

### Map Boundary
This trigger script will teleport the player to a random (or specific) Transform and optionally can Tag the player when 
triggered. It can be used in multiple ways, but the main intent was for it to be used as a way to prevent players from 
escaping your map. This script is included in the `MapBoundary` prefab in the `Assets/MapPrefabs/` folder which uses a 
Box Collider and includes a visual preview. Check out each of the FunctionalityOverview scenes for some examples.

**Additonal Options**
- `Teleport Points` - One or more points the player will be teleported to when activating this trigger. If more than one
  point is defined, it will be chosen at random.
- `Should Tag Player` - Should the player be tagged when activating this trigger?
 
### Teleporter
This trigger script will teleport the player to a random (or specific) Transform. This script is included in the `Teleporter` 
prefab in the `Assets/MapPrefabs/` folder which uses a Box Collider and includes a visual preview. 
Check out the FunctionalityOverview scenes for some examples.

**Additonal Options**
- `Teleport Points` - One or more points the player will be teleported to when activating this trigger. If more than one
  point is defined, it will be chosen at random.

### Tag Zone
This trigger script will Tag any activating player. This script is included in the `TagZone` prefab in the `Assets/MapPrefabs/` 
folder which uses a Box Collider and includes a visual preview.

### Object Activation Trigger
This trigger script can be used to Activate and Deactivate other GameObjects in your map and Reset other Triggers. This script is 
included in the `ObjectActivationTrigger` prefab in the `Assets/MapPrefabs` folder which uses a Box Collider and includes a visual preview.
Check out the FunctionalityOverview scenes for some examples.

**Additional Options**
- `Objects To Deactivate` - List of GameObjects that will be Deactivated when this Trigger is triggered. This list is processed prior
  to `Objects To Activate`.
- `Objects To Activate` - List of GameObjects that will be Activated when this Trigger is triggered. This list is processed after
  `Objects To Deactivate`.
- `Triggers To Reset` - List of Triggers that will be Reset when this Trigger is triggered
   - Reseting a trigger means its current `Trigger Count` and `Last Trigger Time` will be reset. GameObjects in the activate/deactivate
     lists are not affected by this. 

## Play Animation Trigger
This trigger script can be used to activate an animation state on all Animator components on the specified GameObjects.

**Additional Options**
- `Animated Objects` - which GameObjects should activate the specified Animation state Name
- `Animation Name` - the name of the Animation state that will be activated 

## Placeholder Script and Prefabs
The `GTObjectPlaceholder` script defines an object that will get replaced by an existing Gorilla Tag script/object when your map is loaded 
in-game. Each has a prefab in the `Assets/MapPrefabs/` folder that can or should be used depending on the placeholder selected for 
the `Placeholder Object` setting.

### Force Volume 
This is used in Gorilla Tag for things like the elevator to Sky Jungle and the invisible wind barriers preventing players from 
falling out of the that map. The `ForceVolumePlaceholder` prefab has the `GTObjectPlaceholder` script setup to use the `Force Volume` 
option and includes some default settings (each of which has a tooltip when hovered that provides more info). The prefab includes a visual 
preview and can be scaled as desired. 
If you'd like to customize the collider shape used for a Force Volume, you can set the `Use Default Placeholder` option to FALSE, 
and add your collider component alongside the `GTObjectPlaceholder` script.
Check out the `FunctionalityOverview_StartingZone` scene for some examples.

### Leaf Glider 
The `LeafGliderPlaceholder` prefab has the `GTObjectPlaceholder` script setup to use the `Leaf Glider` option and includes a visual preview 
to assist with placement. It's recommended to **ONLY** use this prefab when using the `Leaf Glider` option on the `GTObjectPlaceholder` 
script. Scaling the placeholder will not affect the leaf glider that it gets replaced with.
Check out the `FunctionalityOverview_StartingZone` scene for some examples.

### Glider Wind Volume 
This is used in Gorilla Tag in Sky Jungle to send the Leaf Gliders into the air. The `GliderWindVolumePlaceholder` prefab has the 
`GTObjectPlaceholder` script setup to use the `Glider Wind Volume` option and includes some default settings. It also includes a visual 
preview, but if you change the `Local Wind Direction` setting the arrows in the preview will not be pointed the correct way. This 
prefab/placeholder can be scaled as desired. 
If you'd like to customize the collider shape used for a Glider Wind Volume, you can set the `Use Default Placeholder` option to FALSE, 
and add your collider component alongside the `GTObjectPlaceholder` script.
Check out the `FunctionalityOverview_StartingZone` scene for some examples.

### Water Volume
Using this placeholder you can define a swimmable water volume. This works best when combined with `Zone Shader Settings` underwater effects.
The `WaterVolumePlaceholder` prefab has the `GTObjectPlaceholder` script setup to use the `Water Volume` option with some default settings. 
It includes a visual preview and can be scaled as desired.
If you'd like to customize the collider shape used for a Water Volume, you can set the `Use Default Placeholder` option to FALSE, 
and add your collider component alongside the `GTObjectPlaceholder` script.
Check out the `FunctionalityOverview_StartingZone` and `FunctionalityOverview_OceanZone` scenes for some examples.

### Hoverboard Area
The Hoverboard Area placeholder allows you to define an area where players are allowed to use Hoverboards. The `HoverboardArea` prefab has the 
`GTObjectPlaceholder` script setup to use the `HoverboardArea` option and a Box Collider component. This option for the `GTObjectPlaceholder` 
script *requires* a Collider component to function correctly. 
Check out the `FunctionalityOverview_StartingZone` scene for some examples.

### Hoverboard Dispenser
For players to actually have access to Hoverboards in your map, you'll need to add some `HoverboardDispenser` placeholder prefabs. These need
to be placed *inside* a `HoverboardArea` to function correctly. 
It's recommended to **ONLY** use this prefab when using the `Hoverboard Dispenser` option on the `GTObjectPlaceholder` 
script. Scaling the placeholder will not affect the Hoverboard Dispenser that it gets replaced with.
Check out the `FunctionalityOverview_StartingZone` scene for an example.

### Rope Swing
Using the `Rope Swing` option on the `GTObjectPlaceholder` component will allow you to place Rope Swings in your map. They have a `Rope Length`
option to customize how long the rope is and will show a preview of what to expect when your map is loaded in Gorilla Tag. 
Check out the `FunctionalityOverview_StartingZone` scene for some examples.
If you'd like to customize the look off your ropes or want them included in your light bake, you can set the `Use Default Placeholder` option to FALSE, 
which will then give you access to two new options: 
- `Rope Swing Segment Prefab` - the prefab to use for your rope segments, some example prefabs are provided in the `GorillaTagAssets/RopeAndZiplineSegments/Prefabs` folder
- `Rop Segment Generation Offset` - this controls the distance between rope segments when the `Generate Rope Swing` button is pressed.
Once you select your prefab click the `Generate Rope Swing` button to generate your rope swing. If you'd like your rope swing to be light baked, you can then 
modify the Rope Swing Segment prefab you're using and enable the "Contribute Global Illumination" on the Mesh object in the Prefab.

### Zipline 
Use the `ZiplinePlaceholder` prefab to put ziplines in your map. The Zipline placeholder utilizes the `Bezier Spline` component to define
the shape of the zipline. By default it starts out with only 2 spline points that you can adjust, but you can add more points by clicking the
`Add Curve` button on the `Bezier Spline` component. Once you've adjusted the spline to your liking, you can press the `Click to generate preview mesh`
button on the `GTObjectPlaceholder` component to see a preview of what to expect when your map is loaded in Gorilla Tag.
Check out the `FunctionalityOverview_StartingZone` scene for some examples.
If you'd like to customize the look off your ziplines or want them included in your light bake, you can set the `Use Default Placeholder` option to FALSE, 
which will then give you access to two new options: 
- `Zipline Segment Prefab` - the prefab to use for your zipline segments, some example prefabs are provided in the `GorillaTagAssets/RopeAndZiplineSegments/Prefabs` folder
- `Zipline Segment Generation Offset` - this controls the distance between zipline segments when the `Generate Zipline` button is pressed.
Once you select your prefab click the `Generate Zipline` button to generate your zipline. If you'd like your zipline to be light baked, you can then 
modify the Zipline Segment prefab you're using and enable the "Contribute Global Illumination" on the Mesh object in the Prefab.

### ATM
Using the `ATM_CustomMesh` or `ATM_FullReplacement` prefabs, you can give players access to an ATM in your map. It has an option to set a 
Default Creator Code. It's recommended to **ONLY** use one of these prefabs when using the `ATM` option on the `GTObjectPlaceholder` script. 
Scaling the placeholder will not affect the ATM that it gets replaced with. Check out the `FunctionalityOverview_StartingZone` scene for an example.
For more information about creator codes and how to apply, please refer to this 
[announcement post](https://discord.com/channels/671854243510091789/804747032651628615/1352342582717452371) in the Gorilla Tag Discord.

### Store Placeholders
There are several placeholder options related to cosmetic shop functionality. These can be used to provide players with a way
to purchase/try-on specific cosmetics from rotating list in your map. These include:
- `Store_DisplayStand` - Shows a specific cosmetic from a set of 12 that are available in custom maps. The available items will change occasionally.
- `Store_Checkout` - Gives players a place to purchase cosmetic items while in your map. Use the `Use Custom Mesh` option to allow for baked lighting
- `Store_TryOnConsole` - Gives players a place to try-on any cosmetics currently in their cart. Use the `Use Custom Mesh` option to allow for baked lighting
- `Store_TryOnArea` - Allows players to equip try-on cosmetics while inside this area. The Try-On console needs to be within a Try-On Area to function correctly.
  - Try-On Areas are restricted in their size to a maximum volume of 64 (x scale * y scale * z scale), if they are too big they will not be replaced when your map is loaded.
There are prefabs for each of these in the `Assets/MapPrefabs/` folder. Check out the MiniShop area in the `FunctionalityOverview_StartingZone` scene for some examples. 

## Other Scripts/Prefabs

### Surface Override Settings
If you want to modify how climbing works on an object, you can add a `Surface Override Settings` script to it.

**Script Options:**
- `Sound Override` - Used to customize what sound plays when a Player hits the object.
- `Extra Vel Multiplier` - A number that influences how much extra velocity is gained when a player jumps off the object.
  (Must be higher than 1)
- `Extra Vel Max Multiplier` - A number that defines the maximum extra velocity multiplier applied when a player jumps off the
  object. (Must be higher than 1)
- `Slide Percentage` - A number that decides how "slippery" an object is when used for climbing. Default value is 0.0 which is
  the least slippery an object can be. Higher values are more slippery with a maximum of 1.0 meaning the object is unclimbable.

Each of the FunctionalityOverview scenes has examples of this, but the `FunctionalityOverview_OceanZone` scene has some specific examples of the Sound Override setting, 
and the `FunctionalityOverview_ScriptsZone` scene has an example of the Extra Vel settings.

### Surface Mover Settings
You can setup moving surfaces using the `Surface Mover Settings` script component, these are automatically synced between all players.

**Script Options:**
- `Move Type` - How should the object move, options are `Translation` and `Rotation`.
- `Velocity` - Meters per second for `Translation` move type | Revolutions per second for `Rotation` move type
- `Cycle Delay` - Adds a delay equal to half this value in seconds to the beginning and end of the movement cycle. 
- `Reverse Dir` - Will reverse the movement direction 
- `Reverse Dir On Cycle` - Will reverse the movement direction when reaching the start or end of the movement cycle 
- `Start` (only for `Translation` move type) - The starting transform for the movement cycle
- `End` (only for `Translation` move type) - The ending transform for the movement cycle
- `Rotation Axis` (only for `Rotation` move type) - Which local axis should the object rotate on 
- `Rotation Amount` (only for `Rotation` move type) - How many degrees (0-360) should the object rotate in one cycle
- `Rotation Relative to Starting` (only for `Rotation` move type) - If TRUE the rotation starting point will be the initial rotation value of the 
object when the map is loaded, otherwise it will start at 0"

### Moving Surface Settings
This component can be used with `Surface Mover Settings` to indicate that the player should move along with a specific moving GameObject if they are standing on it. 
You can put this on the same GameObject as the `Surface Mover Settings` component, or any child GameObjects that are affected by the `Surface Mover Settings`.

### Access Door Placeholder
This is used for positioning your iniital scene in the correct place so it lines up with the "Lobby" room in GorillaTag. This script
is already part of the `AccessDoorPlaceholder` prefab in MapPrefabs, so it's not necessary to manually add this to anything.
There should only be one `AccessDoorPlaceholder` script component in your map, if you place multiple, only one will be valid.

### Map Orientation Point
For all scenes that are not your initial scene use the `MapOrientationPoint` prefab. It serves the same purpose as the `AccessDoorPlaceholder` in that
it positions and orients your map. As with the `AccessDoorPlaceholder` there should only be one `MapOrientationPoint` in your scene.
IMPORTANT: Make sure that all `MapOrientationPoint` prefabs have the same position and orientation as the `AccessDoorPlaceholder` prefab or your
scenes won't load in correctly.

### Hand Hold Settings
This component can be used to create grab points in your map. It needs to be added to a GameObject alongside a Collider component.

**Script Options:**
- `Hand Snap Method` - Used to change if and how the players hand will snap to the mesh when they grab it.
- `Rotate Player When Held` - Used if you want the player to be able to rotate their body while grabbing this object
- `Allow Pre Grab` - Used to allow players to press the Grab button before actually colliding with this object, and still allow the grab.
Check out the `FunctionalityOverview_ScriptsZone` scene for some examples.

### Custom Map Eject Button Settings
This component can be used to create a button that when pressed can either teleport them back to the Virtual Stump, or return them to the 
Arcade or Stump (wherever they entered the Virtual Stump from).

**Script Options:**
- `Eject Type` - Used to set if the player is returned to the Virtual Stump or ejected completely.
Check out each of the FunctionalityOverview scenes for some examples.

### Destroy Pre Export
This is used to destroy in-editor visualization helpers and other editor-only objects to ensure they don't end up in your 
exported map. You can attach this script to any GameObject that should **NOT** be included in your exported map.

### Inspector Note
This is used extensively in the Functionality Overview scenes to provide more information on how things are setup. You can use this for any
kind of notes you'd like to add on GameObjects. This component will be removed during the export process so it's only present while in-editor.

### Teleport Point (Prefab)
This is a simple prefab that is essentially just a visual preview to show where you've placed them in your map. Can be used with the 
`MapBoundary` and `Teleporter` scripts to define teleport destinations.

### Cameras
Cameras are allowed as long as they are being used for Render Textures. Any cameras not using Render Textures will be deleted when loading your map.
Check out the `FunctionalityOverview_StartingZone` scene to see an example of how a Camera + Render Texture can be used to create a mirror.

## Map Entities/Prefabs
Map Entities are objects you can create at runtime and sync across all players in the map. It's highly recommended to look at the AI And Grabbable section of the `FunctionalityOverview_StartingZone`
scene to get a better understanding of how these components are used. Map Entity Support is currently limited to single-zone maps; Multi-zone maps
may encounter problems while loading or spawning AIAgents and Grabbable Entities. Map Entity Support also relies heavily on Lua currently, check out the `FunctionalityOverview` Luau
script for an example of working with Map Entities. Additonal non-Lua support will be added with future updates.
There are currently two types of Map Entities available: AIAgents and GrabbableEntities.

### Nav Mesh Surface
The `NavMeshSurface` component can be used in Custom Maps to create a navigable area for AI Agents. There are currently 4 supported NavAgent sizes 
available for Custom Maps: Humanoid, Small, Medium, and Large. Check the `Window > AI > Navigation` window in Unity to see the specific settings for each Agent size.
You can also check out the `SmallAgent`, `MediumAgent`, and `LargeAgent` prefabs in the `Assets/Prefabs/FunctionalityOverview/AI/` folder for a visual
representation of 3 of the agent sizes. There is no prefab for the Humanoid NavAgent type, but you are still able to use it if desired. It is also the type
used for Ghost Reactor. 
To setup a new `NavMeshSurface` component, make sure to set the `AgentType` to one of the supported options, and click the `Bake` button to create the 
Nav Mesh itself. You can use the `Show Gizmos` button on the Scene viewport to see a preview of your baked NavMesh. Check out the AI Section of the 
`FunctionalityOverview_StartingZone` for an example NavMesh setup.

![NavMesh](https://github.com/user-attachments/assets/6ad79039-231e-498a-bdab-f973d6eab6ac)

### AI Agent
The `AIAgent` component is used to define a new AI Agent. It is highly recommended that you create a Prefab for each of your AI Agent types.
Check out the `FunctionalityOverview_StartingZone` scene's AI And Grabbable section for an example setup. 

`AIAgent` has two important properties that handle how they are spawned:
- `IsTemplate` - If checked, this `AIAgent` and all it's child GameObjects will be used as the base to spawn duplicated AI Agents for both pre-placed and Lua-spawned
  agents. Each of your `AIAgent` types must have a version with `IsTemplate` set to true as a child of the `MapSpawnManager` in your map or pre-placed and Lua-spawned
  Agents of that type will not be created.
- `EntityTypeID` - This is used to distinguish each Agent type that the `MapSpawnManager` can create. Make sure each `IsTemplate` Agent you created has a unique `EntityTypeID`.
  On pre-placed AI Agents, this is used to tell the `MapSpawnManager` which Agent type to spawn in it's place.

Most other options for `AIAgent` are only editable on AI Agents with `IsTemplate` set to true. These properties control various settings for Navigation and Sight.

![aiagentprops](https://github.com/user-attachments/assets/b1435529-5ae9-4ae6-bf6b-25c7cbd261e2)

There is one other setting specific to pre-placed AI Agents that is relevant if you intend on controlling the Agent with Lua scripting. This is the `Lua_EntityID`, which
is only visible when `IsTemplate` is set to false. It is not manually editable, but can be generated by clicking `Tools > Generate Lua Map Entity IDs`. This will generate
a unique ID for each of your pre-placed AI Agents that can be used to get a reference to the Agent in Lua. Check out the `FunctionalityOverview_StartingZone` scene and the
`FunctionalityOverview` Luau script for an example of how this ID is used.

### Grabbable Entity
The `GrabbableEntity` component is used to define an object that players can pick up and throw. It is highly recommended that you create a Prefab for each of your Grabbable Entity types.
Check out the `FunctionalityOverview_StartingZone` scene's AI And Grabbable section for an example setup. 

`GrabbableEntity` has two important properties that handle how they are spawned:
- `IsTemplate` - If checked, this `GrabbableEntity` and all it's child GameObjects will be used as the base to spawn duplicated Grabbable Entities for both pre-placed and Lua-spawned
  entities. Each of your `GrabbableEntity` types must have a version with `IsTemplate` set to true as a child of the `MapSpawnManager` in your map or pre-placed and Lua-spawned
  entities of that type will not be created.
- `EntityTypeID` - This is used to distinguish each entity type that the `MapSpawnManager` can create. Make sure each `IsTemplate` entity you created has a unique `EntityTypeID`.
  On pre-placed Grabbable Entities, this is used to tell the `MapSpawnManager` which entity type to spawn in it's place.

Most other options for `GrabbableEntity` are only editable on Grabbable Entities with `IsTemplate` set to true.

![grabbableentityprops](https://github.com/user-attachments/assets/bb3f8aa6-c8a4-445b-a981-28e3e9560ff6)

Like AI Agents, Grbabbable Entities have a `Lua_AgentID`, which is only visible when `IsTemplate` is set to false. It is not manually editable, but can be generated 
by clicking `Tools > Generate Lua Map Entity IDs`. This will generate a unique ID for each of your pre-placed Grabbable Entities that can be used to get a reference to the 
entity in Lua. Check out the `FunctionalityOverview_StartingZone` scene and the `FunctionalityOverview` Luau script for an example of how this ID is used.

### Map Spawn Manager
This component is required to utilize the AI Agent and Grabbbable Entity support for Custom Maps. AI Agents and Grabbable Entities in your scene with `IsTemplate` set to true must be children of the GameObject with the 
`MapSpawnManager` component for them to function correctly. Pre-placed AI Agents and Grabbable Entities do NOT need to be children of the `MapSpawnManager`.

### Map Spawn Point
There is also the `MapSpawnPoint` component and the `CustomMapSpawnPoint` prefab, these aren't currently required for spawning entities via Lua, but will be used in a future 
update to allow for a non-Lua spawn method.

## Loading Zones

If you want to break up your map into multiple scenes, you can use the `ZoneLaodTigger` prefab to load and unload those scenes. Check out the FunctionalityOverview scenes 
for an example Loading Zone setup.

### Multi Map Setup
ALL scenes you want included in your map need to be added to the `Scenes In Build` section of the `Build Settings` window.
Select the `MapDescriptor` object in the scene you want to load first and check `IsInitalScene` in the `Inspector` window.
Only one scene should be marked as your initial scene otherwise the importer will grab the first initial scene it finds and load that first.
To make sure all your scenes line up correctly with each other, open your main scene and then select the other scenes from the `Project`
window and drag them into the `Hierarchy` window. The scenes should appear in the `Scene` view and you can edit them as needed.
Add a `MapOrientationPoint` prefab to each scene that is not your intial scene and make sure they all have the same position and rotation
as the `AccessDoorPlaceholder` prefab in your initial scene.
Add the `ZoneLoadTrigger` prefab where you a scene load/unload to occur. Make sure the prefab is in the correct scene.

### Zone Load Trigger
This is the prefab used to determine where scenes are loaded and/or unloaded. It contains the `LoadZoneSettings` script, a `Box Collider`, and
a preview mesh to help with sizing and placement. All scenes added to the `Scenes In Build` section of the `Build Settings` window will be listed 
under the `Load Zone Settings` script in two sections: `Scenes to Load` and `Scenes to Unload`. The `Use Dynamic Lighting` option allows you to 
change the state of UberShader Dynamic Lighting via the Zone Load Trigger. 

### Multi Map Lightmapping
Currently there are only two ways to use lightmaps with loading multiple scenes
- Open all scenes at the same time in editor and lightmap all scenes at once
- Create a lightmap for each scene individually
Creating two or more lightmaps for the same scene is not supported at this time.


## Exporting and Uploading to Mod.io

### Exporting

Once your map is all done, it's time to export! First, let's run through our checklist:

- Did you add Colliders to Objects that the player needs to collide with?
    - Make sure your colliders match fairly closely to the mesh shape.
    - Avoid using too many Mesh Colliders if possible, instead use Box or Sphere colliders
  (if you know what you're doing, you can always create lower poly versions of your meshes to use for the colliders)
- Did you completely fill out your `Map Descriptor`?
- Did you add the `AccessDoorPlaceholder` prefab to your initial scene?
    - It's required to have an `AccessDoorPlaceholder` in your initial scene, or you won't be able to export.
    - Brush back over the tips in the [Accessing Your Map section](#accessing-your-map) if needed
- Did you add the `MapOrientationPoint` prefab to your other scenes?
- Did you read over the [Lighting section](#lighting) and follow all the steps?

If you want to use a custom skybox, import it into your Unity project as an image, set the `Texture Shape` to Cube 
and assign it to the `Custom Skybox` property on your `Map Descriptor`

### Map Export Window
Now that you've gone over the checklist, it's time to export! In the toolbar got to `Tools > Export Maps`
A new window will open containing two tabs with functionality to help you export your map.

MAP EXPORT SETTINGS
This tab contains all the export settings for your map.
- `Is Initial Scene` - If checked, this is scene will be initially loaded in game when a player loads up your map. Multiple scenes can be set as an Initial Scene.
- - `Dev Mode` - If checked, this will enable you to reload the LUA script for your map when in the CUSTOM game mode. When `Dev Mode` is enabled
  you can press the Secondary Face buttons on both controllers to reload the LUA script for your map. Optionally you can put a LUA script at
  `<AppData>/LocalLow/Another Axiom/Gorilla Tag/script.luau` and if present, that script will be loaded when you reload the LUA script instead
  of the one packaged with your map.
- `Max Players` - Use this to set the maximum amount of players allowed in Public rooms for your map. This setting is ignored for Private rooms.
- `Use Uber Shader Dynamic Lighting` - If checked, UberShader Dynamic Lighting will be enabled when the initial scene is loaded
  - `Uber Shader Ambient Dynamic Light` - This is the ambient color applied to anything not currently lit up by an UberShader Dynamic Light.
- `Custom Gamemode` - Add a Text Asset here for any gamemode logic you created using LUA
- `Return to Virtual Stump Watch Button Settings` - this section contains several settings for the "Return to Virtual Stump" watch button that
  players have on their left hand when inside a Custom Map.
  - `Watch Hold Duration` - This controls how long the player must press the watch button before they're returned to the Virtual Stump.
  - `Watch Should Tag Player` - If checked, when the player uses the watch button, they will be tagged.
  - `Watch Should Kick Player` - If checked, when the player uses the watch button, they will be kicked from their current Public room. Does not kick players in Private rooms.
  - `Watch Infection Override` - If checked, you'll see the same options listed above, but specific to the Infection Game Mode, use this if you want to specify different watch settings for Infection
  - `Watch Custom Mode Override` - If checked, you'll see the same options listed above, but specific to the Custom Game Mode, use this if you want to specify different watch settings for Custom
- `Warnings prevent Export` - If checked, any warnings found while exporting maps will cancel the export.

Clicking `Export Map` at the bottom opens up to the `Exports` folder, but you can select any folder to export to. Click save, and once the export is 
finished you'll have a `.zip` file that's ready to upload to [Mod.io](https://mod.io/g)

MAP VALIDATION
This tab allows you run a validation check on your map(s) before exporting.
Any Errors or Warnings will be listed here and you can click the `Select` button to select the object the warning was found on.

### Uploading to Mod.io

After you've exported your map and have a `.zip` file ready, you can now upload your map to [Mod.io](https://mod.io/g). 
Go to [https://mod.io/g/gorilla-tag](https://mod.io/g/gorilla-tag) and create an account if you haven't already. 
Once you're logged in, click the `Add Level` button on the top right. 

![addLevelbutton](https://github.com/user-attachments/assets/b3d10471-e843-4442-8acc-5b85d51446d4)


On the following page you'll need to fill out some info about your map. 
The required fields are:
- Name - *try to make this unique to your map*
- Summary - *a brief summary of your map (minimum of 10 characters)*
- Logo - *this is the main image shown when players are browsing available maps*

The other fields are all optional, but be sure to fill out any information you'd like to. 

![requiredfields](https://github.com/user-attachments/assets/1d663db1-2bdf-4878-8c6b-4193a7ebc356)

Once your done filling out basic information, click the `Create Level` button at the bottom of the page.
On the next page are more optional fields. You can upload more screenshots of your map, link to a Youtube channel, or add links to
Sketchfab models.
Once you're done on that page click the `Save & next` button at the bottom of the page.

![media](https://github.com/user-attachments/assets/310fb041-84d3-4272-a4eb-c667ed519c85)

The next page is where you will upload your `.zip` file you exported from Unity. Click the `Select zip file` button and find the 
`.zip` file you exported. You can also add a Version number and Changelog with this file and each additionl file you upload. Once 
you've selected your `.zip` file and filled out any desired fields, make sure you read and agree to the mod.io Terms and Conditions 
and check the `I agree` box, then click the `Upload & next` button to continue.

![selectfile](https://github.com/user-attachments/assets/ce2405e7-830d-4631-bf97-c7a9e84a19f7)


The next page is for selecting any dependencies. This is currently unsupported for Gorilla Tag so you can just click the `Save & 
next` button at the bottom of the page to continue. You'll then be taken to the overview page for your map. At the top of this page 
are 2 important things to be aware of: Level Status and Level Visibility. 

- Level Status refers to the approval status of your map. All maps must be verified and approved by a Gorilla Tag moderator before
  they will be available to players in-game or on the mod.io website.
  In order for a map to be approved, it must go through an approval process. For more information, please visit the Community Modding Discord here: https://discord.gg/mzTFwPRhQ5
- Level Visibility refers to the public visibility of your map. If it's hidden it will only be available to pre-existing subscribers
  and anyone added to the map's Team.

Your map must be approved and visible to the public for players to be able to see and download it in-game. 

![status](https://github.com/user-attachments/assets/e2e44113-78c2-4350-be18-ccf2b13fadcc)

If you'd like to see what other players see when browsing mod.io, you can click the `View Level` button on the top-right of this 
page. You can also subscribe to your map on this page, just make sure to link and use the same mod.io account in-game or 
subscriptions on the website won't show up in Gorilla Tag. 

![subscribe](https://github.com/user-attachments/assets/4d89d3b3-3985-488d-b6d4-4f8f7b3f506f)

## Playing Your Map
Once you've created an entry on mod.io, uploaded your map, and subscribed to it on the mod.io website you're now ready to test it 
out in-game. Keep in mind that only you and members of your map's Team on mod.io will be able to see the map in Gorilla Tag until it 
is approved by a moderator and you must subscribe to it on the website before being able to see it in-game. 

  1. Launch Gorilla Tag on Steam/Quest and head to the Arcade which can be found in the City area.
     ![tunnel-to-arcade](https://github.com/user-attachments/assets/971da632-356a-4e45-8b25-95eefcde6f98)
     ![ramps-to-arcade](https://github.com/user-attachments/assets/b87e0624-54ba-4566-8fa0-1cc6988c16ff)

  3. Once in the Arcade, locate the green VR Game Machines and put your face up to the goggles on one of them. You'll see a short
     countdown before being automatically logged in to mod.io using your Steam/Oculus account and sent to the Virtual Stump.
     ![vr-machines](https://github.com/user-attachments/assets/e5bc9ef9-f9e0-4918-87e1-6cd438c23110)

  5. Once in the Virtual Stump, you'll need to approach the `Mod.io Account Options` screen and press the `LINK MOD.IO ACCOUNT`
     button to login with your pre-existing mod.io account (the same one you used to upload your map).
     ![account-options-terminal](https://github.com/user-attachments/assets/8a654942-c709-4af7-af5f-0a5f1896d70b)

  6. After successfully linking your account you can approach the large screen next to the door called the Maps Terminal. Press the
     `TERMINAL CONTROL` button to take control of the terminal and you'll see a list of all the Approved/Public maps that are
     available.
     ![maps-terminal](https://github.com/user-attachments/assets/2fcd4c6a-88d8-4324-b12f-9f5456e64247)

  8. Press the `OPTION` button to switch the view to `SHOW INSTALLED MAPS ONLY` and you should see your map in that list as long as
     you are subscribed to it on the mod.io website.
  9. Press the `SELECT` button to load your map and the doors should open to it once loading is finished.

If your map doesn't look quite right in-game, read back over the [Lighting section](#lighting)

---

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg
