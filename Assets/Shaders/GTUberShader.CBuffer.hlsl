#ifndef GT_UBER_CBUFFER_INCLUDE
#define GT_UBER_CBUFFER_INCLUDE

// We won't use all these properties in this pass, but every pass needs the same CBUFFER(UnityPerMaterial)
// for SRP batcher to work

half4 _GChannelColor;
half4 _BChannelColor;
half4 _AChannelColor;

half _TexMipBias;

float4 _BaseMap_ST;
float4 _BaseMap_WH; // _TexelSize alias, populate with [TexelSizeFor(..)] property attribute; Unity sets built-in _TexelSize incorrectly on Quest
int _BaseMap_AtlasSlice;
half4 _BaseColor;

float4 _MaskMap_WH;
float4 _MaskMap_ST;

int _TexelSnap_Factor;

float3 _SpecularDir;
half4 _SpecularColor;
float2 _SpecularPowerIntensity;
int _SpecularUseDiffuseColor;

half4 _AlphaDetail_ST;
half _AlphaDetail_Opacity;
float _AlphaDetail_WorldSpace;

int _WeatherMap_AtlasSlice;
half _WeatherMapDissolveEdgeSize;

half4 _EmissionColor;
int _EmissionMap_AtlasSlice;
half _EmissionMaskByBaseMapAlpha;
float3 _EmissionUVScrollSpeed;
half _EmissionDissolveProgress;
float3 _EmissionDissolveAnimation;
half _EmissionDissolveEdgeSize;

float4 _InnerGlowParams; // xyz = position, w = radius.w
float3 _InnerGlowColor;
int _InnerGlowSine;
int _InnerGlowTap;
float _InnerGlowSinePeriod;
float _InnerGlowSinePhaseShift;

half _Cutoff;

half4 _SpecColor;
half _Smoothness;
half _Metallic;
half _Surface;

half _RotateAngle;
half _RotateAnim;

half _CrystalPower;
half4 _CrystalRimColor;

half4 _ReflectTint;
half4 _ReflectOffset;
half4 _ReflectScale;
half _ReflectRotate;
half _ReflectExposure;
half _ReflectOpacity;
half3 _ReflectBoxCubePos;
half3 _ReflectBoxSize;
half3 _ReflectBoxRotation;

int2 _UvShiftSteps;
int2 _UvShiftOffset;
half2 _UvShiftRate;

half _WaveScale, _WaveAmplitude, _WaveFrequency;

half _LiquidFill, _LiquidSwayX, _LiquidSwayY;
half4 _LiquidFillNormal;
half4 _LiquidSurfaceColor;
half4 _LiquidPlaneNormal, _LiquidPlanePosition;

int _DeformMap_AtlasSlice;
float _DeformMapIntensity;
float _DeformMapMaskByVertColorRAmount;
float2 _DeformMapScrollSpeed;
float2 _DeformMapUV0Influence;
float3 _DeformMapObjectSpaceOffsetsU;
float3 _DeformMapObjectSpaceOffsetsV;
float3 _DeformMapWorldSpaceOffsetsU;
float3 _DeformMapWorldSpaceOffsetsV;
float4 _RotateOnYAxisBySinTime;

float3 _VertexFlapAxis;
float2 _VertexFlapDegreesMinMax;
float _VertexFlapSpeed;
float _VertexFlapPhaseOffset;

float4 _VertexWaveParams; // x = Speed, y = Yaw, z = Roll, w = Scale
float4 _VertexWaveFalloff;
float _VertexWavePhaseOffset;
float4 _VertexWaveEnd;
float4 _VertexWaveSphereMask;
int2 _VertexWaveAxes;

float4 _VertexRotateAngles;

half _ParallaxAmplitude;
int _ParallaxAABias;
half2 _ParallaxSamplesMinMax;

int _GreyZoneException;

half4 _Color;

int _DayNightLightmapArray_AtlasSlice;

float4 _EyeTileOffsetUV;
float _EyeOverrideUV;
float4 _EyeOverrideUVTransform;

int _MouthMap_AtlasSlice;
float4 MouthTexture_ST;
float4 _MouthMap_ST;

int _ZFightOffset;

#endif // GT_UBER_CBUFFER_INCLUDE