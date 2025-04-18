#if (_USE_TEXTURE || USE_TEXTURE__AS_MASK)
#define USE_BASE_MAP 1
#endif

// Always using world position because it is needed for per-fragment fog. It might make sense to make it a
// multicompile keyword though, so leaving preprocessor logic for now. --MattO
//
// #if ( _GT_RIM_LIGHT  || _WATER_EFFECT || _UV_SOURCE__WORLD_PLANAR_Y || _GLOBAL_ZONE_LIQUID_TYPE__LAVA || _LIQUID_CONTAINER)
#define FRAG_NEEDS_POSITION_INPUTS 1
// #else
//     #define FRAG_NEEDS_POSITION_INPUTS 0
// #endif


#pragma target 3.5

#pragma vertex vert
#pragma fragment frag

// Default is none.
#pragma multi_compile \
    _ \
    _GLOBAL_ZONE_LIQUID_TYPE__WATER \
    _GLOBAL_ZONE_LIQUID_TYPE__LAVA

// Default is plane.
#pragma multi_compile \
    _ \
    _ZONE_LIQUID_SHAPE__CYLINDER

// TODO: Rename to `_BASE_MAP__ON`, and `_BASE_MAP__AS_MASK`
#pragma shader_feature \
    _ \
    _USE_TEXTURE \
    USE_TEXTURE__AS_MASK

#pragma shader_feature \
    _UV_SOURCE__UV0 \
    _UV_SOURCE__WORLD_PLANAR_Y

#pragma shader_feature _USE_VERTEX_COLOR
#pragma shader_feature _USE_WEATHER_MAP
#pragma shader_feature _ALPHA_DETAIL_MAP
#pragma shader_feature _HALF_LAMBERT_TERM
#pragma shader_feature _WATER_EFFECT
#pragma shader_feature _HEIGHT_BASED_WATER_EFFECT
#pragma shader_feature _WATER_CAUSTICS
#pragma shader_feature _ALPHATEST_ON
#pragma shader_feature _MAINTEX_ROTATE
#pragma shader_feature _UV_WAVE_WARP

#pragma shader_feature _LIQUID_VOLUME // Alternate liquids implementation 
#pragma shader_feature _LIQUID_CONTAINER // Original GTag liquids port

#pragma shader_feature _GT_RIM_LIGHT //Add custom rim lighting to simulate BiRP lighting
#pragma shader_feature _GT_RIM_LIGHT_FLAT
#pragma shader_feature _GT_RIM_LIGHT_USE_ALPHA

#pragma shader_feature _SPECULAR_HIGHLIGHT

#pragma shader_feature _EMISSION
#pragma shader_feature _EMISSION_USE_UV_WAVE_WARP

#pragma shader_feature _USE_DEFORM_MAP

#pragma shader_feature _USE_DAY_NIGHT_LIGHTMAP //If false, use standard Unity lightmap
#pragma shader_feature _USE_TEX_ARRAY_ATLAS
#pragma shader_feature _GT_BASE_MAP_ATLAS_SLICE_SOURCE__PROPERTY
#pragma shader_feature _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z

#pragma shader_feature _CRYSTAL_EFFECT

#pragma shader_feature _EYECOMP
#pragma shader_feature _MOUTHCOMP

#pragma shader_feature _ALPHA_BLUE_LIVE_ON
#pragma shader_feature _GRID_EFFECT

#pragma shader_feature _REFLECTIONS
#pragma shader_feature _REFLECTIONS_BOX_PROJECT
#pragma shader_feature _REFLECTIONS_MATCAP
#pragma shader_feature _REFLECTIONS_MATCAP_PERSP_AWARE
#pragma shader_feature _REFLECTIONS_ALBEDO_TINT
#pragma shader_feature _REFLECTIONS_USE_NORMAL_TEX

#pragma shader_feature _VERTEX_ROTATE

#pragma shader_feature _VERTEX_ANIM_FLAP
#pragma shader_feature _VERTEX_ANIM_WAVE
#pragma shader_feature _VERTEX_ANIM_WAVE_DEBUG

// #pragma shader_feature _VERTEX_LIGHTING

#pragma shader_feature _GRADIENT_MAP_ON

#pragma shader_feature _PARALLAX
#pragma shader_feature _PARALLAX_AA
#pragma shader_feature _PARALLAX_PLANAR

#pragma shader_feature _MASK_MAP_ON
#pragma shader_feature _FX_LAVA_LAMP

#pragma shader_feature _INNER_GLOW
#pragma shader_feature _STEALTH_EFFECT

#pragma shader_feature _UV_SHIFT
#pragma shader_feature _TEXEL_SNAP_UVS

#pragma shader_feature _UNITY_EDIT_MODE
#pragma shader_feature _GT_EDITOR_TIME

#pragma shader_feature _DEBUG_PAWN_DATA

#pragma shader_feature _COLOR_GRADE_PROTANOMALY
#pragma shader_feature _COLOR_GRADE_PROTANOPIA
#pragma shader_feature _COLOR_GRADE_DEUTERANOMALY
#pragma shader_feature _COLOR_GRADE_DEUTERANOPIA
#pragma shader_feature _COLOR_GRADE_TRITANOMALY
#pragma shader_feature _COLOR_GRADE_TRITANOPIA
#pragma shader_feature _COLOR_GRADE_ACHROMATOMALY
#pragma shader_feature _COLOR_GRADE_ACHROMATOPSIA

// Unity automatically sets these keywords for us
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED // we're using the directional lightmap to store the lightmap we're blending to
#pragma shader_feature _ UNITY_LIGHTMAP_RGBM_ENCODING UNITY_LIGHTMAP_DLDR_ENCODING

#pragma multi_compile_instancing

// Some defines for JetBrains Rider syntax highlighting.
#if __RESHARPER__
    #define LIGHTMAP_ON 1
    #define _USE_DAY_NIGHT_LIGHTMAP 1
    #define _USE_TEXTURE 1
    #define USE_TEXTURE__AS_MASK 0
    #define _UV_WAVE_WARP 0
    #define _USE_WEATHER_MAP 1
    #define _EMISSION 1
    // #define _EMISSION_USE_FLOW_MAP 1
    #define _EMISSION_USE_UV_WAVE_WARP 1
    #define _GT_RIM_LIGHT 1
    #define _WATER_EFFECT 1
    #define _WATER_CAUSTICS 1
    #define _HEIGHT_BASED_WATER_EFFECT 1
    #define _ZONE_LIQUID_SHAPE__CYLINDER 1
    // #define _UV_SOURCE__WORLD_PLANAR_Y 1
    #define _GLOBAL_ZONE_LIQUID_TYPE__LAVA 0
    #define _USE_TEX_ARRAY_ATLAS 1
    #define _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z 1
    #define _LIQUID_CONTAINER 1
    #define _USE_DEFORM_MAP 1
    #define _USE_DAY_NIGHT_LIGHTMAP 1
    #define DIRLIGHTMAP_COMBINED 1
    #define _UNITY_EDIT_MODE 0
    #define _EYECOMP 1
#endif

#include "GTUberShader.Common.hlsl"

DECLARE_ATLASABLE_TEX2D(_BaseMap);
DECLARE_ATLASABLE_SAMPLER(sampler_BaseMap);

#if _MASK_MAP_ON
    TEXTURE2D(_MaskMap);
    SAMPLER(sampler_MaskMap);
