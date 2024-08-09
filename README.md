# GT_CustomMapExample
A Unity project to facilitate the creation of custom maps for Gorilla Tag. 

**Contents**

* [Setup](#setup)
* [Creating a map](#creating-a-map)
* [Accessing Your Map](#accessing-your-map)
* [Matching Gorilla Tag's Style](#matching-gorilla-tags-style)
* [Lighting](#lighting)
    + [Lighting Setup](#lighting-setup)
    + [Lighting Meshes](#lighting-meshes)
    + [Lights](#lights)
    + [Other Tips](#other-tips)
* [Other Scripts](#other-scripts)
    + [Surface Override Settings](#surface-override-settings)
    + [Access Door Placeholder](#access-door-placeholder)
    + [Destroy Pre Export](#destroy-pre-export)
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

**NOTE: Quest Support for custom maps is still WIP, but the exporter does build Android AssetBundles.**

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

![mapdescriptor](https://github.com/user-attachments/assets/6d642350-7aac-4c8b-8fb5-0d7fb6d4e2dd)

Here's what each setting does:
- Map name
    - This will be used for your
- Custom Skybox
    - A cubemap that will be used as the skybox on your map
    - If this empty, it'll automatically give your map the default game's skybox
- Export Lighting
    - Whether or not to generate lightmaps for your map
    - Please read the [Lighting Section](#lighting) for more information.

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
    - For example, N64 maps, minecraft maps, etc
- Maps where shadows aren't important
- Maps that really need to save filesize

If your map falls under the "SHOULDN'T USE LIGHTING" category, you can set your map's `Export Lighting` value to false 
and ignore the rest of this section.

Otherwise, follow these steps to getting lighting looking nice on your map:

### Lighting Setup
Make sure to set your map's `Export Lighting` value to true.

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

## Other Scripts

### Surface Override Settings
If you want to modify how climbing works on an object, you can add a `Surface Override Settings` script to it.

**Script Options:**
- Sound Override
    - Used to customize what sound plays when a Player hits the object.
- Extra Vel Multiplier
  - A number that influences how much extra velocity is gained when a player jumps off the object. 
  (Must be higher than 1)
- Extra Vel Max Multiplier
  - A number that defines the maximum extra velocity multiplier applied when a player jumps off the object. 
  (Must be higher than 1)
- Slide Percentage
    - A number that decides how "slippery" an object is when used for climbing.
    - Default value is 0.0 which is the least slippery an object can be. Higher values are more slippery with a maximum 
  of 1.0 meaning the object is unclimbable.

### Access Door Placeholder
This is used for positioning your map in the correct place so it lines up with the "Lobby" room in GorillaTag. This script
is already part of the `AccessDoorPlaceholder` prefab in MapPrefabs, so it's not necessary to manually add this to anything.
There should only be one `AccessDoorPlaceholder` script component in your map, if you place multiple, only one will be valid.

### Destroy Pre Export
This is used to destroy in-editor visualization helpers and other editor-only objects to ensure they don't end up in your 
exported map. You can attach this script to any GameObject that should **NOT** be included in your exported map.

### More Coming Soon!


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

If you want to use a custom skybox, import it into your Unity project as an image, set the `Texture Shape` to Cube 
and assign it to the `Custom Skybox` property on your `Map Descriptor`

Now that you've gone over the checklist, it's time to export! Select the GameObject with your `MapDescriptor` component,
and click the `Export Map` button. 

This opens up to the `Exports` folder, but you can select any folder to export to. Click save, and once the export is 
finished you'll have a `.zip` file that's ready to upload to [Mod.io](https://mod.io/g)

### Uploading to Mod.io

After you've exported your map and have a `.zip` file ready, you can now upload your map to [Mod.io](https://mod.io/g). 
Go to [https://mod.io/g/gorilla-tag](https://mod.io/g/gorilla-tag) and create an account if you haven't already. 
Once you're logged in, click the `Add Level` button on the top right. 

![addLevelbutton](https://github.com/user-attachments/assets/4132aec2-c760-4a1e-be1c-3dd6b4074a8a)

On the following page you'll need to fill out some info about your map. 
The required fields are:
- Name - *try to make this unique to your map*
- Summary - *a brief summary of your map (minimum of 10 characters)*
- Logo - *this is the main image shown when players are browsing available maps*

The other fields are all optional, but be sure to fill out any information you'd like to. 

![requiredfields](https://github.com/user-attachments/assets/1d663db1-2bdf-4878-8c6b-4193a7ebc356)

Once your done filling out basic information, click the `Create Level` button at the bottom of the page.
On the next page are more optional fields. You can upload more screenshots of your map, link to a Youtube channel, or add links to Sketchfab models.
Once you're done on that page click the `Save & next` button at the bottom of the page.

![media](https://github.com/user-attachments/assets/310fb041-84d3-4272-a4eb-c667ed519c85)

The next page is where you will upload your `.zip` file you exported from Unity. Click the `Select zip file` button and find the `.zip` file you exported. 
You can also add a Version number and Changelog with this file and each additionl file you upload. Once you've selected your `.zip` file and filled out any desired fields, 
make sure you read and agree to the mod.io Terms and Conditions and check the `I agree` box, then click the `Upload & next` button to continue.

![selectfile](https://github.com/user-attachments/assets/c5efdeda-1731-4fa5-910e-b982e240d45f)

The next page is for selecting any dependencies. This is currently unsupported for Gorilla Tag so you can just click the `Save & next` button at the bottom of the page to continue.
You'll then be taken to the overview page for your map. At the top of this page are 2 important things to be aware of: Level Status and Level Visibility. 

- Level Status refers to the approval status of your map. All maps must be verified and approved by a Gorilla Tag moderator before they will be available to players in-game or on the mod.io website.
  This is an automated process and the moderator team will be notified whenever a map needs approval.
- Level Visibility refers to the public visibility of your map. If it's hidden it will only be available to pre-existing subscribers and anyone added to the map's Team.

Your map must be approved and visible to the public for players to be able to see and download it in-game. 

![status](https://github.com/user-attachments/assets/e9cf21c0-9654-4aa1-81a8-0d3acf403c87)

If you'd like to see what other players see when browsing mod.io, you can click the `View Level` button on the top-right of this page.
You can also subscribe to your map on this page, just make sure to link your Steam/Oculus Mod.io account to your email-based one or subscriptions on the website won't propagate. 

![subscribe](https://github.com/user-attachments/assets/4d89d3b3-3985-488d-b6d4-4f8f7b3f506f)

## Playing Your Map
*Coming Soon*

If your map doesn't look quite right in-game, read back over the [Lighting section](#lighting)
