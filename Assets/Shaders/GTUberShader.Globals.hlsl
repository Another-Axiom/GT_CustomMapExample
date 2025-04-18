#ifndef GT_UBER_GLOBALS_INCLUDE
#define GT_UBER_GLOBALS_INCLUDE

_DECLARE_TEX2D(_GT_BlueNoiseTex)
float4 _GT_BlueNoiseTex_WH;

float  _GT_Time;
float  _GT_iFrame;
float3 _GT_WorldSpaceCameraPos;

#define MAX_PAWNS 10
float4x4 _GT_PawnData[MAX_PAWNS];
int _GT_PawnActiveCount;

int _GT_ShaderVolumesActive;
float4x4 _GT_ShaderVolumes[16];

int _GreyZoneActive;

SCREENSPACE_TEXTURE_HALF(_CameraOpaqueTexture);
SAMPLER(sampler_CameraOpaqueTexture);
#define _SAMPLE_CAMERA_TEX(screen_uvs) SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screen_uvs)

// Color blindness matrices referenced from:
// "A Physiologically-based Model for Simulation of Color Vision Deficiency"
// https://www.inf.ufrgs.br/~oliveira/pubs_files/CVD_Simulation/CVD_Simulation.html

static const float3x3 _GT_CG_Protanomaly = 
{
     0.458064,	 0.679578,	-0.137642,
     0.092785,	 0.846313,	0.060902,
    -0.007494,	-0.016807,	1.024301,
};

static const float3x3 _GT_CG_Protanopia =
{
     0.152286,  1.052583, -0.204868,
     0.114503,  0.786281,  0.099216,
    -0.003882, -0.048116,  1.051998
};

static const float3x3 _GT_CG_Deuteranomaly = 
{
     0.547494, 0.607765, -0.155259,
     0.181692, 0.781742,  0.036566,
    -0.010410, 0.027275,  0.983136
};

static const float3x3 _GT_CG_Deuteranopia =
{
     0.367322, 0.860646, -0.227968,
     0.280085, 0.672501,  0.047413,
    -0.011820, 0.042940,  0.968881
};

static const float3x3 _GT_CG_Tritanomaly =
{
     1.193214,	-0.109812,	-0.083402,
    -0.058496,	 0.979410,	 0.079086,
    -0.002346,	 0.403492,	 0.598854
};

static const float3x3 _GT_CG_Tritanopia =
{
    1.255528, -0.076749, -0.178779,
   -0.078411,  0.930809,  0.147602,
    0.004733,  0.691367,  0.303900
};

static const float3x3 _GT_CG_Achromatomaly = 
{
    0.618, 0.320, 0.062,
    0.163, 0.775, 0.062,
    0.163, 0.320, 0.516
};

static const float3x3 _GT_CG_Achromatopsia = 
{	
    0.2126, 0.7152, 0.0722,
    0.2126, 0.7152, 0.0722,
    0.2126, 0.7152, 0.0722
};

#endif // GT_UBER_GLOBALS_INCLUDE