#endif

#if _GRADIENT_MAP_ON
    TEXTURE2D(_GradientMap);
    SAMPLER(sampler_GradientMap);
#endif

#if _USE_WEATHER_MAP
    DECLARE_ATLASABLE_TEX2D(_WeatherMap);
    DECLARE_ATLASABLE_SAMPLER(sampler_WeatherMap);
#endif

#if _EMISSION || _CRYSTAL_EFFECT
    DECLARE_ATLASABLE_TEX2D(_EmissionMap);
    DECLARE_ATLASABLE_SAMPLER(sampler_EmissionMap);
#endif

#if _USE_DEFORM_MAP
    DECLARE_ATLASABLE_TEX2D(_DeformMap);
    // DECLARE_ATLASABLE_SAMPLER(sampler_DeformMap);
    // #ifndef NEED_LINEAR_SAMPLER
    //     #define NEED_LINEAR_SAMPLER 1
    // #endif
#endif

#define _NEED_WORLD_UV (_ALPHA_DETAIL_MAP && (_USE_TEXTURE || USE_TEXTURE__AS_MASK))
#define _NEED_POSITION_VS (_WATER_EFFECT || _STEALTH_EFFECT || _ALPHA_BLUE_LIVE_ON)
#define _NEED_POSITION_0S (_LIQUID_VOLUME || _INNER_GLOW || _VERTEX_ANIM_WAVE_DEBUG)
#define _NEED_VIEW_DIR_WS (_WATER_EFFECT || _STEALTH_EFFECT)


#if _REFLECTIONS
    TEXTURE2D(_ReflectTex);
    SAMPLER(sampler_ReflectTex);

    #if _REFLECTIONS_USE_NORMAL_TEX
        TEXTURE2D(_ReflectNormalTex);
        SAMPLER(sampler_ReflectNormalTex);
    #endif

#endif

#if _PARALLAX
    TEXTURE2D(_DepthMap);
    SAMPLER(sampler_DepthMap);
#endif

// #if NEED_LINEAR_SAMPLER
//     SAMPLER(sampler_linear_repeat);
// #endif


// Global Properties
#if (LIGHTMAP_ON && _USE_DAY_NIGHT_LIGHTMAP)
    float _GlobalDayNightLerpValue;
#endif

#if (LIGHTMAP_ON && DIRLIGHTMAP_COMBINED)
    SAMPLER(samplerunity_LightmapInd);
 #endif

#if _USE_WEATHER_MAP
    half _ZoneWeatherMapDissolveProgress;
#endif

// Zone Fog
float _ZoneGroundFogHeight;
float _ZoneGroundFogHeightFade;
float _ZoneGroundFogDepthFadeSq;
half4 _ZoneGroundFogColor;


#if _WATER_EFFECT
    //TODO: rename _Global vars to _Zone to indicate they are controlled per zone.
    float4 _GlobalMainWaterSurfacePlane;
    half4 _GlobalWaterTintColor;
    half4 _GlobalUnderwaterFogColor;
    float2 _GlobalUnderwaterFogParams;
    float2 _GlobalUnderwaterEffectsDistanceToSurfaceFade;
    half4 _ZoneLiquidLightColor;
    half _ZoneLiquidLightAttenuation;

    #if _WATER_CAUSTICS || _GLOBAL_ZONE_LIQUID_TYPE__LAVA
        float _GlobalZoneLiquidUVScale;
        float2 _GlobalUnderwaterCausticsParams;
        TEXTURE2D(_GlobalUnderwaterCausticsTex);
        SAMPLER(sampler_GlobalUnderwaterCausticsTex);
        TEXTURE2D(_GlobalLiquidResidueTex);
        SAMPLER(sampler_GlobalLiquidResidueTex);
    #endif // _WATER_CAUSTICS || _GLOBAL_ZONE_LIQUID_TYPE__LAVA

    #if _HEIGHT_BASED_WATER_EFFECT && _ZONE_LIQUID_SHAPE__CYLINDER
        float4 _ZoneLiquidPosRadiusSq;
    #endif // _ZONE_LIQUID_SHAPE__CYLINDER
#endif // _WATER_EFFECT

#if _EYECOMP
    float2 eyeTile;
    float2 eyeOffset;
    float4 EyeTexture_ST;
    float overrideUV;
    float4 overrideUVTransform;
#endif

#if _MOUTHCOMP
    TEXTURE2D(_MouthMap);
    SAMPLER(sampler_MouthMap);
#endif

// Vertex Inputs
struct Attributes
{
    float3 positionOS : POSITION;

    #if (_USE_TEXTURE || USE_TEXTURE__AS_MASK || _USE_WEATHER_MAP || _EMISSION || _USE_DEFORM_MAP || _REFLECTIONS)
        #if _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z
            float4 uv : TEXCOORD0;
        #else // not _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z
            float2 uv : TEXCOORD0;
        #endif // not _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z
    #endif // (_USE_TEXTURE || USE_TEXTURE__AS_MASK || _USE_WEATHER_MAP || _EMISSION || _USE_DEFORM_MAP || _REFLECTIONS)

    #if (_USE_VERTEX_COLOR || _USE_DEFORM_MAP || _VERTEX_ANIM_FLAP || _VERTEX_ANIM_WAVE)
        half4 vertexColor : COLOR;
    #endif

    #if LIGHTMAP_ON
        float2 lightmapUV : TEXCOORD1;
    #endif

    #if FRAG_NEEDS_POSITION_INPUTS || _PARALLAX || _PARALLAX_PLANAR
        float3 normalOS : NORMAL;
    #endif

    // #if _PARALLAX || _PARALLAX_PLANAR
        float4 tangent : TANGENT;
    // #endif
    
    #if _MOUTHCOMP
        float2 mouthUV : TEXCOORD2;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};


// Fragment Inputs
struct Varyings
{
    float4 positionCS : SV_POSITION;
#if _NEED_POSITION_VS
    float4 positionVS : TEXCOORD12;
#endif

#if _NEED_VIEW_DIR_WS
    float3 viewDirWS : TEXCOORD16;
#endif

    #if (_USE_TEXTURE || USE_TEXTURE__AS_MASK || _EMISSION || _REFLECTIONS)
        float2 uv : TEXCOORD0;

        #if _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z
            uint baseMapSlice : TEXCOORD17;
        #endif // _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z
    #endif

    #if _NEED_WORLD_UV
        float2 worldUV : TEXCOORD13;
    #endif
    
    #if _INNER_GLOW
        float4 glowMask : TEXCOORD14;
    #endif

    // #if _VERTEX_LIGHTING
    //     float3 lightMask : TEXCOORD23;
    // #endif

    #if (_USE_VERTEX_COLOR || _VERTEX_ANIM_FLAP || _VERTEX_ANIM_WAVE)
        half4 vertexColor : COLOR;
    #endif

    #if LIGHTMAP_ON
        float2 lightmapUV : TEXCOORD1;
    #endif

    #if FRAG_NEEDS_POSITION_INPUTS || _PARALLAX || _PARALLAX_PLANAR
        float3 normalWS : NORMAL;
        float3 positionWS : TEXCOORD3;
    #endif
    
    #if _NEED_POSITION_0S
            float3 positionOS : TEXCOORD26;
    #endif
    
