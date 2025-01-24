[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

# GT_CustomMapExample
A Unity project to facilitate the creation of custom maps for Gorilla Tag. 

**Contents**

* [Setup](#setup)
* [Creating a map](#creating-a-map)
* [Accessing Your Map](#accessing-your-map)
* [Matching Gorilla Tag's Style](#matching-gorilla-tags-style)
* [Lighting](#lighting)
    + [General Lighting Setup](#general-lighting-setup)
    + [Lighting Meshes](#lighting-meshes)
    + [Lights](#lights)
    + [Other Tips](#other-tips)
* [Trigger Scripts](#trigger-scriptsprefabs)
    + [Map Boundary](#map-boundary)
    + [Teleporter](#teleporter)
    + [Tag Zone](#tag-zone)
    + [Object Activation Trigger](#object-activation-trigger)
* [Placeholder Script and Prefabs](#placeholder-script-and-prefabs)
    + [Force Volume](#force-volume)
    + [Leaf Glider](#leaf-glider)
    + [Glider Wind Volume](#glider-wind-volume)
    + [Water Volume](#water-volume)
* [Other Scripts](#other-scriptsprefabs)
    + [Surface Override Settings](#surface-override-settings)
    + [Access Door Placeholder](#access-door-placeholder)
    + [Destroy Pre Export](#destroy-pre-export)
    + [Teleport Point (Prefab)](#teleport-point-prefab)
* [Loading Zones](#loading-zones)
    + [Multi Map Setup](#multi-map-setup)
    + [Zone Load Trigger](#zone-load-trigger)
    + [Multi Map Lightmapping](#multi-map-lightmapping)
* [Exporting and Uploading to Mod.io](#exporting-and-uploading-to-modio)
    + [Exporting](#exporting)
    + [Uploading to Mod.io](#uploading-to-modio)
* [Playing Your Map](#playing-your-map)

## Setup
This project is made with Unity version 2022.3.2f1. Higher or lower Unity versions may not work properly, so make sure 
to download it from the [Unity Archive](https://unity3d.com/get-unity/download/archive) if you don't have it already. 
It's recommended to use Unity Hub to make managing versions easier.

**MAKE SURE TO ADD ANDROID BUILD SUPPORT TO YOUR UNITY 2022.3.2f1 INSTALLATION!** This is needed to make sure your 
bundles properly support the Quest. Instructions can be found here: 
https://docs.unity3d.com/Manual/android-sdksetup.html

## Creating a map
For the most part, creating a map itself is the same as creating anything in Unity. However, there are a few specific 
things that you'll need to do to ensure that Gorilla Tag can load it correctly.

To load up the Unity project, go ahead and open up Unity or Unity Hub (Hub is recommended) and then click Open/Add and 
navigate to the downloaded + unzipped project. Navigate to the folder that contains the `Assets`, `Packages`, and 
`ProjectSettings` folders, then click `Select Folder`.

If Unity doesn't load the Example Map upon opening you can open it by navigating to `Assets/Scenes/ExampleMap.unity`.
You can use this map as a reference for all the available functionality and how to properly setup a Map.

When creating a new map, you should first create a new Scene and load it up. Then create an empty GameObject that will 
hold everything in your map. Make sure the position is (0, 0, 0), and the scale is (1, 1, 1).

Next, click Add Component and add a Map Descriptor. This will hold some information about your map.

![mapdescriptor](https://github.com/user-attachments/assets/78bed4ad-5042-4a26-a2b8-ac094ad3664c)

Here's what each setting does:
- `Map name` - This will be used for your exported scene and the .zip file created by the export process.
- `Custom Skybox` - A cubemap that will be used as the skybox on your map. If this empty, it'll automatically give your
  map the default game skybox
- `Export Lighting` - How to handle exporting lighting data for your map. Please read the [Lighting Section](#lighting) for
  more information.

## Accessing Your Map
In order for Players to be able to access your map, it's required to include an `AccessDoorPlaceholder`.  

Under MapPrefabs, there's an `AccessDoorPlaceholder` prefab. Drag it into your scene and place it wherever you'd like. 
This represents the `Lobby` room that Players will use to pick which map to load. The door should be able to open 
directly into the map. Ensure the Placeholder doesn't overlap with any other meshes or collision or it could cause issues
for Players trying to load into your map. 

Players should always be able to return to the "Lobby" room at any point to facilitate leaving your map. Don't put it 
somewhere difficult to reach.

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
- Objects that should not have shadows

### Lighting Meshes
When you're initially importing a mesh, go to the properties and make sure that the `Generate Lightmap UVs` box is checked.

Go through all of your imported meshes now and make sure it's enabled for **all of them!** (unless you know what you're 
doing and have applied Lightmap UVs in an external program)

Next, go to each object with a `Mesh Renderer` in the scene, and ensure that `Contribute Global Illumination` is enabled. 
If you want to disable an object Receiving/Casting shadows, mess with the `Cast Shadows` and `Receive Shadows` 
properties - otherwise, leave them as the default values.

### Lights
The Example Map includes a `Directional Light` by default. Don't remove this unless you know what you're doing, as it 
(pretty accurately) recreates the base game lighting.

You can add any other sort of `Light` to your map that you want, but ensure that the type is set to `Baked`.

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

## Trigger Scripts/Prefabs
The following scripts can be used for multiple purposes, but the GameObject they are attached to will always need a Collider 
component with `Is Trigger` set to true. All trigger scripts have several common options: 
- `Synced To All Players` - Should this Trigger sync to all players, or only be processed for the person who triggered it?
    - Generally this will sync the Trigger Activation event as well as its current `Trigger Count` (used to check against
    `Num Allowed Triggers`).
- `Triggered By` - Defines which parts of the player will trigger this Trigger.
    - Options include Hands, Body, Head, BodyOrHead. Due to how Hand and Body/Head colliders work in GorillaTag, a single Trigger is
    unable to check for both at the same time.
- `General Retrigger Delay` - After being triggered, how long before this Trigger can be triggered again?
- `Num Allowed Triggers` - How many times is this Trigger allowed to trigger? 0 means infinite
- `Retrigger After Duration` - Should this Trigger re-trigger if a player stays inside it for long enough?
- `Retrigger Stay Duration` - How long does a player need to stay inside the Trigger before it re-triggers?
    - NOTE: If `General Retrigger Delay` is larger, that value will be used for this instead.

### Map Boundary
This trigger script will teleport the player to a random (or specific) Transform and optionally can Tag the player when 
triggered. It can be used in multiple ways, but the main intent was for it to be used as a way to prevent players from 
escaping your map. This script is included in the `MapBoundary` prefab in the `Assets/MapPrefabs/` folder which uses a 
Box Collider and includes a visual preview.

**Additonal Options**
- `Teleport Points` - One or more points the player will be teleported to when activating this trigger. If more than one
  point is defined, it will be chosen at random.
- `Should Tag Player` - Should the player be tagged when activating this trigger?
 
### Teleporter
This trigger script will teleport the player to a random (or specific) Transform. This script is included in the `Teleporter` 
prefab in the `Assets/MapPrefabs/` folder which uses a Box Collider and includes a visual preview.

**Additonal Options**
- `Teleport Points` - One or more points the player will be teleported to when activating this trigger. If more than one
  point is defined, it will be chosen at random.

### Tag Zone
This trigger script will Tag any activating player. This script is included in the `TagZone` prefab in the `Assets/MapPrefabs/` 
folder which uses a Box Collider and includes a visual preview.

### Object Activation Trigger
This trigger script can be used to Activate and Deactivate other GameObjects in your map and Reset other Triggers. This script is 
included in the `ObjectActivationTrigger` prefab in the `Assets/MapPrefabs` folder which uses a Box Collider and includes a visual preview.

**Additional Options**
- `Objects To Deactivate` - List of GameObjects that will be Deactivated when this Trigger is triggered. This list is processed prior
  to `Objects To Activate`.
- `Objects To Activate` - List of GameObjects that will be Activated when this Trigger is triggered. This list is processed after
  `Objects To Deactivate`.
- `Triggers To Reset` - List of Triggers that will be Reset when this Trigger is triggered
   - Reseting a trigger means its current `Trigger Count` and `Last Trigger Time` will be reset. GameObjects in the activate/deactivate
     lists are not affected by this. 

## Placeholder Script and Prefabs
The `Placeholder` script defines an object that will get replaced by an existing Gorilla Tag script/object when your map is loaded 
in-game. Each has a prefab in the `Assets/MapPrefabs/` folder that can or should be used depending on the placeholder selected for 
the `Placeholder Object` setting.

### Force Volume 
This is used in Gorilla Tag for things like the elevator to Sky Jungle and the invisible wind barriers preventing players from 
falling out of the that map. The `ForceVolumePlaceholder` prefab has the `Placeholder` script setup to use the `Force Volume` option 
and includes some default settings (each of which has a tooltip when hovered that provides more info). The prefab includes a visual 
preview and can be scaled as desired. 

### Leaf Glider 
The `LeafGliderPlaceholder` prefab has the `Placeholder` script setup to use the `Leaf Glider` option and includes a visual preview 
to assist with placement. It's recommended to **ONLY** use this prefab when using the `Leaf Glider` option on the `Placeholder` 
script. Scaling the placeholder will not affect the leaf glider that it get's replaced with.

### Glider Wind Volume 
This is used in Gorilla Tag in Sky Jungle to send the Leaf Gliders into the air. The `GliderWindVolumePlaceholder` prefab has the 
`Placeholder` script setup to use the `Glider Wind Volume` option and includes some default settings. It also includes a visual 
preview, but if you change the `Local Wind Direction` setting the arrows in the preview will not be pointed the correct way. This 
prefab/placeholder can be scaled as desired. 

### Water Volume
The `WaterVolumePlaceholder` prefab has the `Placeholder` script setup to use the `Water Volume` option with some default settings. It includes a visual preview and can be scaled as desired.

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

### Access Door Placeholder
This is used for positioning your map in the correct place so it lines up with the "Lobby" room in GorillaTag. This script
is already part of the `AccessDoorPlaceholder` prefab in MapPrefabs, so it's not necessary to manually add this to anything.
There should only be one `AccessDoorPlaceholder` script component in your map, if you place multiple, only one will be valid.

### Destroy Pre Export
This is used to destroy in-editor visualization helpers and other editor-only objects to ensure they don't end up in your 
exported map. You can attach this script to any GameObject that should **NOT** be included in your exported map.

### Teleport Point (Prefab)
This is a simple prefab that is essentially just a visual preview to show where you've placed them in your map. Can be used with the 
`MapBoundary` and `Teleporter` scripts to define teleport destinations.

## Loading Zones

If you want to break up your map into multiple scenes, you can use the `ZoneLaodTigger` prefab to load and unload those scenes.

### Multi Map Setup
ALL scenes you want included in your map need to be added to the `Scenes In Build` section of the `Build Settings` window.
To make sure all your scenes line up correctly with each other, open your main scene and then select the other scenes from the `Project`
window and drag them into the `Hierarchy` window. The scenes should appear in the `Scene` view and you can edit them as needed.
Add the `ZoneLoadTrigger` prefab where you a scene load/unload to occur. Make sure the prefab is in the correct scene.

### Zone Load Trigger
This is the prefab used to determine where scenes are loaded and/or unloaded. It contains the `LoadZoneSettings` script, a `Box Collider`, and
a preview mesh to help with sizing and placement.
All scenes added to the `Scenes In Build` section of the `Build Settings` window will be listed under the `Load Zone Settings` script in two sections:
`Scenes to Load` and `Scenes to Unload`
You can also set how the load zone is triggered with the `Triggered By` setting.

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
- Did you add the `AccessDoorPlaceholder` prefab to your map?
    - It's required to have an `AccessDoorPlaceholder` in your map, or you won't be able to export.
    - Brush back over the tips in the [Accessing Your Map section](#accessing-your-map) if needed
- Did you read over the [Lighting section](#lighting) and follow all the steps?
- Did you add all the scenes you want exported to the `Scenes In Build` section of the `Build Settings` window?

If you want to use a custom skybox, import it into your Unity project as an image, set the `Texture Shape` to Cube 
and assign it to the `Custom Skybox` property on your `Map Descriptor`

Now that you've gone over the checklist, it's time to export! Make sure all the scenes you want have been added to the `Build settings`
window then in the toolbar got to `Tools > Export Maps`

This opens up to the `Exports` folder, but you can select any folder to export to. Click save, and once the export is 
finished you'll have a `.zip` file that's ready to upload to [Mod.io](https://mod.io/g)

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
