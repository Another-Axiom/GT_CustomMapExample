/* ==================================================================================================================
 * 
 * Global shader properties that are intended to be used and controlled by game modes.
 * 
 * ================================================================================================================== */


#ifndef GT_UBER_GLOBALS_GAMEMODES_INCLUDE
#define GT_UBER_GLOBALS_GAMEMODES_INCLUDE


// ---- Playable Boundaries ----
//
// (2025-04-21 MattO) Used by: PropHaunt.
//

// Either on or off.
// TODO: (2025-04-21 MattO) Should probably be a multi-compiled shader feature.
int _GTGameModes_PlayableBoundary_IsEnabled = 0;

// Axis aligned cylinders which can be repositioned.
// TODO: (2025-04-21 MattO) Height not defined, should pack/unpack radius and height together.
half3 _GTGameModes_PlayableBoundary_Cylinders_Centers[8];
half2 _GTGameModes_PlayableBoundary_Cylinders_RadiusHeights[8];

// Controls how much the signed distance field blends the shapes together.
float _GTGameModes_PlayableBoundary_NonZeroSmoothRadius = 16.0;


// ---- Grey Zones ----
//
// (2025-04-21 MattO) Not tied to a specific game mode as of writing this comment but instead was part of the 2024
// Halloween update. It would likely make sense for this to be part of specific game modes in the future though.
//

int _GreyZoneActive;


#endif // GT_UBER_GLOBALS_GAMEMODES_INCLUDE
