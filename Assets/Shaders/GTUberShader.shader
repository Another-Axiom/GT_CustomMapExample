Shader "GorillaTag/UberShader" 
{

    // Cyanilux's page, a great reference for scripting URP shaders: 
    // https://www.cyanilux.com/tutorials/urp-shader-code/

    HLSLINCLUDE
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
            #define _ZONE_LIQUID_SHAPE__CYLINDER 1
            #define _HEIGHT_BASED_WATER_EFFECT 1
            // #define _UV_SOURCE__WORLD_PLANAR_Y 1
            #define _GLOBAL_ZONE_LIQUID_TYPE__LAVA 1
            #define _USE_TEX_ARRAY_ATLAS 1
            #define _LIQUID_CONTAINER 1
            #define _USE_DEFORM_MAP 1
            #define _USE_DAY_NIGHT_LIGHTMAP 1
            #define DIRLIGHTMAP_COMBINED 1
            #define _UNITY_EDIT_MODE 0
        #endif

        #include "GTUberShader.Common.hlsl"
        #include "GTUberShader.Funcs.hlsl"
    
        CBUFFER_START(UnityPerMaterial)
            #include "GTUberShader.CBuffer.hlsl"
        CBUFFER_END
    
    ENDHLSL

    Properties 
    {
        [Enum(GTShaderTransparencyMode)] _TransparencyMode ("Transparency Mode", Integer) = 0
        _Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [Space]
        [Enum(GTShaderColorSource)] _ColorSource ("Color Source", Integer) = 0
        [MainColor] _BaseColor ("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _GChannelColor ("G Channel Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _BChannelColor ("B Channel Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _AChannelColor ("A Channel Color", Color) = (1.0, 1.0, 1.0, 1.0)

        _TexMipBias ("Texture Mip Bias", Float) = 0

        [MainTexture] _BaseMap ("Base Map", 2D) = "white" {}
        [TexelSizeFor(_BaseMap)] _BaseMap_WH ("Base Map Texel Size", Vector)  = (0,0,0,0)
        [Toggle(_TEXEL_SNAP_UVS)] _TexelSnapToggle("Texel Snap", Float) = 0
        _TexelSnap_Factor("Texel Snap Factor", Range(1, 16)) = 1 
        [Enum(GTShaderUVSource)] _UVSource ("UV Source", Integer) = 0
        
        [Toggle(_ALPHA_DETAIL_MAP)] _AlphaDetailToggle ("Base Map Alpha Detail", Float) = 0
        _AlphaDetail_ST("Alpha Detail - Tile and Offset", Vector) = (1,1,0,0)
        _AlphaDetail_Opacity("Alpha Detail - Opacity", Range(0,1)) = 1
        [Toggle] _AlphaDetail_WorldSpace("Alpha Detail - World Space UVs", Float) = 0
        
        [Space]
        [Toggle(_MASK_MAP_ON)] _MaskMapToggle ("Use Mask Map", Float) = 0
        _MaskMap ("Mask Map", 2D) = "white" {}
        [TexelSizeFor(_MaskMap)] _MaskMap_WH ("Mask Map Texel Size", Vector) = (0,0,0,0)
        
        [Toggle(_FX_LAVA_LAMP)] _LavaLampToggle ("Lava Lamp FX", Float) = 0
        
        [Space]
        [Toggle(_GRADIENT_MAP_ON)] _GradientMapToggle("Use Gradient Map", Float) = 0
        [NoScaleOffset] _GradientMap ("Gradient Map", 2D) = "white" {}

        [Space]
        [Toggle(_MAINTEX_ROTATE)] _DoTextureRotation ("Rotate Base Texture", Float) = 0
        _RotateAngle ("Degrees", Float) = 0
        [Toggle] _RotateAnim ("Animate", Float) = 0

        [Space]
        [Toggle(_UV_WAVE_WARP)] _UseWaveWarp  ("Wave Warp UVs", Float) = 0
        _WaveAmplitude ("Wave Amplitude", Float) = 0.02
        _WaveFrequency ("Wave Frequency", Float) = 1
        _WaveScale ("Wave Scale", Float) = 12
        _WaveTimeScale ("Wave Timescale", Float) = 1
        
        [Toggle(_USE_WEATHER_MAP)] _UseWeatherMap ("Use Weather Map", Float) = 0
        [NoScaleOffset] _WeatherMap ("Weather Map", 2D) = "grey" {}
        _WeatherMapDissolveEdgeSize ("Weather Dissolve Edge Size", Range(0.0001, 1.0)) = 0.1
        
        [Space]
        [Toggle(_REFLECTIONS)] _ReflectToggle ("Reflections", Float) = 0
        [Toggle(_REFLECTIONS_BOX_PROJECT)] _ReflectBoxProjectToggle("Box Projection", Float) = 0
        [Vec3] _ReflectBoxCubePos("Box Project Cube Origin", Vector) = (0,0,0,1)
        [Vec3] _ReflectBoxSize("Box Size", Vector) = (1,1,1,1)
        [HideInInspector] [Vec3] _ReflectBoxRotation("Box Rotation", Vector) = (0, 0, 0, 1)
        [Toggle(_REFLECTIONS_MATCAP)] _ReflectMatcapToggle ("Matcap", Float) = 0
        [Toggle(_REFLECTIONS_MATCAP_PERSP_AWARE)] _ReflectMatcapPerspToggle ("Matcap - View Align", Float) = 1
        [Toggle(_REFLECTIONS_USE_NORMAL_TEX)] _ReflectNormalToggle ("Use Normal Map", Float) = 0
        [NoScaleOffset] _ReflectTex ("Reflection Map", 2D) = "gray" {}
        [NoScaleOffset] _ReflectNormalTex("Normal Map", 2D) = "black" {}
        [Toggle(_REFLECTIONS_ALBEDO_TINT)] _ReflectAlbedoTint ("Tint by Albedo", Float) = 0
        _ReflectTint ("Tint", Color) = (1, 1, 1, 1)
        _ReflectOpacity ("Opacity", Range(0, 1)) = 1
        _ReflectExposure ("Exposure", Range(1, 16)) = 1
        [Vec3] _ReflectOffset ("Shift", Vector) = (0,0,0,0)
        [Vec2] _ReflectScale ("Scale", Vector) = (1, 1, 1, 1)
        _ReflectRotate ("Rotation", Range(0, 360)) = 0
        
        [Space]
        [Toggle(_HALF_LAMBERT_TERM)] _HalfLambertToggle("Half Lambert", Float) = 0
        
        [Space]
        [Toggle] _ZFightOffset("Z-Fighting Offset", Integer) = 0
        
        [Space]
        [Toggle(_PARALLAX_PLANAR)] _ParallaxPlanarToggle("Planar Parallax", Float) = 0
        
        
        [Space]
        [Toggle(_PARALLAX)] _ParallaxToggle("Parallax Occlusion Mapping", Float) = 0
        [Toggle(_PARALLAX_AA)] _ParallaxAAToggle("Parallax AA", Float) = 0
        _ParallaxAABias("Parallax AA Bias", Range(0, 255)) = 127
        [NoScaleOffset] _DepthMap ("Parallax Depth Map", 2D) = "gray" {}
        _ParallaxAmplitude ("Parallax Strength", Float) = 8.16
        [Vec2] _ParallaxSamplesMinMax ("Parallax Samples Min Max", Vector) = (4, 64, 0, 0) 
        
        [Space]
        [Toggle(_UV_SHIFT)] _UvShiftToggle ("UV Shift", Float) = 0
        [Vec2] _UvShiftSteps("Steps", Vector) = (1,1,0,0)
        [Vec2] _UvShiftRate("Rate", Vector) = (0,0,0,0)
        [Vec2] _UvShiftOffset("Offset", Vector) = (0,0,0,0)
        
        [Space]
        [Toggle(_GRID_EFFECT)] _UseGridEffect("Grid Effect", Float) = 0

        [Space]
        [Toggle(_CRYSTAL_EFFECT)] _UseCrystalEffect ("Crystal Effect", Float) = 0
        _CrystalPower("Crystal Power", Float) = 0.32
        _CrystalRimColor("Crystal Rim Color", Color) = (0.382, 0.382, 0.382, 1.0)

        [Space]
        [Toggle(_LIQUID_VOLUME)] _LiquidVolume ("Liquid Volume", Float) = 0
        _LiquidFill ("Fill Amount", Range(-2, 2)) = 0.86
        _LiquidFillNormal("Fill Normal", Vector) = (0, 1, 0, 1)
        _LiquidSurfaceColor ("Surface Color", Color) = (0, 1, 0, 1)
        _LiquidSwayX ("Sway X", Range(-1, 1)) = 0    
        _LiquidSwayY ("Sway Y", Range(-1, 1)) = 0

        [Space]
        [Toggle(_LIQUID_CONTAINER)] _LiquidContainer("Liquid Container (Legacy)", Float) = 0
        _LiquidPlanePosition("Plane Position", Vector) = (0, 0, 0, 1)
        _LiquidPlaneNormal("Plane Normal", Vector) = (0, -1, 0, 1)
        
        [Space]
        [Toggle(_VERTEX_ANIM_FLAP)] _VertexFlapToggle("Vertex Flap Animation", Float) = 0
        [Vec3] _VertexFlapAxis("Flap Axis (Local Space)", Vector) = (0, 1, 0, 1)
        [Vec2] _VertexFlapDegreesMinMax("Flap Degrees Min Max", Vector) = (-20.0, 60.0, 1, 1)
        _VertexFlapSpeed("Flap Speed", Float) = 1
        _VertexFlapPhaseOffset("Flap Phase Offset", Float) = 0
        
        [Space]
        [Toggle(_VERTEX_ANIM_WAVE)] _VertexWaveToggle("Vertex Wave Animation", Float) = 0
        [Toggle(_VERTEX_ANIM_WAVE_DEBUG)] _VertexWaveDebug("Vertex Wave Debug", Float) = 0
        _VertexWaveEnd("Wave Direction", Vector) = (0, 0, 0, 1)
        _VertexWaveParams("Wave Parameters", Vector) = (1, 1, 1, 16)
        _VertexWaveFalloff("Wave Falloff", Vector) = (0,1,0,0)
        _VertexWaveSphereMask("Wave Sphere Mask", Vector) = (0,0,0,0)
        _VertexWavePhaseOffset("Wave Phase Offset", Float) = 0
        [Vec2] _VertexWaveAxes("Wave Axes", Vector) = (0, 1, 0, 0)
        
        [Space]
        [Toggle(_VERTEX_ROTATE)] _VertexRotateToggle("Vertex Rotation", Float) = 0
        _VertexRotateAngles("Vertex Rotation Amount", Vector) = (0,0,0,0)
        [Toggle] _VertexRotateAnim("Vertex Rotation - Animate", Float) = 0
        
        [Space]
        [Toggle(_VERTEX_LIGHTING)] _VertexLightToggle("Vertex Lighting", Float) = 0
        
        [Space]
        [Toggle(_INNER_GLOW)] _InnerGlowOn("Inner Glow", Float) = 0
        _InnerGlowColor("Inner Glow Color", Color) = (1, 0.1, 0.47, 1)
        _InnerGlowParams("Inner Glow Settings", Vector) = (0,0,0,1)
        [Toggle] _InnerGlowTap("Inner Glow Tap Effect", Float) = 0
        [Toggle] _InnerGlowSine("Inner Glow Sine", Float) = 0
        _InnerGlowSinePeriod("Inner Glow Sine Period (seconds)", Float) = 1
        _InnerGlowSinePhaseShift("Inner Glow Sine Phase Shift", Float) = 0
        
        [Space]
        [Toggle(_STEALTH_EFFECT)] _StealthEffectOn("Stealth Effect", Float) = 0

        [Space]
        [Toggle(_EYECOMP)] _UseEyeTracking ("Use Eye Tracking", Float) = 0
        _EyeTileOffsetUV ("EyeTilingOffset", Vector) = (1.0,1.0,0.0,0.0)
        [HideInInspector]_EyeOverrideUV ("Override UV", float) = 0
        [HideInInspector]_EyeOverrideUVTransform ("Override UV Transform", Vector) = (1.0,1.0,0.0,0.0)

        [Space]
        [Toggle(_MOUTHCOMP)] _UseMouthFlap ("Use Mouth Flap", Float) = 0
        _MouthMap ("Mouth Texture", 2D) = "white" {}

        [Space]
        [Toggle(_USE_VERTEX_COLOR)] _UseVertexColor ("Use Vertex Color", Float) = 0
        [Toggle(_WATER_EFFECT)] _WaterEffect ("Water Effect", Float) = 0
        [Toggle(_HEIGHT_BASED_WATER_EFFECT)] _HeightBasedWaterEffect ("Partial Water Effect", Float) = 0
        [Toggle(_WATER_CAUSTICS)] _WaterCaustics ("Water Caustics", Float) = 0

        [Space]
        [Toggle(_USE_DAY_NIGHT_LIGHTMAP)] _UseDayNightLightmap ("Use Day/Night Lightmap", Float) = 0
        
        [Space]
        [Toggle(_GT_RIM_LIGHT)] _UseSpecular ("Rim Light", Float) = 0
        [Toggle(_GT_RIM_LIGHT_USE_ALPHA)] _UseSpecularAlphaChannel ("Rim Light - Mask By Diffuse Alpha", Float) = 0
        _Smoothness("Rim Light Smoothness", Range(0.0, 1.0)) = 0.0
        
        [Space]
        [Toggle(_SPECULAR_HIGHLIGHT)] _UseSpecHighlight ("Specular Highlight", Float) = 0
        [Vec3] _SpecularDir ("Specular Direction", Vector) = (0, -1, 0, 0)
        [Vec2] _SpecularPowerIntensity ("Specular Power / Intensity", Vector) = (16.0,1.0,0,0)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        [Toggle] _SpecularUseDiffuseColor ("Tint By Diffuse", Int) = 0

        [Space]
        [Toggle(_EMISSION)] _EmissionToggle ("Emission", Float) = 0
        [HDR] _EmissionColor("Emission Color", Color) = (0.0, 0.0, 0.0, 0.0)
        [NoScaleOffset] _EmissionMap("Emission Map", 2D) = "white" {}
        _EmissionMaskByBaseMapAlpha("Emission - Mask Influence By Base Map Alpha", Range(0.0, 1.0)) = 1.0
        [Vec3] _EmissionUVScrollSpeed("Emission - UV Scroll Speed & Scale", Vector) = (0.0, 0.0, 1.0, -0.0)
        _EmissionDissolveProgress("Emission - Dissolve Progress", Range(0.0, 1.0)) = 1.0
        [Vec2] _EmissionDissolveAnimation("Emission - Dissolve Anim", Vector) = (0.0, 1.0, -0.0, -0.0)
        _EmissionDissolveEdgeSize("Emission - Dissolve Edge Size", Range(0.0001, 1.0)) = 0.1
        [Toggle(_EMISSION_USE_UV_WAVE_WARP)] _EmissionUseUVWaveWarp("Emission - Use UV Wave Warp", Float) = 0.0
//        [Toggle(_EMISSION_USE_FLOW_MAP)] _EmissionUseFlowMap("Emission - Use Flow Map", 2D) = "white" {}
        
        [Space]
        [Toggle] _GreyZoneException("Grey Zone Exception", Float) = 0

        [Space]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Int) = 2

        [IntRange] _StencilReference("Stencil Reference", Range(0 , 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComparison("Stencil Comparison", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassFront("Stencil Pass Front", Float) = 0
//        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFailFront("Stencil Fail Front", Float) = 0
//        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailFront("Stencil Z Fail Front", Float) = 0
//        [IntRange] _StencilReadMask("Stencil Read Mask", Range(0 , 255)) = 255
//        [IntRange] _StencilWriteMask("Stencil Write Mask", Range(0 , 255)) = 255

        [Space]
        [Toggle(_USE_DEFORM_MAP)] _USE_DEFORM_MAP("Use Deform Map", Int) = 0
        [NoScaleOffset] _DeformMap("Deform Map", 2D) = "gray" {}
        _DeformMapIntensity("Deform Map Intensity", Float) = 1.0
        _DeformMapMaskByVertColorRAmount("Deform Map Mask By Vertex Color R Amount", Float) = 1.0
        [Vec2] _DeformMapScrollSpeed("Deform Map Scroll Speed", Vector) = (1.0, 1.0, -0, -0)
        [Vec2] _DeformMapUV0Influence("Deform Map UV0 Influence", Vector) = (1.0, 1.0, -0, -0)
        // Used by Candle Flame
        [Vec3] _DeformMapObjectSpaceOffsetsU("Deform Map Object Space Offsets U", Vector) = (0.0, 0.0, 0.0, -0)
        [Vec3] _DeformMapObjectSpaceOffsetsV("Deform Map Object Space Offsets V", Vector) = (0.0, 0.0, 0.0, -0)
        [Vec3] _DeformMapWorldSpaceOffsetsU("Deform Map World Space Offsets U", Vector) = (0.0, 0.0, 0.0, -0)
        [Vec3] _DeformMapWorldSpaceOffsetsV("Deform Map World Space Offsets V", Vector) = (0.0, 0.0, 0.0, -0)
        // Used by Candle Flame
        _RotateOnYAxisBySinTime("Rotate By Sine of Time (t/8, t/4, t/2, t)", Vector) = (0.0, 0.0, 0.0, 0.0)


        [Space]
        [Toggle(_USE_TEX_ARRAY_ATLAS)] _USE_TEX_ARRAY_ATLAS ("Debug/Use Tex Array Atlas", Int) = 0
        [NoScaleOffset] _BaseMap_Atlas ("Debug/Base Map - Atlas", 2DArray) = "" {}
        _BaseMap_AtlasSlice ("Debug/Base Map - Atlas Slice", Int) = 0
        [Enum(GTAtlasSliceSource)] _BaseMap_AtlasSliceSource ("Debug/Base Map - Atlas Slice Source", Int) = 0

        [NoScaleOffset] _EmissionMap_Atlas ("Debug/Emission Map - Atlas", 2DArray) = "" {}
        _EmissionMap_AtlasSlice ("Debug/Emission Map - Atlas Slice", Int) = 0
        [NoScaleOffset] _DeformMap_Atlas ("Debug/Deform Map - Atlas", 2DArray) = "" {}
        _DeformMap_AtlasSlice ("Debug/Deform Map - Atlas Slice", Int) = 0
        [NoScaleOffset] _WeatherMap_Atlas ("Debug/Deform Map - Atlas", 2DArray) = "" {}
        _WeatherMap_AtlasSlice ("Debug/Deform Map - Atlas Slice", Int) = 0


        [Space]
        [Toggle(_DEBUG_PAWN_DATA)] _DEBUG_PAWN_DATA ("Pawn Data Debug View", Float) = 0

        //These values control alpha blending, and are set by the script when "Transparency Mode" is changed
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0

        //Light baker relies on legacy _Color's alpha value to determine transparency
        [HideInInspector] _Color("Legacy Color", Color) = (1.0, 1.0, 1.0, 1.0)

        //These CBUFFER parameters in the meta pass need corresponding property declarations for URP's batcher to work
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        [HideInInspector] _SpecColor("Specular", Color) = (0.2, 0.2, 0.2)

        _DayNightLightmapArray("DayNightLightmapsArray", 2DArray) = "" {}
        _DayNightLightmapArray_AtlasSlice ("DayNightLightmapsArray - Atlas Slice", Int) = 0
        //_DayNightSingleLightmap ("DayNightSingleLightmap", 2D) = "white" {}
//        _SingleLightmap ("SingleLightmap", 2D) = "white" {}
    }

    SubShader 
    {
        //Specifying RenderPipeline sets the Shader.globalRenderPipeline property
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }
        LOD 100

        Blend [_SrcBlend][_DstBlend],[_SrcBlendAlpha][_DstBlendAlpha]
        ZWrite [_ZWrite]
        Cull [_Cull]
        AlphaToMask [_AlphaToMask]

        Stencil 
        {
            Ref [_StencilReference]
//            ReadMask [_StencilReadMask]
//            WriteMask [_StencilWriteMask]
            Comp [_StencilComparison]
            Pass [_StencilPassFront]
//            Fail [_StencilFailFront]
//            ZFail [_StencilZFailFront]
        }

        Pass 
        {
            Name "UniversalForward"
            Tags 
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
                #include_with_pragmas "GTUberShader.Pass.Forward.hlsl"
            ENDHLSL
        }


        //This pass is used for shadow casting to determine which parts of the scene a light can "see"
        //So it doesn't need color information or multi-eye support, but must support alpha clipping
        Pass 
        {
            Name "ShadowCaster"
            Tags 
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
                #include_with_pragmas "GTUberShader.Pass.ShadowCaster.hlsl"
            ENDHLSL
        }

        //This pass is used for the depth prepass; it does not need color information
        //but does need to support multi-eye rendering and alpha clipping
        Pass 
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            ColorMask 0
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
                #include_with_pragmas "GTUberShader.Pass.DepthOnly.hlsl"
            ENDHLSL
        }
        
        //This pass is used only for baking lights.
        Pass 
        {
            Name "Meta"
            Tags 
            {
                "LightMode" = "Meta"
            }

            Blend [_SrcBlend][_DstBlend],[_SrcBlendAlpha][_DstBlendAlpha]
            Cull Off

            HLSLPROGRAM
                #include_with_pragmas "GTUberShader.Pass.Meta.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "GT_CustomMapSupportEditor.GTUberShaderGUI"
}