    #if _PARALLAX || _PARALLAX_PLANAR
        float4 tSpace0 : TEXCOORD9;
        float4 tSpace1 : TEXCOORD10;
        float4 tSpace2 : TEXCOORD11;
    #endif

    #if _WATER_EFFECT
        float4 causticsUVs : TEXCOORD4;
        float groundToWaterPlaneSignedDistance : TEXCOORD8;
    #endif

    #if _EMISSION || _CRYSTAL_EFFECT
        float2 emissionUV : TEXCOORD5;
    #endif

    #if _LIQUID_VOLUME
        float4 liquidEdge : TEXCOORD6;
    #endif

    #if _REFLECTIONS && _REFLECTIONS_MATCAP
        float2 matcapUV : TEXCOORD7;
    #endif

    #if _MOUTHCOMP
        float2 mouthUV : TEXCOORD2;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

// Vertex Shader
Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 posOS = input.positionOS;
    float3 normalOS = input.normalOS;

    // Optional position offset to address z-fighting
    posOS += _ZFightOffset? sign(normalOS) * abs(posOS * 0.0000002) : 0.0;
    
    #if _VERTEX_ROTATE
        float vr_anim = _VertexRotateAngles.w ? _Time.y : 1;
        float3 vr_rads = _VertexRotateAngles.xyz * PI / 180.0;
    
        posOS = RotateByEuler(posOS, vr_rads * vr_anim );
        normalOS = RotateByEuler(normalOS, vr_rads * vr_anim );
    #endif

    #if _NEED_POSITION_0S
        output.positionOS = posOS;
    #endif
    
    VertexPositionInputs positionInputs = GetVertexPositionInputs(posOS);
    float3 posWS = positionInputs.positionWS;

#if _NEED_VIEW_DIR_WS
    output.viewDirWS = GetWorldSpaceNormalizeViewDir(posWS);
#endif

#if _NEED_POSITION_VS
    // TODO: (2024-12-18 MattO) ComputeScreenPos is deprecated according to comment above the function definition:
    // // Deprecated: A confusingly named and duplicate function that scales clipspace to unity NDC range. (-w < x(-y) < w --> 0 < xy < w)
    // // Use GetVertexPositionInputs().positionNDC instead for vertex shader
    // // Or a similar function in Common.hlsl, ComputeNormalizedDeviceCoordinatesWithZ()
    output.positionVS = ComputeScreenPos(positionInputs.positionCS);
#endif
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    #if _NEED_WORLD_UV
        output.worldUV = CalcWorldSpaceUV(posWS, normalWS);
    #endif
    

    // #if _VERTEX_LIGHTING
    //     int l_count = GetAdditionalLightsCount();
    //
    //     for(int i = 0; i < l_count; ++i)
    //     {
    //         Light l = GetAdditionalLight(i, posWS);
    //         output.lightMask += l.color * l.distanceAttenuation; 
    //     }   
    // #endif
    
    // Disabled until I can figure out the sampling error --MattO
    #if _USE_DEFORM_MAP
        float2 deformMapUVs = input.uv * _DeformMapUV0Influence;
        // These offsets can be used to do world space mapping or to offset the scrolling so that things
        // like candle flames don't play too much in sync.
        deformMapUVs.x += (
            dot(posOS, _DeformMapObjectSpaceOffsetsU)
            // + dot(posWS, _DeformMapWorldSpaceOffsetsU)
        );
        deformMapUVs.y += (
            dot(posOS, _DeformMapObjectSpaceOffsetsV)
            // + dot(posWS, _DeformMapWorldSpaceOffsetsV)
        );
        float3 objWorldPivotPosition = unity_ObjectToWorld._m03_m13_m23;
        deformMapUVs.x += DistanceSq(objWorldPivotPosition);
        deformMapUVs += _DeformMapScrollSpeed * float2(_Time.y, _Time.y);

        float3 deformMapRelativePos = SAMPLE_ATLASABLE_TEX2D_LOD(_DeformMap, sampler_linear_repeat, deformMapUVs, 0.0).rgb;
        deformMapRelativePos *= _DeformMapIntensity;
        deformMapRelativePos *= lerp(1.0, input.vertexColor.r, _DeformMapMaskByVertColorRAmount);
        posOS += deformMapRelativePos;

        // Wiggle rotation.
        float sinTimeRotAngle = dot(_SinTime, _RotateOnYAxisBySinTime);
        // float sinTimeRotAngle = _RotateOnYAxisBySinTime.x;//poop
        float cosTheta = cos(sinTimeRotAngle);
        float sinTheta = sin(sinTimeRotAngle);
        posOS = float3(
            posOS.x * cosTheta - posOS.z * sinTheta,
            posOS.y,
            posOS.x * sinTheta + posOS.z * cosTheta
        );
        posOS.xz = mul(posOS.xz, float2x2( cosTheta , -sinTheta , sinTheta , cosTheta ));
        posWS = TransformObjectToWorld(posOS);
    #endif

    #if _VERTEX_ANIM_FLAP
        float vfSide = 1.;
    
        if (_VertexFlapAxis.x == 1) vfSide = sign(posOS.z);
        if (_VertexFlapAxis.y == 1) vfSide = sign(posOS.x);
        if (_VertexFlapAxis.z == 1) vfSide = sign(posOS.y);

        if(length(input.vertexColor.xyz) != 0)
        {
            float vfSin = sin(_Time.y * _VertexFlapSpeed + _VertexFlapPhaseOffset);
            float vfSinMinMax = RemapValue(vfSin, float2(-1, 1), _VertexFlapDegreesMinMax);
            
            float vfDegrees = vfSide * vfSinMinMax;
            float3 vfPosOS = RotateAboutAxis(posOS, _VertexFlapAxis, vfDegrees);
            posWS = TransformObjectToWorld(vfPosOS);   
        }
    #endif
    
    #if _VERTEX_ANIM_WAVE
        float3 vw_pos = posOS;
        float vw_time = _Time.y + _VertexWavePhaseOffset;
    
        float vw_speed = _VertexWaveParams.x;
        float vw_yaw = _VertexWaveParams.y * 100;
        float vw_roll = _VertexWaveParams.z * 100;
        float vw_scale = _VertexWaveParams.w / 100;
    
        float vw_new_pos;
        float vw_mask = VertexWaveMask(vw_pos, _VertexWaveEnd.xyz, _VertexWaveSphereMask, _VertexWaveEnd.w, vw_new_pos, _VertexWaveFalloff.z, _VertexWaveFalloff.xy);

        float vw_offset_ws = _VertexWaveFalloff.w ? length(posWS) : 0;
    
        float vw_offset_a = sin(vw_time * vw_speed + (-vw_new_pos) * vw_yaw  + vw_offset_ws) * vw_scale * vw_mask;
        float vw_offset_b = cos(vw_time * vw_speed + (-vw_new_pos) * vw_roll + vw_offset_ws) * vw_scale * vw_mask; 

        if      (_VertexWaveAxes.x == 0) vw_pos.x += vw_offset_a;
        else if (_VertexWaveAxes.x == 1) vw_pos.y += vw_offset_a;
        else if (_VertexWaveAxes.x == 2) vw_pos.z += vw_offset_a;
    
