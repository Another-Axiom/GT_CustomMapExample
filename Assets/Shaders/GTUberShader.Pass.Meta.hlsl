#pragma target 3.0

#pragma vertex UniversalVertexMeta
#pragma fragment CustomFragmentMeta

#pragma shader_feature_local_fragment _ALPHATEST_ON
#pragma shader_feature_local_fragment _EMISSION

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UniversalMetaPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"

#include "GTUberShader.Common.hlsl"
#include "GTUberShader.Cbuffer.hlsl"

DECLARE_ATLASABLE_TEX2D(_BaseMap);
DECLARE_ATLASABLE_SAMPLER(sampler_BaseMap);

#if _EMISSION
DECLARE_ATLASABLE_TEX2D(_EmissionMap);
DECLARE_ATLASABLE_SAMPLER(sampler_EmissionMap);
#endif

float4 CustomFragmentMeta(Varyings input) : SV_Target
{
    float3 metaColor;

    half4 albedo = SAMPLE_ATLASABLE_TEX2D(_BaseMap, sampler_BaseMap, input.uv, 0.0);
    half alpha = albedo.a * _BaseColor.a;

    #if _ALPHATEST_ON
    clip(alpha - _Cutoff);
    #endif

    albedo.rgb *= _BaseColor.rgb;
    BRDFData brdfData;
    InitializeBRDFData(albedo.rgb, _Metallic, half3(0.0, 0.0, 0.0), _Smoothness, alpha, /*out*/ brdfData);
    metaColor = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;

    #if _EMISSION
    float3 emissionColor = SAMPLE_ATLASABLE_TEX2D(_EmissionMap, sampler_EmissionMap, input.uv, 0.0).rgb * _EmissionColor.rgb;
    metaColor = max(metaColor, emissionColor);
    #endif

    return float4(metaColor, 1.0);
}