        if      (_VertexWaveAxes.y == 0) vw_pos.x += vw_offset_b;
        else if (_VertexWaveAxes.y == 1) vw_pos.y += vw_offset_b;
        else if (_VertexWaveAxes.y == 2) vw_pos.z += vw_offset_b;

        posWS = TransformObjectToWorld(vw_pos);
    #endif

    #if _LIQUID_VOLUME
        // float3 worldPos = mul(unity_ObjectToWorld, input.positionOS);
        // float3 worldPosOffset = dot(input.positionOS - _LiquidFill, _LiquidFillNormal);
        float3 lOrigin = mul(unity_ObjectToWorld, float4(input.positionOS, 0.0)).xyz;
        float3 worldPosOffset =  lOrigin + mul(normalize(_LiquidFillNormal), _LiquidFill);
        float3 worldPosX = RotateAboutAxis(worldPosOffset, float3(0,0,1),90);
        float3 worldPosZ = RotateAboutAxis(worldPosOffset, float3(1,0,0),90);
        float3 worldPosRotated = lOrigin + (worldPosX * _LiquidSwayX) + (worldPosZ * _LiquidSwayY);
    
        output.liquidEdge = float4(-worldPosRotated + _LiquidFill - 0.001, 0);
    #endif

    #if (_USE_TEXTURE || USE_TEXTURE__AS_MASK || _EMISSION)

        #if _UV_SOURCE__WORLD_PLANAR_Y
            float2 uvs = positionInputs.positionWS.xz;
        #else 
            float2 uvs = input.uv;
        #endif
        
        #if _MAINTEX_ROTATE
            uvs = RotateUV_Degrees(uvs, float2(0.5, 0.5), _RotateAngle, _RotateAnim);
        #endif

        #if _UV_WAVE_WARP
            uvs = WaveWarpUV(uvs, _WaveAmplitude, _WaveFrequency, _WaveScale);
        #endif

        #if _UV_SHIFT
            half2 _uvStep = _UvShiftSteps <= 0 ? 1. : 1. / _UvShiftSteps;
            half2 _uvShift = fmod(floor(_Time.y * _UvShiftRate) * _uvStep, 1.);
            half2 _uvOff = _uvStep + (_UvShiftOffset + _UvShiftSteps - 1) * _uvStep;
            uvs += _uvShift + _uvOff;
        #endif

        output.uv = TRANSFORM_TEX(uvs.xy, _BaseMap);

        #if _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z
            output.baseMapSlice = input.uv.z;
        #endif // _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z

        #if _EYECOMP
            float2 overrideUV = input.uv * _BaseMap_ST.xy + _EyeOverrideUVTransform.zw;
            output.uv = (output.uv * (1.0f - _EyeOverrideUV)) + (overrideUV * _EyeOverrideUV);
        #endif

        #if _EMISSION
            float2 emiUV = (uvs * _EmissionUVScrollSpeed.z)  + _EmissionUVScrollSpeed.xy * _Time.y;
            emiUV = TileAndOffset(emiUV, _BaseMap_ST.xy, _BaseMap_ST.zw);
            #if _EMISSION_USE_UV_WAVE_WARP
                emiUV = WaveWarpUV(emiUV, _WaveAmplitude, _WaveFrequency, _WaveScale);
            #endif
            output.emissionUV = emiUV;
        #endif
        
    #endif

    #if _USE_VERTEX_COLOR || _VERTEX_ANIM_FLAP || _VERTEX_ANIM_WAVE
        output.vertexColor = input.vertexColor;
    #endif

    #if LIGHTMAP_ON
        output.lightmapUV = input.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;
    #endif
        
    #if _WATER_EFFECT
        #if _WATER_CAUSTICS
            output.causticsUVs.xy = (
                _GlobalUnderwaterCausticsParams.y
                * (positionInputs.positionWS.xz + sin(positionInputs.positionWS.xz + _Time.y * 0.5))
            );
            output.causticsUVs.zw = output.causticsUVs.xy;

            float extraOffset = _Time.y * _GlobalUnderwaterCausticsParams.x;
            output.causticsUVs.x += extraOffset;
            output.causticsUVs.w += extraOffset;
        #endif // _WATER_CAUSTICS

        output.groundToWaterPlaneSignedDistance = (
            dot(posWS, _GlobalMainWaterSurfacePlane.xyz)
            + _GlobalMainWaterSurfacePlane.w
        );
    #endif

    #if _REFLECTIONS && _REFLECTIONS_MATCAP

        #if _REFLECTIONS_MATCAP_PERSP_AWARE
            // Construct rotation matrix for perspective-aware view align -- Albert
            float3 mcViewDir = normalize(posWS - _WorldSpaceCameraPos.xyz);                
            float3 mcUp = mul((float3x3) UNITY_MATRIX_I_V, float3(0, 1, 0));
            float3 mcRt = normalize(cross(mcUp, mcViewDir));
            mcUp = cross(mcViewDir, mcRt);
            float3x3 mcRot = float3x3(mcRt, mcUp, mcViewDir);

            // Persp-correct + aligned normal
            float2 _mcUV = mul(mcRot, normalWS).xy;
        #else
            // Simpler, perspective-agnostic implementation -- Albert
            float3 mcViewDir = mul((float3x3)UNITY_MATRIX_V, normalWS);
            float2 _mcUV = mcViewDir.xy;
        #endif
    
        output.matcapUV = _mcUV  * 0.5 + 0.5;                  
    #endif

    #if _MOUTHCOMP
        output.mouthUV = TRANSFORM_TEX(input.mouthUV, _MouthMap);
    #endif

    output.positionWS = posWS;
    output.positionCS = TransformWorldToHClip(posWS);
    output.normalWS = normalWS;

    #if _PARALLAX || _PARALLAX_PLANAR
        VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangent);
        
        output.tSpace0 = float4(normalInputs.normalWS, output.positionWS.x);
        output.tSpace1 = float4(normalInputs.tangentWS, output.positionWS.y);
        output.tSpace2 = float4(normalInputs.bitangentWS, output.positionWS.z);
    #endif
    
    #if _INNER_GLOW    
        float ig = 1 - saturate( length(input.positionOS + _InnerGlowParams.xyz) - _InnerGlowParams.w );
        ig = ig * ig;
    
        float ig_period = TWO_PI / _InnerGlowSinePeriod;    
        float ig_time = _GT_Time - _InnerGlowSinePhaseShift;
        float ig_percent = saturate(ig_time / _InnerGlowSinePeriod);
    
        float ig_tap_mask = pulse(12., ig_percent);    
        float ig_sine = sin(ig_time * ig_period + THREE_HALFS_PI) * 0.5 + 0.5;
    
        output.glowMask.rgb = _InnerGlowTap
            ? ig * ig_tap_mask
            : ig * (_InnerGlowSine ? ig_sine : 1);
    
        // output.glowMask.rgb = ig * (_InnerGlowTap ? ig_tap_mask : 1);
    #endif
        
    return output;
}


// Fragment Shader
//
half4 frag(Varyings input, bool facing: SV_IsFrontFace) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    // Process the albedo color
    half4 color = _BaseColor;

    #if (_USE_TEXTURE || USE_TEXTURE__AS_MASK)

        #if _TEXEL_SNAP_UVS
            float4 texel_size = _BaseMap_WH;

            texel_size.xy *= _TexelSnap_Factor;
            texel_size.zw /= _TexelSnap_Factor;
    
            float2 dST = GetFragmentDelta(input.uv, texel_size);
            input.positionWS = TexelSnap(input.positionWS, dST);
            input.normalWS = TexelSnap(input.normalWS, dST);
        #endif
    
        float2 texUV = input.uv.xy;

        #if _PARALLAX || _PARALLAX_PLANAR
            float3 _wv = GetWorldSpaceViewDir(input.positionWS);
    
            float3 _wn = input.tSpace0.xyz;
            float3 _wt = input.tSpace1.xyz;
            float3 _wbt = input.tSpace2.xyz;

            float3 t2w0 = float3(_wt.x, _wbt.x, _wn.x);
            float3 t2w1 = float3(_wt.y, _wbt.y, _wn.y);
            float3 t2w2 = float3(_wt.z, _wbt.z, _wn.z);
    
            float3 tanViewDir =
                t2w0 * _wv.x +
                t2w1 * _wv.y +
                t2w2 * _wv.z ;
        #endif
    
        #if _PARALLAX
            // More samples at oblique angles
            float nDotV = saturate( dot(input.normalWS, _wv) );
            int numSteps = (int) lerp(_ParallaxSamplesMinMax.y, _ParallaxSamplesMinMax.x, nDotV );

            // half clipValue;
            texUV = GetParallaxUVs(input.uv, tanViewDir, numSteps, _ParallaxAmplitude, TEXTURE2D_ARGS(_DepthMap, sampler_DepthMap));

            #if _PARALLAX_AA
                texUV = GetAntiAliasUV(texUV, _BaseMap_WH, (_ParallaxAABias / 255.0) * 0.9999);
            #endif

        #elif _PARALLAX_PLANAR
            texUV = ToPlanarParallaxUVs(input.uv, tanViewDir, _ParallaxAmplitude);
        #endif

        #if _USE_TEX_ARRAY_ATLAS && _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z
            _BaseMap_AtlasSlice = input.baseMapSlice;
        #endif // _USE_TEX_ARRAY_ATLAS && _GT_BASE_MAP_ATLAS_SLICE_SOURCE__UV1_Z

        half4 textureSample = SAMPLE_ATLASABLE_TEX2D(_BaseMap, sampler_BaseMap, texUV, _TexMipBias);

        #if USE_TEXTURE__AS_MASK
            color = (
                _BaseColor * textureSample.r
                + _GChannelColor * textureSample.g
                + _BChannelColor * textureSample.b
                + _AChannelColor * textureSample.a
            );
        #else
            color *= textureSample;
        #endif

        #if _ALPHA_DETAIL_MAP
            half2 detailInUV = _AlphaDetail_WorldSpace == 1.0f ? QuantizeUV(input.worldUV, _BaseMap_WH.zw, 2.5) : texUV; 
            half2 detailUV = TileAndOffset(detailInUV, _AlphaDetail_ST.xy, _AlphaDetail_ST.zw);

            detailUV = FilterNiceUV(detailUV, _BaseMap_WH.zw);
            half4 detailSample = SAMPLE_ATLASABLE_TEX2D(_BaseMap, sampler_BaseMap, detailUV, _TexMipBias);
            // color.rgb = lerp(color.rgb, color.rgb * detailSample.a, _AlphaDetail_Opacity);
            color.rgb = Blend_Overlay(color.rgb, detailSample.a, _AlphaDetail_Opacity);
        #endif
    
    #endif // (_USE_TEXTURE || USE_TEXTURE__AS_MASK)

    #if (_USE_WEATHER_MAP)
        half4 weatherMapSample = SAMPLE_ATLASABLE_TEX2D(_WeatherMap, sampler_WeatherMap, input.uv.xy, _TexMipBias);
        // // vvv poop vvv TODO: remove after done testing
        // _ZoneWeatherMapDissolveProgress = sin(((_Time.x * 4.0) + 1.0) * 0.5); //poop
        // // ^^^ poop ^^^
        const half weatherMapDissolveMask = saturate(
            Progress(weatherMapSample.a, _WeatherMapDissolveEdgeSize, _ZoneWeatherMapDissolveProgress)
        );
        color = lerp(weatherMapSample, color, weatherMapDissolveMask);
    #endif

    #if _EYECOMP
        half4 faceTextureSample = SAMPLE_ATLASABLE_TEX2D(_BaseMap, sampler_BaseMap, input.uv.xy, _TexMipBias);
        EyeTexture_ST.x = _EyeTileOffsetUV.x;
        EyeTexture_ST.y = _EyeTileOffsetUV.y;
        EyeTexture_ST.z = _EyeTileOffsetUV.z;
        EyeTexture_ST.w = _EyeTileOffsetUV.w;
        half4 eyeTextureSample = SAMPLE_ATLASABLE_TEX2D(_BaseMap, sampler_BaseMap, (input.uv.xy * EyeTexture_ST.xy)+EyeTexture_ST.zw, _TexMipBias);
        color = (eyeTextureSample.b*(1-faceTextureSample.a)) + (faceTextureSample.r*faceTextureSample.a);
        color.a = 1;
    #endif
    
    #if _MOUTHCOMP
        half4 mouthTextureSample = SAMPLE_TEXTURE2D(_MouthMap, sampler_MouthMap, input.mouthUV);
        color = (mouthTextureSample * mouthTextureSample.a) + (color * (1-mouthTextureSample.a)); 
    #endif  

    #if _USE_VERTEX_COLOR
        color *= input.vertexColor;
    #endif
    // Add lighting
    #ifdef LIGHTMAP_ON
    
        #if _USE_DAY_NIGHT_LIGHTMAP && DIRLIGHTMAP_COMBINED && !_UNITY_EDIT_MODE
            float4 lightmapColor = lerp(
                SAMPLE_TEXTURE2D(unity_Lightmap, samplerunity_Lightmap, input.lightmapUV),
                SAMPLE_TEXTURE2D(unity_LightmapInd, samplerunity_LightmapInd, input.lightmapUV),
                _GlobalDayNightLerpValue);
        #else // Use Unity lightmaps
            float4 lightmapColor = SAMPLE_TEXTURE2D(unity_Lightmap, samplerunity_Lightmap, input.lightmapUV);
        #endif
    
        color.rgb *= UnpackLightmap(lightmapColor);
    #endif

    // #if _VERTEX_LIGHTING
    //     color.rgb += input.lightMask;
    // #endif
    
    #if _CRYSTAL_EFFECT
        float3 wvDir = GetWorldSpaceViewDir(input.positionWS);
        float3 crsAvg = (float3(0, -1, 1) + wvDir) * 0.5;
        float3 crsDir = 1 - dot(input.normalWS, crsAvg);
        crsDir *= crsDir *= crsDir;
        float3 crsRim = saturate(pow(crsDir, _CrystalPower));
        // color.rgb = lerp(color, crsRim * _CrystalRimColor, _CrystalRimColor.a * 0.5);
        color.rgb *= lerp(color.rgb, crsRim * _CrystalRimColor.rgb, _CrystalRimColor.a * 1.05);
    #endif

    #if _USE_TEXTURE && _MASK_MAP_ON && _FX_LAVA_LAMP && _GRADIENT_MAP_ON
        float2 maskUV = texUV.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
    
        color.rgb = LavaBlobEffect(color.rgb, 0.23, maskUV,
            TEXTURE2D_ARGS(_MaskMap, sampler_MaskMap),
            TEXTURE2D_ARGS(_GradientMap, sampler_GradientMap));
    #endif

    #if _USE_TEXTURE && _GRID_EFFECT
        float gePixel = (color.r + color.g + color.b) / 3.; 
        color.rgb = GridEffect(texUV, gePixel, _BaseMap_WH.zw, _BaseColor, 0.01);
    #endif

    #if _REFLECTIONS
    
        #if _REFLECTIONS_MATCAP
            float2 refUV = input.matcapUV;
            
        #else
            float3 refDir = GetWorldSpaceViewDir(input.positionWS);
            float3 refCoords = reflect(-normalize(refDir), input.normalWS);

            #if _REFLECTIONS_BOX_PROJECT
                float3 refBoxExtents = _ReflectBoxSize * 0.5;
                float3 refBoxMin = _ReflectBoxCubePos - refBoxExtents;
                float3 refBoxMax = _ReflectBoxCubePos + refBoxExtents;
                float3 refRot = _ReflectBoxRotation;
    
                refCoords = BoxProject(refCoords, input.positionWS, _ReflectBoxCubePos, refBoxMin, refBoxMax);
            #endif
    
            refCoords = RotateAroundY_Degrees(refCoords, _ReflectRotate);
        
            float2 refUV = ToRadialCoords( refCoords + _ReflectOffset.xyz );
            refUV = refUV * _ReflectScale.xy;
        #endif

        #if _REFLECTIONS_USE_NORMAL_TEX
            float3 refTexN = UnpackNormal(SAMPLE_TEXTURE2D(_ReflectNormalTex, sampler_ReflectNormalTex, input.uv));
            refUV = refUV + refTexN.xy;
        #endif

        // refUV = TexelSnap(input.positionWS, input.uv, _BaseMap_WH);
    
        half4 refTex = SAMPLE_TEXTURE2D(_ReflectTex, sampler_ReflectTex, refUV);

        #if _REFLECTIONS_ALBEDO_TINT
            half3 mcCol = refTex.rgb * color.rgb * _ReflectTint.rgb;
        #else
            half3 mcCol = refTex.rgb * _ReflectTint.rgb;
        #endif

        half refAlpha = _ReflectOpacity * color.a;
        color.rgb = lerp(color.rgb, mcCol * _ReflectExposure, refAlpha);
    
    #endif

    #if _HALF_LAMBERT_TERM
        float3 hl_vdir = normalize(GetWorldSpaceViewDir(input.positionWS));
        float hl_ndotl = max(0.0,dot(input.normalWS, hl_vdir));
        float hl_diff = pow(hl_ndotl * 0.5 + 0.5,2.0);
        color.rgb *= hl_diff;
    #endif

    #if _GT_RIM_LIGHT
        float3 rl_view_dir = normalize(input.positionWS - _WorldSpaceCameraPos);
        half3 rl_color = half3(0.314, 0.396, 0.533); //Default skybox blue
        half rl_spec = GetGTClassicRimLight(rl_view_dir, input.normalWS, _Smoothness);

        #if _USE_TEXTURE && _GT_RIM_LIGHT_USE_ALPHA
            rl_spec *= textureSample.a;
        #endif
        
        color.rgb += rl_spec * rl_color;
    #endif
    
    #if _SPECULAR_HIGHLIGHT
        float sh_pow = _SpecularPowerIntensity.x;
        float sh_int = _SpecularPowerIntensity.y;
    
        float sh_term = SpecularHighlight(TransformViewToWorldDir(normalize(_SpecularDir)), input.normalWS, GetWorldSpaceViewDir(input.positionWS), sh_pow, sh_int);
        sh_term *= _SpecularColor.a;

        half3 sh_color = _SpecularColor.rgb;
    
        #if _USE_TEXTURE
            sh_term *= textureSample.a;
            if (_SpecularUseDiffuseColor) sh_color = textureSample.rgb;
        #endif

        color.rgb += sh_term * sh_color;
    
    #endif

    #if _EMISSION || _CRYSTAL_EFFECT
        half3 emissionValue = _EmissionColor.rgb * _EmissionColor.a;

        #if _ALPHA_DETAIL_MAP
            emissionValue = Blend_Multiply(emissionValue, detailSample.a, _AlphaDetail_Opacity);
        #endif

        #if _PARALLAX
            float2 emUV = GetParallaxUVs(input.emissionUV, tanViewDir, numSteps, _ParallaxAmplitude, TEXTURE2D_ARGS(_DepthMap, sampler_DepthMap));
        #elif _PARALLAX_PLANAR
            float2 emUV = ToPlanarParallaxUVs(input.emissionUV, tanViewDir, _ParallaxAmplitude);
        #else
            float2 emUV = input.emissionUV;
        #endif
    
        half4 emiMap = SAMPLE_ATLASABLE_TEX2D(_EmissionMap, sampler_EmissionMap, emUV, _TexMipBias);
        const half emissionDissolveMask = saturate(
            Progress(emiMap.a, _EmissionDissolveEdgeSize, _EmissionDissolveProgress)
        );
        emissionValue *= emiMap.rgb * emissionDissolveMask * (pow(abs(sin(_Time.x * _EmissionDissolveAnimation.y)), _EmissionDissolveAnimation.x));
        color.rgb += emissionValue * lerp(1.0, color.a, _EmissionMaskByBaseMapAlpha);
    #endif

    // ========== Ground Fog ==========

    // half4 _ZoneGroundFogColor = half4(0.5, 0.9, 1.0, 1.0);
    // float _ZoneGroundFogHeight = 7.45; // top of gazebo
    // float _ZoneGroundFogHeightFade = 1.0 / 20.0;
    // float _ZoneGroundFogDepthFade = 1.0 / 10.0;
    float offsetYFromCamera = input.positionWS.y - _WorldSpaceCameraPos.y;
    float inFogFraction = (_ZoneGroundFogHeight - _WorldSpaceCameraPos.y) / offsetYFromCamera;
    // basically: if(offsetFromCamera.y < 1) inFogFraction = 1-inFogFraction
    inFogFraction = saturate(0.5 + (inFogFraction - 0.5) * sign(offsetYFromCamera));
    float camDistSq = DistanceSq(input.positionWS, _WorldSpaceCameraPos);
    float vertDist = saturate(saturate((_ZoneGroundFogHeight - input.positionWS.y) * _ZoneGroundFogHeightFade) + saturate((_ZoneGroundFogHeight - _WorldSpaceCameraPos.y) * _ZoneGroundFogHeightFade));
    float groundFogMask = vertDist * saturate(inFogFraction * inFogFraction * camDistSq * _ZoneGroundFogDepthFadeSq);
    color = lerp(saturate(color), _ZoneGroundFogColor, groundFogMask * _ZoneGroundFogColor.a);
    
    #if _INNER_GLOW
        color.rgb = Blend_Screen(color.rgb, _InnerGlowColor.rgb, input.glowMask.r);
    #endif

    #if _WATER_EFFECT
        float groundToWaterPlaneSignedDistance = input.groundToWaterPlaneSignedDistance;
        #if _GLOBAL_ZONE_LIQUID_TYPE__LAVA
            // TODO: this should not be tied with caustics and instead should be specific for shore
            // blending.

            // LAVA - Only apply effect where the surface plane intersects horizontally facing surfaces.
            half4 lavaCausticsTexSample = SAMPLE_TEXTURE2D(
                _GlobalUnderwaterCausticsTex,
                sampler_GlobalUnderwaterCausticsTex,
                input.positionWS.xz * _GlobalZoneLiquidUVScale
            );
            
            half shoreDistMask = 1.0 - saturate(abs(groundToWaterPlaneSignedDistance) * 2.0);
            shoreDistMask *= shoreDistMask * shoreDistMask * shoreDistMask;
            color = lerp(color, lavaCausticsTexSample, shoreDistMask * lavaCausticsTexSample.a);
            half lavaLightDirectionMask = saturate((-input.normalWS.y - 0.3));
            color += color * (1.0 - (saturate(abs(groundToWaterPlaneSignedDistance) * _ZoneLiquidLightAttenuation))) * lavaLightDirectionMask * _ZoneLiquidLightColor;
        #endif
    
        //Add water effect
        half4 waterColor = color;
        bool doWaterEffect = true;
        #if _HEIGHT_BASED_WATER_EFFECT
            // We only want to do this if we're below the water plane otherwise
            // lerp at the end would undo it all
            doWaterEffect = groundToWaterPlaneSignedDistance < 0;
        #endif
    
        // ---- Caustics ----
        #if _WATER_CAUSTICS && !_GLOBAL_ZONE_LIQUID_TYPE__LAVA
            // Only apply caustics on surfaces that face up.
            half4 causticsTexSample1 = SAMPLE_TEXTURE2D(
                _GlobalUnderwaterCausticsTex, sampler_GlobalUnderwaterCausticsTex, input.causticsUVs.xy
            );
            half4 causticsTexSample2 = SAMPLE_TEXTURE2D(
                _GlobalUnderwaterCausticsTex, sampler_GlobalUnderwaterCausticsTex, input.causticsUVs.zw
            );
            half causticsNormalMultiplier = saturate(input.normalWS.y);
            // TODO: 8.0 multiplier should be controllable by ZoneShaderSettings.
            half causticsContribution = (
                (causticsTexSample1.g * causticsTexSample2.a * 8.0)
                * (causticsNormalMultiplier * causticsNormalMultiplier)
            );
            waterColor = saturate(waterColor + causticsContribution);
        #endif // _WATER_CAUSTICS && !_GLOBAL_ZONE_LIQUID_TYPE__LAVA

        // Branch after caustic sample to avoid breaking parallax due to driver issue(?)
        if(doWaterEffect) {
        // ---- Liquid Fogging ----

        // TODO: fog distance from surface plane to surface is not being applied properly. Currently there
        // is more liquid fogging the farther the camera is moved away from the water surface, but the
        // fogging should stay consistent while the camera is above the liquid's surface plane.
        //     --MattO

        float waterFogDistance = length(_WorldSpaceCameraPos - input.positionWS);
        waterFogDistance = (
            (waterFogDistance - _GlobalUnderwaterFogParams.x) / (_GlobalUnderwaterFogParams.y + 0.00024414)
        );
        waterFogDistance = waterFogDistance * waterFogDistance;

        float waterFogInfluence = saturate(
            (-groundToWaterPlaneSignedDistance - _GlobalUnderwaterEffectsDistanceToSurfaceFade.x)
            / (
                _GlobalUnderwaterEffectsDistanceToSurfaceFade.y
                - _GlobalUnderwaterEffectsDistanceToSurfaceFade.x
            )
        );

        float water_depth = input.positionVS.z / input.positionVS.w;
        water_depth = 1.0 - water_depth;

        float waterFogRemapped = min(waterFogDistance, waterFogInfluence);
        float waterFogMask = saturate(waterFogRemapped * _GlobalUnderwaterFogColor.a);

        float water_edge = 1.0 - dot(input.normalWS, input.viewDirWS);
        waterFogMask *= water_depth;

        float waterTintMask = _GlobalWaterTintColor.a;

        waterColor.rgb = lerp(waterColor.rgb, _GlobalUnderwaterFogColor.rgb, waterFogMask);
        waterColor.rgb = lerp(waterColor.rgb, _GlobalWaterTintColor.rgb, waterTintMask);

        // Increase readability underwater --Albert
        #if 1
        {
            float zd =  (input.positionVS.z) / input.positionVS.w;
            zd = 1.0 - saturate(zd / 0.0025);
            
            float water_term = pow(max(water_edge + water_depth, 0.0), 1.36);
            
            // waterColor.rgb = Blend_Overwrite(waterColor.rgb, waterColor.rgb * 1.26f, water_term);
            waterColor.rgb = Blend_SoftLight(waterColor.rgb, waterColor.rgb * 1.26f, zd * 0.56);
            
            #if _USE_TEXTURE
                waterColor.rgb = Blend_SoftLight(waterColor.rgb, bias(luma(textureSample.rgb).r, 0.5), 0.05);
            #endif
        }
        #endif
    
        #if _HEIGHT_BASED_WATER_EFFECT
            float underwaterMask = saturate(-groundToWaterPlaneSignedDistance * 1000.0);

            #if _ZONE_LIQUID_SHAPE__CYLINDER
                float zoneCyl_distSq = DistanceSq(
                    _ZoneLiquidPosRadiusSq.xz, input.positionWS.xz
                );
                float insideRadiusMask = saturate(
                    (_ZoneLiquidPosRadiusSq.w - zoneCyl_distSq) * 1000.0
                );
    
                float aboveBottomCapMask = saturate(
                    (input.positionWS.y - _ZoneLiquidPosRadiusSq.y) * 1000.0
                );
    
                underwaterMask *= insideRadiusMask * aboveBottomCapMask;
            #endif // _ZONE_LIQUID_SHAPE__CYLINDER

            // Apply the final mask to outgoing color.
            waterColor.rgb = lerp(color.rgb, waterColor.rgb, underwaterMask);
        #endif // _HEIGHT_BASED_WATER_EFFECT
            
        }
            // Trick compiler into not moving texture samples into the if scope
        color.rgb = lerp(color.rgb, waterColor.rgb, doWaterEffect);
    #endif //_WATER_EFFECT

    // One liquid mode at a time
    #if _LIQUID_CONTAINER
        #define _LIQUID_VOLUME_ALLOW 0
    #else
        #define _LIQUID_VOLUME_ALLOW 1
    #endif

    #if _LIQUID_VOLUME && _LIQUID_VOLUME_ALLOW
        // add movement based deform
        float _freq = 8;
        float _amp = 0.15;
    
        float swayStrength =  abs(_LiquidSwayX) + abs(_LiquidSwayY);            
        float sway = sin((input.liquidEdge.x * _freq) + (input.liquidEdge.z * _freq) + _Time.y) * (_amp * swayStrength);               
        float liquidEdge = input.liquidEdge.y + sway;

        #if _USE_TEXTURE
            float4 surfColor = _LiquidSurfaceColor;
        #else
            float4 surfColor = _LiquidSurfaceColor * color;
        #endif                
    
        // facing returns positive for front, negative for back
        color = facing > 0 ? color : surfColor;
    
    #endif
    
    #if _STEALTH_EFFECT
        float se_aspect = _ScreenParams.x / _ScreenParams.y;
        float2 se_screen_uv = input.positionVS.xy / input.positionVS.w;
        // float3 normalVS = TransformWorldToViewNormal(input.normalWS) / input.positionVS.w;
    
        // se_screen_uv += normalVS * 0.0256;
        // se_screen_uv += input.normalWS;
        float2 se_dms = float2(128 * se_aspect, 128);
    
        se_screen_uv = QuantizeUV(se_screen_uv, se_dms, lerp(1.0, 1.0 / input.positionVS.w, 0.32));
        // float3 stealth_sample = BoxBlur(se_screen_uv, 1, 0.25);
        half3 stealth_sample = _SAMPLE_CAMERA_TEX(se_screen_uv).xyz;
        // se_screen_uv = QuantizeUV(se_screen_uv, se_dms, 1);
        
        float xx = saturate(1.0 - pow(dot(normalize(input.viewDirWS), input.normalWS), 1.));
        float blend = (1.0 - xx) * 0.15;

        stealth_sample = Blend_Overwrite(stealth_sample, color.rgb, bias(1.0 - xx, 0.09));
        
        #if _WATER_EFFECT
            float water_plane_dist = -groundToWaterPlaneSignedDistance - _GlobalUnderwaterEffectsDistanceToSurfaceFade.x;
            float in_water = step(0, water_plane_dist);
            blend = in_water ? (1.0 - blend) * saturate(pow(water_plane_dist, 5)) * 0.25 : blend;
            color.rgb = Blend_Screen(stealth_sample, xx * _GlobalWaterTintColor * 0.25, saturate(water_plane_dist) * xx  );
        #else
            color.rgb = stealth_sample;
        #endif
    
    #endif
    
    #if _VERTEX_ANIM_WAVE_DEBUG
        float vw_new_pos;
        float vw_mask = VertexWaveMask(input.positionOS, _VertexWaveEnd.xyz, _VertexWaveSphereMask, _VertexWaveEnd.w, vw_new_pos, _VertexWaveFalloff.z, _VertexWaveFalloff.xy);
        color.rgb = lerp(frac(vw_new_pos), vw_mask, 1);
        color.rgb = input.vertexColor.rgb;
    #endif

    #if _DEBUG_PAWN_DATA
        float3 pn_posWS = input.positionWS;
        half3 pn_out_colors = 0;
        
        for (int j = 0; j < _GT_PawnActiveCount; ++j)
        {
            float4x4 pawn = _GT_PawnData[j];

            float4 pn_head  = pawn._m00_m01_m02_m03;
            float4 pn_body  = pawn._m10_m11_m12_m13;
            float4 pn_left  = pawn._m20_m21_m22_m23;
            float4 pn_right = pawn._m30_m31_m32_m33;

            float pn_m_head  = 1.0 - step(saturate(-(length(pn_posWS -  pn_head.xyz) -  pn_head.w)), 0);
            float pn_m_body  = 1.0 - step(saturate(-(length(pn_posWS -  pn_body.xyz) -  pn_body.w)), 0);
            float pn_m_left  = 1.0 - step(saturate(-(length(pn_posWS -  pn_left.xyz) -  pn_left.w)), 0);
            float pn_m_right = 1.0 - step(saturate(-(length(pn_posWS - pn_right.xyz) - pn_right.w)), 0);
            
            pn_out_colors +=
                pn_m_head  * half3(1,0,1) +
                pn_m_body  * half3(0,1,0) +
                pn_m_left  * half3(0,0,1) +
                pn_m_right * half3(1,0,0);
        }

        color.rgb += pn_out_colors;
    #endif

    #if 0 // GTShaderVolume Debug
        float3 vol_mask = 0;
        half3 vol_col = 0;
        
        // UNITY_UNROLL
        for(int jj = 0; jj < _GT_ShaderVolumesActive; ++jj)
        {
            float4x4 vol_data = _GT_ShaderVolumes[jj];

            float3 vpos = vol_data._m00_m01_m02;
            float4 vrot = vol_data._m10_m11_m12_m13;
            float3 vscl = vol_data._m20_m21_m22;

            vpos = vpos - input.positionWS;
            vpos = RotateByQuat(vpos, vrot);
            
            float3 vunit = (vpos) / (vscl) - 0.5;
            vunit = 1.0 - frac(vunit);
            
            half3 vol_sample = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, vunit.xy);

            vol_mask = saturate(1.0 - sdf_box_round(vpos, vscl * 0.5 - 1.0, -1));
            color.rgb += vol_mask * vol_sample;
        }
        
        color.rgb += vol_col;
    #endif

    //
    // Make sure any sort of color grading is the last _color_ operation 
    //
    
    // Grey Zone
    if (_GreyZoneActive && !_GreyZoneException)
    {
        color.rgb = saturate(mul(_GT_CG_Achromatopsia, color.rgb));
    }
    
    //
    // Color blindness tests
    //
    #if _COLOR_GRADE_PROTANOMALY
        color.rgb = saturate(mul(_GT_CG_Protanomaly, color.rgb));
    #elif _COLOR_GRADE_PROTANOPIA
        color.rgb = saturate(mul(_GT_CG_Protanopia, color.rgb));
    #elif _COLOR_GRADE_DEUTERANOMALY
        color.rgb = saturate(mul(_GT_CG_Deuteranomaly, color.rgb));
    #elif _COLOR_GRADE_DEUTERANOPIA
        color.rgb = saturate(mul(_GT_CG_Deuteranopia, color.rgb));
    #elif _COLOR_GRADE_TRITANOMALY
        color.rgb = saturate(mul(_GT_CG_Tritanomaly, color.rgb));
    #elif _COLOR_GRADE_TRITANOPIA
        color.rgb = saturate(mul(_GT_CG_Tritanopia, color.rgb));
    #elif _COLOR_GRADE_ACHROMATOMALY
        color.rgb = saturate(mul(_GT_CG_Achromatomaly, color.rgb));
    #elif _COLOR_GRADE_ACHROMATOPSIA
        color.rgb = saturate(mul(_GT_CG_Achromatopsia, color.rgb));
    #endif

    //
    // On tiled renderers (i.e. Quest/Adreno), a tile will re-render if
    // a clip or discard is hit mid-shader, so run all such logic at the
    // absolute tail end, when no more buffer contribution can happen
    // -- Albert
    //
    
    float clip_mask = 0;
    
    #if _ALPHATEST_ON

        clip_mask = min(clip_mask, color.a - _Cutoff);
    
    #elif _ALPHA_BLUE_LIVE_ON

        float in_alpha = color.a - _Cutoff;
        float2 screen_uv = input.positionVS.xy / input.positionVS.w;
    
        float clip_blue = DitherBlue(screen_uv, in_alpha, 0) * 2.h - 1.h;
        clip_mask = min(clip_mask, clip_blue);
    
    #endif

    #if _LIQUID_CONTAINER
    
        float lc_mask = dot(input.positionWS.xyz - _LiquidPlanePosition, _LiquidPlaneNormal);
        clip_mask = min(clip_mask, lc_mask);

    #elif _LIQUID_VOLUME
    
        float3 lv_cut = -step(liquidEdge, 0.5);
        clip_mask = min(clip_mask, lv_cut);
    
    #endif

    #if _ALPHATEST_ON || _ALPHA_BLUE_LIVE_ON || _LIQUID_CONTAINER || _LIQUID_VOLUME
    
        clip(clip_mask);
    
    #endif
    
    return color;
}